import 'package:client/core/components/screen_config.dart';
import 'package:client/features/chat/presentation/blocs/chat_bloc/chat_bloc.dart';
import 'package:client/features/chat/presentation/widgets/message_bubble.dart';
import 'package:client/features/chat/presentation/widgets/prompt_input_field.dart';
import 'package:client/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Prompta"),
          backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
          scrolledUnderElevation:
              0.0, // <-- Prevents the color changing when scrolling
          actions: const [],
          leading: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              print('menu clicked');
            },
            child: const Icon(Icons.menu),
          ),
        ),
        body: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            // By calling this post-frame, we guarantee the ListView has already painted
            // the newest text chunk layout before attempting to scroll to the newest bottom
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: ScreenConfig.screenWidth,
                height: ScreenConfig.screenHeight,
                decoration: BoxDecoration(
                  //color: Colors.amber,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          return MessageBubble(
                            message: state.messages[index],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 12,),
                    PromptInputField(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
