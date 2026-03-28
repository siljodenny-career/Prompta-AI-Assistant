import 'package:client/core/components/custom_button.dart';
import 'package:client/core/components/screen_config.dart';
import 'package:client/features/auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:client/features/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:client/features/chat/presentation/blocs/chat_bloc/chat_bloc.dart';
import 'package:client/features/chat/presentation/widgets/message_bubble.dart';
import 'package:client/features/chat/presentation/widgets/prompt_input_field.dart';
import 'package:client/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  bool _hasClicked = false;

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
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.status == AuthenticationStatus.unauthenticated) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: SafeArea(
        child: Scaffold(
          drawer: _sidebarmenu(),
          appBar: _appBar(),
          body: BlocConsumer<ChatBloc, ChatState>(
            listener: (context, state) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            },
            builder: (context, state) {
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
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Opacity(
                                  opacity: 0.3,
                                  child: Lottie.asset(
                                    "assets/animations/infinity_loading.json",
                                    width: ScreenConfig.screenWidth * 0.2,
                                    //height: 100,
                                    repeat: true,
                                    animate: true,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Start with your first prompt",
                                      style: GoogleFonts.raleway(
                                        color: Colors.white60,
                                        fontSize: 20,
                                      ),
                                    ),

                                    Text(
                                      "Ask anything, generate ideas, or explore with AI",
                                      style: GoogleFonts.raleway(
                                        color: Colors.white30,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
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
      ),
    );
  }

  //SidebarMenu widget

  Widget _sidebarmenu() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.all_inclusive_rounded),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SizeTransition(
                              sizeFactor: animation,
                              axis: Axis.horizontal,
                              axisAlignment: -1,
                              child: child,
                            ),
                          );
                        },
                        child: _hasClicked == true
                            ? Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                height: 30,
                                child: TextField(
                                  style: TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: "Search",
                                    hintStyle: GoogleFonts.raleway(
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: 18,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 0,
                                    ),

                                    filled: true,
                                    fillColor: Colors.white12,

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        20,
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _hasClicked = !_hasClicked;
                        });
                      },
                      icon: Icon(Icons.search_rounded),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.edit_square),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Prompta",
                      style: GoogleFonts.raleway(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      "AI powered assistant ",
                      style: GoogleFonts.raleway(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.chat_bubble_rounded),
                  title: Text(
                    "New Chat",
                    style: GoogleFonts.raleway(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                ListTile(
                  leading: Icon(Icons.history),
                  title: Text(
                    "Chat History",
                    style: GoogleFonts.raleway(fontSize: 16),
                  ),
                  onTap: () {},
                ),

                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text(
                    "Settings",
                    style: GoogleFonts.raleway(fontSize: 16),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          Spacer(),
          CustomButton(
            text: 'Logout',
            onPressed: () {
              context.read<SignInBloc>().add(SignOutRequired());
            },
            icon: Icons.logout_rounded,
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black,
                  child: Center(child: Text("GU")),
                ),
                SizedBox(width: 10),
                Text(
                  "Guest User",
                  style: GoogleFonts.raleway(
                    fontSize: 16,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // AppBar Widget

  PreferredSizeWidget _appBar() {
    return AppBar(
      leadingWidth: 60,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/images/prompt_icon.svg",
            width: 40,
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            "Prompta",
            style: GoogleFonts.raleway(),
          ),
        ],
      ),
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      scrolledUnderElevation:
          0.0, // <-- Prevents the color changing when scrolling
      actions: const [],
    );
  }
}
