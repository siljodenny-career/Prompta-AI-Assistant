import 'package:client/features/auth/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TypewriterHeadline extends StatefulWidget {
  const TypewriterHeadline({super.key});

  @override
  State<TypewriterHeadline> createState() => _TypewriterHeadlineState();
}

class _TypewriterHeadlineState extends State<TypewriterHeadline>
    with SingleTickerProviderStateMixin {
  static const _lines = [
    'What if your\nprompts never\nfade away?',
    'Every great idea\nstarts with the\nright words.',
    'Your prompts.\nPerfected.\nForever.',
  ];

  int _lineIdx = 0;
  int _charIdx = 0;
  bool _deleting = false;
  String _displayed = '';

  late AnimationController _cursorCtrl;

  @override
  void initState() {
    super.initState();
    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
    _tick();
  }

  void _tick() async {
    if (!mounted) return;
    final full = _lines[_lineIdx];

    if (!_deleting) {
      if (_charIdx < full.length) {
        await Future.delayed(const Duration(milliseconds: 48));
        if (!mounted) return;
        setState(() {
          _charIdx++;
          _displayed = full.substring(0, _charIdx);
        });
        _tick();
      } else {
        await Future.delayed(const Duration(milliseconds: 2200));
        if (!mounted) return;
        setState(() => _deleting = true);
        _tick();
      }
    } else {
      if (_charIdx > 0) {
        await Future.delayed(const Duration(milliseconds: 28));
        if (!mounted) return;
        setState(() {
          _charIdx--;
          _displayed = full.substring(0, _charIdx);
        });
        _tick();
      } else {
        setState(() {
          _deleting = false;
          _lineIdx = (_lineIdx + 1) % _lines.length;
        });
        _tick();
      }
    }
  }

  @override
  void dispose() {
    _cursorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            _displayed,
            style: GoogleFonts.raleway(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.18,
              letterSpacing: -0.8,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _cursorCtrl,
          builder: (_, _) => Opacity(
            opacity: _cursorCtrl.value,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                width: 3,
                height: 34,
                decoration: BoxDecoration(
                  color: PromptaWelcomeTheme.accent,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: PromptaWelcomeTheme.accent.withValues(alpha: 0.7),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}