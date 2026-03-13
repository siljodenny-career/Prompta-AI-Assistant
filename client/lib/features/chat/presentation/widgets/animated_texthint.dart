import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedHint extends StatelessWidget {
  const AnimatedHint({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey,
      ),
      child: AnimatedTextKit(
        repeatForever: true,
        animatedTexts: [
          TypewriterAnimatedText(
            'Ask anything...',
            textStyle: GoogleFonts.raleway(),
            speed: Duration(milliseconds: 120),
          ),
          TypewriterAnimatedText(
            'Start a conversation...',
            textStyle: GoogleFonts.raleway(),
            speed: Duration(milliseconds: 120),
          ),
          TypewriterAnimatedText(
            'How can I help you?',
            textStyle: GoogleFonts.raleway(),
            speed: Duration(milliseconds: 120),
          ),
        ],
      ),
    );
  }
}
