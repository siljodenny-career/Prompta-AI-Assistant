import 'package:client/core/components/custom_button.dart';
import 'package:client/core/components/screen_config.dart';
import 'package:client/core/theme/theme_cubit.dart';
import 'package:client/features/auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:client/features/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:client/features/chat/presentation/blocs/chat_bloc/chat_bloc.dart';
import 'package:client/features/chat/presentation/widgets/message_bubble.dart';
import 'package:client/features/chat/presentation/widgets/chat_background.dart';
import 'package:client/features/chat/presentation/widgets/prompt_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:user_repository/user_repository.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state.status == AuthenticationStatus.unauthenticated) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: SafeArea(
          child: Scaffold(
            drawer: _sidebarmenu(isDark),
            appBar: _appBar(isDark),
            body: ChatBackground(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                },
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: ScreenConfig.screenWidth,
                      height: ScreenConfig.screenHeight,
                      child: Column(
                        children: [
                          Expanded(
                            child: state.messages.isNotEmpty
                                ? ListView.builder(
                                    controller: _scrollController,
                                    itemCount: state.messages.length,
                                    itemBuilder: (context, index) {
                                      final isLast =
                                          index == state.messages.length - 1;
                                      return MessageBubble(
                                        message: state.messages[index],
                                        isLast: isLast,
                                        onRegenerate: isLast &&
                                                !state.messages[index].isUser &&
                                                !state.isLoading
                                            ? () {
                                                context
                                                    .read<ChatBloc>()
                                                    .add(RegenerateResponseEvent());
                                              }
                                            : null,
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
                                          width:
                                              ScreenConfig.screenWidth * 0.2,
                                          repeat: true,
                                          animate: true,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Start with your first prompt",
                                            style: GoogleFonts.raleway(
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black87,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Ask anything, generate ideas, or explore with AI",
                                            style: GoogleFonts.raleway(
                                              color: isDark
                                                  ? Colors.white38
                                                  : Colors.black54,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                          SizedBox(height: 12),
                          PromptInputField(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _userTile(String name, String initials) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF5137E6),
            child: Text(
              initials,
              style: GoogleFonts.raleway(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.raleway(
                fontSize: 16,
                color: Colors.white38,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    final first = parts[0][0].toUpperCase();
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '$first${parts[1][0].toUpperCase()}';
    }
    return first;
  }

  //SidebarMenu widget
  Widget _sidebarmenu(bool isDark) {
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
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.all_inclusive_rounded),
                    ),
                    const Spacer(),
                    BlocBuilder<ThemeCubit, ThemeMode>(
                      builder: (context, mode) {
                        final isDarkMode = mode == ThemeMode.dark;
                        return GestureDetector(
                          onTap: () =>
                              context.read<ThemeCubit>().toggleTheme(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: 48,
                            height: 26,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: isDarkMode
                                  ? Colors.white.withAlpha(25)
                                  : Colors.black.withAlpha(25),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              alignment: isDarkMode
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDarkMode
                                      ? const Color(0xFF5137E6)
                                      : const Color(0xFFFFB300),
                                ),
                                child: Icon(
                                  isDarkMode
                                      ? Icons.dark_mode_rounded
                                      : Icons.light_mode_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Prompta",
                      style: GoogleFonts.raleway(fontSize: 24),
                    ),
                    Text(
                      "AI powered assistant ",
                      style: GoogleFonts.raleway(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Search bar section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
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
                    child: _hasClicked
                        ? Container(
                            height: 34,
                            child: TextField(
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: "Search",
                                hintStyle:
                                    GoogleFonts.raleway(fontSize: 14),
                                prefixIcon:
                                    Icon(Icons.search, size: 18),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 0),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white12
                                    : Colors.black.withAlpha(13),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _hasClicked = !_hasClicked;
                    });
                  },
                  icon: Icon(Icons.search_rounded, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1),
          // New Chat button
          ListTile(
            leading: Icon(Icons.add_comment_rounded),
            title: Text("New Chat",
                style: GoogleFonts.raleway(fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              context.read<ChatBloc>().add(NewChatEvent());
            },
          ),
          Divider(height: 1),
          // Chat History from Firestore
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state.threads.isEmpty) {
                  return Center(
                    child: Text(
                      "No chat history yet",
                      style: GoogleFonts.raleway(
                        color: isDark ? Colors.white24 : Colors.black26,
                        fontSize: 14,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: state.threads.length,
                  itemBuilder: (context, index) {
                    final thread = state.threads[index];
                    final isActive =
                        thread.id == state.currentThreadId;
                    return Dismissible(
                      key: Key(thread.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red.withAlpha(51),
                        child: Icon(Icons.delete_outline,
                            color: Colors.red),
                      ),
                      onDismissed: (_) {
                        context
                            .read<ChatBloc>()
                            .add(DeleteThreadEvent(thread.id));
                      },
                      child: ListTile(
                        dense: true,
                        selected: isActive,
                        selectedTileColor: isDark
                            ? Colors.white.withAlpha(13)
                            : Colors.black.withAlpha(13),
                        leading: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: isActive
                              ? const Color(0xFF5137E6)
                              : null,
                        ),
                        title: Text(
                          thread.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.raleway(
                            fontSize: 14,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          _formatDate(thread.updatedAt),
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: isDark
                                ? Colors.white24
                                : Colors.black26,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          context
                              .read<ChatBloc>()
                              .add(LoadThreadEvent(thread.id));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          const SizedBox(height: 8),
          CustomButton(
            text: 'Logout',
            onPressed: () {
              context.read<SignInBloc>().add(SignOutRequired());
            },
            icon: Icons.logout_rounded,
          ),
          Divider(),
          BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              final user = state.user;
              if (user == null) {
                return _userTile('Guest User', 'G');
              }
              final userRepo = context.read<UserRepository>();
              return FutureBuilder<MyUser>(
                future: userRepo.getUserData(user.uid),
                builder: (context, snapshot) {
                  final name = (snapshot.data != null &&
                          snapshot.data!.name.isNotEmpty)
                      ? snapshot.data!.name
                      : user.displayName ?? 'Guest User';
                  final initials = _getInitials(name);
                  return _userTile(name, initials);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  // AppBar Widget
  PreferredSizeWidget _appBar(bool isDark) {
    return AppBar(
      leadingWidth: 60,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/images/prompt_icon.svg",
            width: 40,
          ),
          SizedBox(width: 10),
          Text(
            "Prompta",
            style: GoogleFonts.raleway(),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      scrolledUnderElevation: 0.0,
      actions: const [],
    );
  }
}
