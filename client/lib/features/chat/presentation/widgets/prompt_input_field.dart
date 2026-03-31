import 'package:client/features/chat/presentation/blocs/chat_bloc/chat_bloc.dart';
import 'package:client/features/chat/presentation/widgets/animated_texthint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class PromptInputField extends StatefulWidget {
  final GlobalKey<PromptInputFieldState>? fieldKey;
  
  const PromptInputField({super.key, this.fieldKey});

  @override
  State<PromptInputField> createState() => PromptInputFieldState();

  static PromptInputFieldState? of(BuildContext context) {
    return context.findAncestorStateOfType<PromptInputFieldState>();
  }
}

class PromptInputFieldState extends State<PromptInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  bool _wasLoading = false;

  void requestFocus() {
    _focusNode.requestFocus();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      HapticFeedback.lightImpact();
      context.read<ChatBloc>().add(SendChatEvent(_controller.text));
      _controller.clear();
      setState(() {
        _hasText = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          _wasLoading && !current.isLoading,
      listener: (context, state) {
        _focusNode.requestFocus();
      },
      child: BlocListener<ChatBloc, ChatState>(
        listenWhen: (previous, current) =>
            previous.isLoading != current.isLoading,
        listener: (context, state) {
          _wasLoading = state.isLoading;
        },
        child: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 20),
      padding: const EdgeInsets.fromLTRB(25, 0, 6, 0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(40),
        border: isDark
            ? null
            : Border.all(color: Colors.black.withAlpha(30), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                _hasText == false
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2.0,
                          vertical: 14,
                        ),
                        child: AnimatedHint(),
                      )
                    : SizedBox(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: TextField(
                    focusNode: _focusNode,
                    style: GoogleFonts.raleway(
                      color: isDark ? Colors.white60 : Colors.black87,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    minLines: 1,
                    maxLines: 5,
                    autocorrect: true,
                    cursorColor: Colors.blue,
                    cursorHeight: 20,
                    decoration: const InputDecoration(
                      hintText: "",
                      alignLabelWithHint: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: _hasText
                ? Container(
                    width: 36,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      key: const ValueKey("send"),
                      icon: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.blue,
                        size: 18,
                      ),
                      onPressed: _sendMessage,
                    ),
                  )
                : const SizedBox(width: 2),
          ),
        ],
      ),
    );
          },
        ),
    ),
    );
  }
}
