part of 'chat_bloc.dart';

final class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final String? currentThreadId;
  final List<ChatThread> threads;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.currentThreadId,
    this.threads = const [],
  });

  ChatState copyWith(
    List<Message> messages,
    bool isLoading, {
    String? currentThreadId,
    List<ChatThread>? threads,
  }) {
    return ChatState(
      messages: messages,
      isLoading: isLoading,
      currentThreadId: currentThreadId ?? this.currentThreadId,
      threads: threads ?? this.threads,
    );
  }
}
