import 'package:client/features/chat/presentation/blocs/chat_bloc/chat_bloc.dart';
import 'package:client/features/chat/presentation/widgets/animated_texthint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class PromptInputField extends StatefulWidget {
  const PromptInputField({super.key});

  @override
  State<PromptInputField> createState() => _PromptInputFieldState();
}

class _PromptInputFieldState extends State<PromptInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      // Dispatch the event to the Bloc
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 20),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                TextField(
                  style: GoogleFonts.raleway(color: Colors.white60),
                  textCapitalization: TextCapitalization.words,
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "",
                    
                    border: InputBorder.none,
                  ),
                ),
                _hasText == false
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 12),
                        child: AnimatedHint(),
                      )
                    : SizedBox(),
                
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: _hasText
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      key: const ValueKey("send"),
                      icon: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.blue,
                        size: 20,
                      ),
                      onPressed: _sendMessage,
                    ),
                  )
                : const SizedBox(width: 40),
          ),
        ],
      ),
    );
  }
}
