import 'package:client/features/chat/domain/entities/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/highlight.dart' show highlight;
import 'package:lottie/lottie.dart';
import 'package:markdown/markdown.dart' as md;

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isLast;
  final VoidCallback? onRegenerate;

  const MessageBubble({
    super.key,
    required this.message,
    this.isLast = false,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: message.text));
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Copied to clipboard'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 0),
              bottomRight: Radius.circular(isUser ? 0 : 16),
            ),
          ),
          child: message.text.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isUser
                        ? Text(
                            message.text,
                            style: GoogleFonts.raleway(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          )
                        : MarkdownBody(
                            data: message.text,
                            selectable: true,
                            extensionSet: md.ExtensionSet(
                              md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                              [
                                md.EmojiSyntax(),
                                ...md.ExtensionSet
                                    .gitHubFlavored.inlineSyntaxes,
                              ],
                            ),
                            styleSheet: MarkdownStyleSheet(
                              p: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.5,
                              ),
                              h1: GoogleFonts.raleway(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              h2: GoogleFonts.raleway(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              h3: GoogleFonts.raleway(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              strong: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              em: GoogleFonts.dmSans(
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                              code: GoogleFonts.firaCode(
                                color: const Color(0xFFE06C75),
                                backgroundColor: Colors.white10,
                                fontSize: 13,
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              codeblockPadding: const EdgeInsets.all(12),
                              listBullet: GoogleFonts.dmSans(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                              blockquoteDecoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: const Color(0xFF5137E6),
                                    width: 3,
                                  ),
                                ),
                              ),
                              blockquotePadding: const EdgeInsets.only(
                                left: 12,
                                top: 4,
                                bottom: 4,
                              ),
                              tableBorder: TableBorder.all(
                                color: Colors.white24,
                                width: 1,
                              ),
                              tableHead: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              tableBody: GoogleFonts.dmSans(
                                color: Colors.white70,
                              ),
                            ),
                            builders: {
                              'code': _CodeBlockBuilder(),
                            },
                          ),
                    if (!isUser && isLast && onRegenerate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          onTap: onRegenerate,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 16,
                                color: Colors.white38,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Regenerate',
                                style: GoogleFonts.raleway(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
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
      ),
    );
  }
}

/// Typing indicator with three bouncing dots
class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _animations = _controllers.map((ctrl) {
      return Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      for (int i = 0; i < 3; i++) {
        if (!mounted) return;
        _controllers[i].forward();
        await Future.delayed(const Duration(milliseconds: 120));
      }
      await Future.delayed(const Duration(milliseconds: 100));
      for (int i = 0; i < 3; i++) {
        if (!mounted) return;
        _controllers[i].reverse();
      }
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _animations[i].value),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white38,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Custom code block builder with copy button and syntax highlighting
class _CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    if (element.tag != 'code') return null;

    final String code = element.textContent.trimRight();
    final parent = element.attributes['class'];
    final String? language = parent?.replaceFirst('language-', '');

    // Only style as block if it has a language class or contains newlines
    final isBlock =
        element.attributes.containsKey('class') || code.contains('\n');
    if (!isBlock) return null;

    List<TextSpan> spans;
    try {
      final result = highlight.parse(code, language: language);
      spans = _convertNodes(result.nodes!);
    } catch (_) {
      spans = [TextSpan(text: code)];
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language ?? 'code',
                  style: GoogleFonts.firaCode(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Code copied'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded,
                          size: 14, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: GoogleFonts.dmSans(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: SelectableText.rich(
              TextSpan(
                style: GoogleFonts.firaCode(
                  color: const Color(0xFFABB2BF),
                  fontSize: 13,
                  height: 1.5,
                ),
                children: spans,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _tokenColors = {
    'keyword': Color(0xFFC678DD),
    'built_in': Color(0xFFE5C07B),
    'type': Color(0xFFE5C07B),
    'literal': Color(0xFFD19A66),
    'number': Color(0xFFD19A66),
    'string': Color(0xFF98C379),
    'symbol': Color(0xFF61AFEF),
    'title': Color(0xFF61AFEF),
    'function': Color(0xFF61AFEF),
    'params': Color(0xFFABB2BF),
    'comment': Color(0xFF5C6370),
    'doctag': Color(0xFF5C6370),
    'attr': Color(0xFFD19A66),
    'attribute': Color(0xFFD19A66),
    'variable': Color(0xFFE06C75),
    'tag': Color(0xFFE06C75),
    'name': Color(0xFFE06C75),
    'selector-tag': Color(0xFFE06C75),
    'deletion': Color(0xFFE06C75),
    'addition': Color(0xFF98C379),
    'meta': Color(0xFF61AFEF),
    'section': Color(0xFF61AFEF),
  };

  static List<TextSpan> _convertNodes(List<dynamic> nodes) {
    final spans = <TextSpan>[];
    for (final node in nodes) {
      if (node.value != null) {
        Color? color;
        if (node.className != null) {
          final cls = node.className as String;
          color = _tokenColors[cls] ?? _tokenColors[cls.split('-').last];
        }
        spans.add(TextSpan(
          text: node.value,
          style: color != null ? TextStyle(color: color) : null,
        ));
      } else if (node.children != null) {
        Color? color;
        if (node.className != null) {
          final cls = node.className as String;
          color = _tokenColors[cls] ?? _tokenColors[cls.split('-').last];
        }
        final childSpans = _convertNodes(node.children);
        if (color != null) {
          spans.add(TextSpan(
            style: TextStyle(color: color),
            children: childSpans,
          ));
        } else {
          spans.addAll(childSpans);
        }
      }
    }
    return spans;
  }
}
