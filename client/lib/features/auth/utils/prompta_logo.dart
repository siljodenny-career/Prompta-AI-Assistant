import 'package:client/features/auth/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PromptaLogo extends StatelessWidget {
  final double size;
  const PromptaLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: PromptaWelcomeTheme.surface,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: PromptaWelcomeTheme.accent.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: PromptaWelcomeTheme.accent.withValues(alpha: 0.28),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: PromptaWelcomeTheme.accent.withValues(alpha: 0.10),
            blurRadius: 48,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/images/prompt_icon.svg',
          width: 40,
        ),
      ),
    );
  }
}