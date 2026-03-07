part of 'chat_bloc.dart';

final class ChatState {
  final List<Message> messages;
  final bool isLoading;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
  });

  // Use copyWith to create a new state object easily
  ChatState copyWith(
    List<Message> messages,
    bool isLoading,
  ) {
    return ChatState(
      messages: messages,
      isLoading: isLoading,
    );
  }
}
