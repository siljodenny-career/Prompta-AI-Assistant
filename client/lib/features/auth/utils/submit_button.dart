import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

class SubmitButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  const SubmitButton({super.key, 
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.955,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _tap() async {
    await _ctrl.forward();
    _ctrl.reverse();
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() => _loading = false);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _tap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: PromptaWelcomeTheme.accent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: PromptaWelcomeTheme.accent.withOpacity(0.38),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _loading
                ? [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF0D0D0D)),
                      ),
                    ),
                  ]
                : [
                    Text(
                      widget.text,
                      style: GoogleFonts.raleway(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0D0D0D),
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(widget.icon, color: const Color(0xFF0D0D0D), size: 18),
                  ],
          ),
        ),
      ),
    );
  }
}