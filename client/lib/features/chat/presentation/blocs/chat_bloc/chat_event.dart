part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

class SendChatEvent extends ChatEvent {
  final String text;
  SendChatEvent(this.text);
}

class RegenerateResponseEvent extends ChatEvent {}

class NewChatEvent extends ChatEvent {}

class LoadThreadEvent extends ChatEvent {
  final String threadId;
  LoadThreadEvent(this.threadId);
}

class DeleteThreadEvent extends ChatEvent {
  final String threadId;
  DeleteThreadEvent(this.threadId);
}

class SetUserIdEvent extends ChatEvent {
  final String userId;
  SetUserIdEvent(this.userId);
}

class _ThreadsUpdatedEvent extends ChatEvent {
  final List<ChatThread> threads;
  _ThreadsUpdatedEvent(this.threads);
}

class _MessagesLoadedEvent extends ChatEvent {
  final List<Message> messages;
  _MessagesLoadedEvent(this.messages);
}
