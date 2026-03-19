import 'package:client/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:client/features/chat/domain/entities/message.dart';
import 'package:client/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl extends ChatRepository {
  final ChatRemoteDatasource remoteDatasource;

  ChatRepositoryImpl(this.remoteDatasource);

  @override
  Stream<String> sendChatStream(List<Message> messages) async* {
    try {
      // 1. Get raw string stream from API Data Source
      final stream = remoteDatasource.fetchApiResponse(messages);
      
      // 2. Yield the chunks as they come in
      await for (final chunk in stream) {
        yield chunk;
      }
    } catch (e) {
      throw Exception('Failed to get AI response :$e');
    }
  }
}
