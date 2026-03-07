part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

class SendChatEvent extends ChatEvent {
  final String text;

  SendChatEvent(this.text);
}
