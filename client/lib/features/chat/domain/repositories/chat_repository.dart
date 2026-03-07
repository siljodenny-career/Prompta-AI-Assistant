import 'package:client/features/chat/domain/entities/message.dart';

abstract class ChatRepository {
  // Abstraction for sending a chat history and getting a stream of chunks back
  Stream<String> sendChatStream(List<Message> messages);
}
