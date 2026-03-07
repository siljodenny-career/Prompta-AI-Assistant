import 'package:client/features/chat/domain/entities/message.dart';
import 'package:client/features/chat/domain/repositories/chat_repository.dart';

class SendChatUsecase {
  final ChatRepository repository;

  SendChatUsecase(this.repository);

  Stream<String> executeStream(List<Message> messages) {
    return repository.sendChatStream(messages);
  }
}
