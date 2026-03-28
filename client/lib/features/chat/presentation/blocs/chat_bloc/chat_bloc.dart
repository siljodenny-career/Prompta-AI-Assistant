import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:client/features/chat/data/datasources/models/message_model.dart';
import 'package:client/features/chat/domain/entities/message.dart';
import 'package:client/features/chat/domain/usecases/send_chat_usecase.dart';

import 'package:meta/meta.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendChatUsecase sendChatUsecase;
  final List<Message> _messages = [];

  ChatBloc({required this.sendChatUsecase}) : super(ChatState()) {
    on<SendChatEvent>(_onSendChat);
  }

  Future<void> _onSendChat(SendChatEvent event, Emitter<ChatState> emit) async {
    if (event.text.trim().isEmpty) return;

    // 1. Add User's typed message to state instantly
    _messages.add(MessageModel(text: event.text, isUser: true));
    emit(state.copyWith(List.unmodifiable(_messages), true));

    // Snapshot messages to send (before adding empty AI placeholder)
    final messagesToSend = List<Message>.unmodifiable(_messages);

    try {
      // 2. We start with an empty AI message to hold the incoming stream
      String currentAiText = "";
      _messages.add(MessageModel(text: currentAiText, isUser: false));
      emit(state.copyWith(List.unmodifiable(_messages), false));

      // 3. Listen to the Clean Architecture UseCase Stream (pass chat history without empty placeholder)
      await for (final chunk in sendChatUsecase.executeStream(messagesToSend)) {
        currentAiText += chunk;

        // Update the last message in-place, then emit a new list reference
        _messages[_messages.length - 1] = MessageModel(
          text: currentAiText,
          isUser: false,
        );

        emit(state.copyWith(List.unmodifiable(_messages), false));
      }
    } catch (e) {
      _messages.add(
        MessageModel(
          text: "Error: Could not fetch response.",
          isUser: false,
        ),
      );
      emit(state.copyWith(List.unmodifiable(_messages), false));
    }
  }
}
