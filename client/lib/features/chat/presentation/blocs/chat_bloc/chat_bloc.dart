import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:client/features/chat/data/datasources/models/message_model.dart';
import 'package:client/features/chat/data/datasources/services/chat_firestore_service.dart';
import 'package:client/features/chat/domain/entities/message.dart';
import 'package:client/features/chat/domain/usecases/send_chat_usecase.dart';

import 'package:meta/meta.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendChatUsecase sendChatUsecase;
  final ChatFirestoreService _firestoreService = ChatFirestoreService();
  final List<Message> _messages = [];
  String? _userId;
  String? _currentThreadId;
  StreamSubscription? _threadsSub;

  ChatBloc({required this.sendChatUsecase}) : super(ChatState()) {
    on<SendChatEvent>(_onSendChat);
    on<RegenerateResponseEvent>(_onRegenerate);
    on<NewChatEvent>(_onNewChat);
    on<LoadThreadEvent>(_onLoadThread);
    on<DeleteThreadEvent>(_onDeleteThread);
    on<SetUserIdEvent>(_onSetUserId);
    on<_ThreadsUpdatedEvent>(_onThreadsUpdated);
    on<_MessagesLoadedEvent>(_onMessagesLoaded);
  }

  void _onSetUserId(SetUserIdEvent event, Emitter<ChatState> emit) {
    if (_userId == event.userId && _threadsSub != null) return;
    
    // Clear all state when switching users to prevent showing previous user's data
    if (_userId != null && _userId != event.userId) {
      _messages.clear();
      _currentThreadId = null;
      emit(ChatState()); // Emit empty state while loading
    }
    
    _userId = event.userId;
    _threadsSub?.cancel();
    _threadsSub = _firestoreService.getThreads(_userId!).listen(
      (threads) {
        if (!isClosed) add(_ThreadsUpdatedEvent(threads));
      },
      onError: (_) {
        if (!isClosed) add(_ThreadsUpdatedEvent([]));
      },
    );
  }

  void _onThreadsUpdated(_ThreadsUpdatedEvent event, Emitter<ChatState> emit) {
    final hasThreads = event.threads.isNotEmpty;
    final noThreadLoaded = _currentThreadId == null;

    // Auto-load latest thread on initial load when no thread is selected
    // Skip auto-load if user has interacted to prevent race condition with new chat
    if (hasThreads && noThreadLoaded && _messages.isEmpty && !state.userHasInteracted) {
      final latestThread = event.threads.first;
      _currentThreadId = latestThread.id;
      // Emit threads first, then load messages asynchronously
      emit(state.copyWith(state.messages, true,
          threads: event.threads, currentThreadId: _currentThreadId));

      // Load messages asynchronously
      _firestoreService.getMessages(latestThread.id).then((messages) {
        // Clear messages first to prevent duplicates in race conditions
        _messages.clear();
        _messages.addAll(messages);
        if (!isClosed) {
          add(_MessagesLoadedEvent(List.unmodifiable(_messages)));
        }
      });
    } else {
      emit(state.copyWith(state.messages, state.isLoading, threads: event.threads));
    }
  }

  void _onMessagesLoaded(_MessagesLoadedEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(event.messages, false,
        currentThreadId: _currentThreadId, threads: state.threads));
  }

  Future<void> _onNewChat(NewChatEvent event, Emitter<ChatState> emit) async {
    _messages.clear();
    _currentThreadId = null;
    emit(ChatState(threads: state.threads));
  }

  Future<void> _onLoadThread(LoadThreadEvent event, Emitter<ChatState> emit) async {
    _currentThreadId = event.threadId;
    _messages.clear();
    emit(state.copyWith(List.unmodifiable(_messages), true,
        currentThreadId: _currentThreadId));

    final messages = await _firestoreService.getMessages(event.threadId);
    _messages.addAll(messages);
    emit(state.copyWith(List.unmodifiable(_messages), false,
        currentThreadId: _currentThreadId));
  }

  Future<void> _onDeleteThread(DeleteThreadEvent event, Emitter<ChatState> emit) async {
    await _firestoreService.deleteThread(event.threadId);
    if (_currentThreadId == event.threadId) {
      _messages.clear();
      _currentThreadId = null;
      emit(ChatState(threads: state.threads));
    }
  }

  Future<void> _onSendChat(SendChatEvent event, Emitter<ChatState> emit) async {
    if (event.text.trim().isEmpty) return;

    // Create thread if needed
    final isFirstMessage = _currentThreadId == null;
    if (isFirstMessage && _userId != null) {
      final thread = await _firestoreService.createThread(_userId!);
      _currentThreadId = thread.id;
      // ✅ REMOVED: the redundant updateThreadTitle('New Chat') line
      // Title will be set by _generateTitle() after AI responds
    }

    // Add user message
    final userMsg = MessageModel(text: event.text, isUser: true);
    _messages.add(userMsg);
    emit(state.copyWith(List.unmodifiable(_messages), true,
        currentThreadId: _currentThreadId, userHasInteracted: true));

    // Save user message to Firestore
    if (_currentThreadId != null) {
      await _firestoreService.addMessage(_currentThreadId!, userMsg);
    }

    final messagesToSend = List<Message>.unmodifiable(_messages);

    // Add empty AI placeholder for typing indicator
    _messages.add(MessageModel(text: "", isUser: false));
    emit(state.copyWith(List.unmodifiable(_messages), false,
        currentThreadId: _currentThreadId));

    try {
      String currentAiText = "";

      await for (final chunk in sendChatUsecase.executeStream(messagesToSend)) {
        currentAiText += chunk;
        _messages[_messages.length - 1] = MessageModel(
          text: currentAiText,
          isUser: false,
        );
        emit(state.copyWith(List.unmodifiable(_messages), false,
            currentThreadId: _currentThreadId));
      }

      // Save completed AI message to Firestore
      if (_currentThreadId != null) {
        await _firestoreService.addMessage(_currentThreadId!, _messages.last);
      }

      // ✅ Generate summarized title after first exchange
      if (isFirstMessage && _currentThreadId != null) {
        _generateTitle(event.text);
      }
    } catch (e) {
      _messages.removeLast();
      _messages.add(
        MessageModel(text: "Error: Could not fetch response.", isUser: false),
      );
      emit(state.copyWith(List.unmodifiable(_messages), false,
          currentThreadId: _currentThreadId));
    }
  }

  /// Generate a short AI summary title for the thread
  void _generateTitle(String userMessage) async {
    if (_currentThreadId == null) return;
    try {
      final titleMessages = [
        MessageModel(
          text:
              'Summarize this user message into a short title (3-5 words max, no quotes, no punctuation at end): "$userMessage"',
          isUser: true,
        ),
      ];
      String title = '';
      await for (final chunk in sendChatUsecase.executeStream(titleMessages)) {
        title += chunk;
      }
      title = title.trim();
      if (title.length > 50) title = '${title.substring(0, 50)}...';
      if (title.isNotEmpty) {
        await _firestoreService.updateThreadTitle(_currentThreadId!, title);
      }
    } catch (e) {
      log('Title generation failed: $e');
      // Fallback: truncate the raw user message
      final fallback = userMessage.length > 35
          ? '${userMessage.substring(0, 35)}...'
          : userMessage;
      try {
        await _firestoreService.updateThreadTitle(_currentThreadId!, fallback);
      } catch (_) {}
    }
  }

  Future<void> _onRegenerate(
      RegenerateResponseEvent event, Emitter<ChatState> emit) async {
    if (_messages.isEmpty) return;

    if (!_messages.last.isUser) {
      _messages.removeLast();
      if (_currentThreadId != null) {
        await _firestoreService.removeLastAiMessage(_currentThreadId!);
      }
    }

    if (_messages.isEmpty) return;

    final messagesToSend = List<Message>.unmodifiable(_messages);

    _messages.add(MessageModel(text: "", isUser: false));
    emit(state.copyWith(List.unmodifiable(_messages), false,
        currentThreadId: _currentThreadId));

    try {
      String currentAiText = "";

      await for (final chunk in sendChatUsecase.executeStream(messagesToSend)) {
        currentAiText += chunk;
        _messages[_messages.length - 1] = MessageModel(
          text: currentAiText,
          isUser: false,
        );
        emit(state.copyWith(List.unmodifiable(_messages), false,
            currentThreadId: _currentThreadId));
      }

      if (_currentThreadId != null) {
        await _firestoreService.addMessage(_currentThreadId!, _messages.last);
      }
    } catch (e) {
      _messages.removeLast();
      _messages.add(
        MessageModel(text: "Error: Could not fetch response.", isUser: false),
      );
      emit(state.copyWith(List.unmodifiable(_messages), false,
          currentThreadId: _currentThreadId));
    }
  }

  @override
  Future<void> close() {
    _threadsSub?.cancel();
    return super.close();
  }
}