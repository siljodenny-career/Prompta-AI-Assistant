import 'package:client/features/chat/domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({required super.text, required super.isUser});

  /// Since your API data is already in the form of a string
  /// We simply pass the string in here to create our Dart Object!
  factory MessageModel.fromString(String apiResponse, {bool isUser = false}) {
    return MessageModel(text: apiResponse, isUser: isUser);
  }

  MessageModel copyWith({
    String? text,
    bool? isUser,
  }) {
    return MessageModel(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
    );
  }
}
