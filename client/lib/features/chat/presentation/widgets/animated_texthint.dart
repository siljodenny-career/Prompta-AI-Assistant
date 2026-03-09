import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

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
            speed: Duration(milliseconds: 120),
          ),
          TypewriterAnimatedText(
            'Start a conversation...',
            speed: Duration(milliseconds: 120),
          ),
          TypewriterAnimatedText(
            'Hello! How can I help you?',
            speed: Duration(milliseconds: 120),
          ),
        ],
      ),
    );
  }
}
