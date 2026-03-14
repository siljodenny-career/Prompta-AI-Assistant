import 'package:client/features/chat/domain/entities/message.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.white : Colors.white12,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            // The bottom corner next to the "tail" is usually sharp (0 radius)
            bottomLeft: Radius.circular(message.isUser ? 16 : 0),
            bottomRight: Radius.circular(message.isUser ? 0 : 16),
          ),
        ),
        child: message.text.isNotEmpty
            ? Text(
                message.text,
                style: GoogleFonts.raleway(
                  color: message.isUser ? Colors.black : Colors.white,
                  fontSize: 16,
                ),
              )
            : Align(
                alignment: Alignment.centerLeft,
                child: Lottie.asset(
                  "assets/animations/infinity_loading.json",
                  addRepaintBoundary: true,
                  width: 40,
                  repeat: true,
                  animate: true,
                ),
              ),
      ),
    );
  }
}
