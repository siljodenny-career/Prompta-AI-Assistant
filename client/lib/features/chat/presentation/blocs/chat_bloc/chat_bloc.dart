import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:client/features/chat/data/datasources/models/message_model.dart';
import 'package:client/features/chat/domain/entities/message.dart';
import 'package:client/features/chat/domain/usecases/send_chat_usecase.dart';

import 'package:meta/meta.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendChatUsecase sendChatUsecase;

  ChatBloc({required this.sendChatUsecase}) : super(ChatState()) {
    on<SendChatEvent>(_onSendChat);
  }

  Future<void> _onSendChat(SendChatEvent event, Emitter<ChatState> emit) async {
    if (event.text.trim().isEmpty) return;

    // 1. Add User's typed message to state instantly
    final userMessages = List<Message>.from(state.messages)
      ..add(MessageModel(text: event.text, isUser: true));

    // Emit new state: show loading and update messages
    emit(state.copyWith(userMessages, true));

    try {
      // 2. We start with an empty AI message to hold the incoming stream
      String currentAiText = "";
      state.messages.add(MessageModel(text: currentAiText, isUser: false));
      emit(state.copyWith(state.messages, false));

      // 3. Listen to the Clean Architecture UseCase Stream (pass the full chat history!)
      await for (final chunk in sendChatUsecase.executeStream(userMessages)) {
        currentAiText += chunk;

        // Update the very last message in the list with the new appended text
        final updatedMessages = List<Message>.from(state.messages);
        updatedMessages[updatedMessages.length -
            1] = (updatedMessages.last as MessageModel).copyWith(
          text: currentAiText,
        );

        // Emit new state: UI rebuilds with the new word!
        emit(state.copyWith(updatedMessages, false));
      }
    } catch (e) {
      final errorMessages = List<Message>.from(state.messages)
        ..add(
          MessageModel(
            text: "Error: Could not fetch response\n$e",
            isUser: false,
          ),
        ); // Output error to UI

      emit(state.copyWith(errorMessages, false));
    }
  }
}
