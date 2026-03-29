import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:client/features/chat/domain/entities/message.dart';

abstract class ChatRemoteDatasource {
  Stream<String> fetchApiResponse(List<Message> messages);
}

class ChatRemoteDatasourceImpl extends ChatRemoteDatasource {
  // Local dev: 'http://localhost:5000'
  // Android Emulator: 'http://10.0.2.2:5000'
  final String baseUrl = 'https://prompta-ai-assistant.onrender.com';

  @override
  Stream<String> fetchApiResponse(List<Message> chatHistory) async* {
    final url = Uri.parse('$baseUrl/api/chat/stream');

    try {
      final request = http.Request('POST', url)
        ..headers.addAll({'Content-Type': 'application/json'})
        ..body = jsonEncode({
          'messages': chatHistory.map((message) => {
            'role': message.isUser ? 'user' : 'assistant',
            'content': message.text
          }).toList()
        });

      final response = await request.send().timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        // Read the stream byte-by-byte as it arrives
        final stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());

        await for (final line in stream) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6).trim();

            if (jsonStr == '[DONE]') {
              return;
            }

            try {
              // Now that we stream block by block, we must safely attempt to decode the JSON chunk
              // if OpenRouter returns it encoded that way, or just yield the raw string
              final decoded = jsonStr.replaceAll('"', ''); // Simple unquote cleanup
              if (decoded.isNotEmpty) {
                 yield decoded.replaceAll(r'\n', '\n'); // Restore any newlines
              }
            } catch (e) {
              // Ignore malformed chunks
            }
          }
        }
      } else {
         final errorResponse = await response.stream.bytesToString();
         throw Exception('API Error: ${response.statusCode}\n$errorResponse');
      }
    } catch (e) {
      throw Exception('Network Request Failed: $e');
    }
  }
}
