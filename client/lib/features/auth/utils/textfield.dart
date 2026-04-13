import 'package:client/features/auth/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PromptaField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const PromptaField({super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<PromptaField> createState() => _PromptaFieldState();
}

class _PromptaFieldState extends State<PromptaField> {
  bool _focused = false;
  bool _showPass = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: PromptaWelcomeTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused
              ? PromptaWelcomeTheme.accent.withValues(alpha: 0.65)
              : PromptaWelcomeTheme.border,
          width: 1.2,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: PromptaWelcomeTheme.accent.withValues(alpha: 0.12),
                  blurRadius: 18,
                  spreadRadius: -2,
                ),
              ]
            : [],
      ),
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.obscure && !_showPass,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          validator: widget.validator,
          style: GoogleFonts.dmSans(
            color: PromptaWelcomeTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 17,
            ),
            border: InputBorder.none,
            hintText: widget.label,
            hintStyle: GoogleFonts.dmSans(
              color: PromptaWelcomeTheme.textMuted,
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(
                widget.icon,
                color: _focused ? PromptaWelcomeTheme.accent : PromptaWelcomeTheme.textMuted,
                size: 19,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(),
            suffixIcon: widget.obscure
                ? GestureDetector(
                    onTap: () => setState(() => _showPass = !_showPass),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Icon(
                        _showPass
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: PromptaWelcomeTheme.textMuted,
                        size: 19,
                      ),
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(),
          ),
        ),
      ),
    );
  }
}