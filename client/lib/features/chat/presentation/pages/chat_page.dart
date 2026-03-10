import 'package:client/core/components/screen_config.dart';
import 'package:client/features/chat/presentation/blocs/chat_bloc/chat_bloc.dart';
import 'package:client/features/chat/presentation/widgets/message_bubble.dart';
import 'package:client/features/chat/presentation/widgets/prompt_input_field.dart';
import 'package:client/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

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
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  "Prompta AI",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),

              ListTile(
                leading: Icon(Icons.chat),
                title: Text("New Chat"),
                onTap: () {},
              ),

              ListTile(
                leading: Icon(Icons.history),
                title: Text("Chat History"),
                onTap: () {},
              ),

              ListTile(
                leading: Icon(Icons.settings),
                title: Text("Settings"),
                onTap: () {},
              ),
            ],
          ),
        ),
        appBar: AppBar(
          leadingWidth: 60,
          title: Row(
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcATop),
                child: Lottie.asset(
                  "animations/infinity_loading.json",
                  width: 50,
                  repeat: true,
                  animate: true,
                  frameRate: FrameRate(30),
                ),
              ),
              const Text("Prompta"),
            ],
          ),
          backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
          scrolledUnderElevation:
              0.0, // <-- Prevents the color changing when scrolling
          actions: const [],
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
                      child: state.messages.isNotEmpty
                          ? ListView.builder(
                              controller: _scrollController,
                              itemCount: state.messages.length,
                              itemBuilder: (context, index) {
                                return MessageBubble(
                                  message: state.messages[index],
                                );
                              },
                            )
                          : Stack(
                              alignment: AlignmentGeometry.center,
                              children: [
                                Opacity(
                                  opacity: 0.3,
                                  child: Lottie.asset(
                                    "animations/infinity_loading.json",
                                    width: ScreenConfig.screenWidth * 0.4,
                                    //height: 100,
                                    repeat: true,
                                    animate: true,
                                    frameRate: FrameRate(120),
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Start with your first prompt",
                                        style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 24,
                                        ),
                                      ),
                                      Text(
                                        "Ask anything, generate ideas, or explore with AI",
                                        style: TextStyle(
                                          color: Colors.white30,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
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
