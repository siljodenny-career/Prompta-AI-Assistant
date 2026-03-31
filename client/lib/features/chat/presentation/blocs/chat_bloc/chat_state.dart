part of 'chat_bloc.dart';

final class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final String? currentThreadId;
  final List<ChatThread> threads;
  final bool? _userHasInteracted;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.currentThreadId,
    this.threads = const [],
    bool? userHasInteracted,
  }) : _userHasInteracted = userHasInteracted;

  bool get userHasInteracted => _userHasInteracted ?? false;

  ChatState copyWith(
    List<Message> messages,
    bool isLoading, {
    String? currentThreadId,
    List<ChatThread>? threads,
    bool? userHasInteracted,
  }) {
    return ChatState(
      messages: messages,
      isLoading: isLoading,
      currentThreadId: currentThreadId ?? this.currentThreadId,
      threads: threads ?? this.threads,
      userHasInteracted: userHasInteracted ?? _userHasInteracted,
    );
  }
}
