import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/theme.dart';

class TermsCheckBox extends StatefulWidget {
  const TermsCheckBox({super.key});

  @override
  State<TermsCheckBox> createState() => _TermsCheckBoxState();
}

class _TermsCheckBoxState extends State<TermsCheckBox> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => _agreed = !_agreed),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: _agreed
                  ? PromptaWelcomeTheme.accent
                  : PromptaWelcomeTheme.surface,
              border: Border.all(
                color: _agreed
                    ? PromptaWelcomeTheme.accent
                    : PromptaWelcomeTheme.border,
                width: 1.4,
              ),
              boxShadow: _agreed
                  ? [
                      BoxShadow(
                        color: PromptaWelcomeTheme.accent.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
            child: _agreed
                ? const Icon(Icons.check, size: 13, color: Color(0xFF0D0D0D))
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'I agree to the ',
              style: GoogleFonts.raleway(color: Colors.white60, fontSize: 13),
              children: [
                TextSpan(
                  text: 'Terms of Service',
                  style: GoogleFonts.raleway(
                    color: PromptaWelcomeTheme.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: ' and ',
                  style: GoogleFonts.raleway(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  style: GoogleFonts.raleway(
                    color: PromptaWelcomeTheme.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}