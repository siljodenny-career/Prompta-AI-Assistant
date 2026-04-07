import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PromptaSnackBar {
  PromptaSnackBar._();

  static void error(BuildContext context, String message) =>
      _show(context, message, const Color(0xFFEF4444), Icons.error_outline_rounded);

  static void success(BuildContext context, String message) =>
      _show(context, message, const Color(0xFF22C55E), Icons.check_circle_outline_rounded);

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF181818),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: color.withValues(alpha: 0.4)),
            ),
            content: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.raleway(fontSize: 13, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
  }
}