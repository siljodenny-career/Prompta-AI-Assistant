import 'package:client/core/components/screen_config.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/theme_cubit.dart';
import 'package:client/features/auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:client/features/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:client/features/chat/presentation/blocs/chat_bloc/chat_bloc.dart';
import 'package:client/features/chat/presentation/widgets/chat_background.dart';
import 'package:client/features/chat/presentation/widgets/message_bubble.dart';
import 'package:client/features/chat/presentation/widgets/prompt_input_field.dart';
import 'package:client/features/profile/presentation/pages/profile_page.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<PromptInputFieldState> _inputFieldKey = GlobalKey<PromptInputFieldState>();
  String _searchQuery = '';

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
                            child: Stack(
                              children: [
                                // Chat content (messages or empty state)
                                state.messages.isNotEmpty
                                    ? ListView.builder(
                                        controller: _scrollController,
                                        itemCount: state.messages.length,
                                        itemBuilder: (context, index) {
                                          final isLast =
                                              index == state.messages.length - 1;
                                          return MessageBubble(
                                            message: state.messages[index],
                                            isLast: isLast,
                                            onRegenerate:
                                                isLast &&
                                                    !state.messages[index].isUser &&
                                                    !state.isLoading
                                                ? () {
                                                    context.read<ChatBloc>().add(
                                                      RegenerateResponseEvent(),
                                                    );
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
                                              width: ScreenConfig.screenWidth * 0.2,
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
                                                      : AppColors.lightTextPrimary,
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
                                                      : AppColors.lightTextSecondary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                // Floating New Chat button overlay
                                if (!state.userHasInteracted)
                                  Positioned(
                                    bottom: 8,
                                    right: 0,
                                    child: FloatingActionButton.extended(
                                      onPressed: () {
                                        context.read<ChatBloc>().add(NewChatEvent());
                                        Future.delayed(const Duration(milliseconds: 100), () {
                                          _inputFieldKey.currentState?.requestFocus();
                                        });
                                      },
                                      icon: const Icon(Icons.auto_awesome),
                                      label: Text(
                                        'New Chat',
                                        style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
                                      ),
                                      backgroundColor: const Color(0xFF5137E6),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          PromptInputField(key: _inputFieldKey),
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

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
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
      actions: [
        BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            final user = state.user;
            if (user == null) return const SizedBox.shrink();
            final userRepo = context.read<UserRepository>();
            return FutureBuilder<MyUser>(
              future: userRepo.getUserData(user.uid),
              builder: (context, snapshot) {
                final name = (snapshot.data != null &&
                        snapshot.data!.name.isNotEmpty)
                    ? snapshot.data!.name
                    : user.displayName ?? 'U';
                final initials = _getInitials(name);
                return _AvatarChip(
                  name: name,
                  initials: initials,
                );
              },
            );
          },
        ),
      ],
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

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    final first = parts[0][0].toUpperCase();
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '$first${parts[1][0].toUpperCase()}';
    }
    return first;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  //SidebarMenu widget
  Widget _sidebarmenu(bool isDark) {
    return Drawer(
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: logo + theme toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
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
                  ),
                  const SizedBox(height: 4),
                  // Prompta title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Prompta",
                          style: GoogleFonts.raleway(fontSize: 22),
                        ),
                        Text(
                          "AI powered assistant",
                          style: GoogleFonts.raleway(
                            color: isDark ? Colors.white38 : AppColors.lightTextTertiary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // Search bar section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 34,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value.trim().toLowerCase());
                },
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Search chats...",
                  hintStyle: GoogleFonts.raleway(fontSize: 14),
                  prefixIcon: Icon(Icons.search, size: 18),
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white12
                      : AppColors.lightInputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1),
          // New Chat button
          ListTile(
            leading: Icon(Icons.auto_awesome),
            title: Text("New Chat", style: GoogleFonts.raleway(fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              context.read<ChatBloc>().add(NewChatEvent());
              // Focus the textfield after a short delay to allow drawer to close
              Future.delayed(const Duration(milliseconds: 100), () {
                _inputFieldKey.currentState?.requestFocus();
              });
            },
          ),
          Divider(height: 1),
          // Chat History from Firestore
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                final filtered = _searchQuery.isEmpty
                    ? state.threads
                    : state.threads
                        .where((t) =>
                            t.title.toLowerCase().contains(_searchQuery))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? "No chat history yet"
                          : "No results found",
                      style: GoogleFonts.raleway(
                        color: isDark ? Colors.white24 : AppColors.lightTextTertiary,
                        fontSize: 14,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final thread = filtered[index];
                    final isActive = thread.id == state.currentThreadId;
                    return Dismissible(
                      key: Key(thread.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red.withAlpha(51),
                        child: Icon(Icons.delete_outline, color: Colors.red),
                      ),
                      onDismissed: (_) {
                        context.read<ChatBloc>().add(
                          DeleteThreadEvent(thread.id),
                        );
                      },
                      child: ListTile(
                        dense: true,
                        selected: isActive,
                        selectedTileColor: isDark
                            ? Colors.white.withAlpha(13)
                            : AppColors.lightCard,
                        leading: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: isActive ? const Color(0xFF5137E6) : null,
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
                            color: isDark ? Colors.white24 : AppColors.lightTextTertiary,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          context.read<ChatBloc>().add(
                            LoadThreadEvent(thread.id),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              final user = state.user;
              if (user == null) {
                return _userTileCompact('Guest User', 'G', null);
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
                  final imageUrl = snapshot.data?.profileImageUrl;
                  return _userTileCompact(name, initials, imageUrl);
                },
              );
            },
          ),
          // Profile button
          BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              final user = state.user;
              if (user == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: 36,
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfilePage(userId: user.uid),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.person_outline_rounded,
                      size: 18,
                      color: isDark ? Colors.white54 : AppColors.lightTextSecondary,
                    ),
                    label: Text(
                      'Edit Profile',
                      style: GoogleFonts.raleway(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 14),
            child: SizedBox(
              height: 36,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<SignInBloc>().add(SignOutRequired());
                },
                icon: Icon(Icons.logout_rounded, color: Colors.red[400]),
                label: Text(
                  'Logout',
                  style: GoogleFonts.raleway(color: Colors.red[400],fontWeight: FontWeight.w700,fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade400, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _userTileCompact(String name, String initials, String? imageUrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF5137E6),
            backgroundImage:
                imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null
                ? Text(
                    initials,
                    style: GoogleFonts.raleway(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: isDark ? Colors.white54 : AppColors.lightTextSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarChip extends StatefulWidget {
  final String name;
  final String initials;
  const _AvatarChip({required this.name, required this.initials});

  @override
  State<_AvatarChip> createState() => _AvatarChipState();
}

class _AvatarChipState extends State<_AvatarChip> {
  bool _expanded = false;

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _expanded) {
          setState(() => _expanded = false);
        }
      });
    }
  }

  void _openProfile(BuildContext context) {
    final authState = context.read<AuthenticationBloc>().state;
    final user = authState.user;
    if (user == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(userId: user.uid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: _toggle,
        onLongPress: () => _openProfile(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 32,
          padding: EdgeInsets.only(
            left: 0,
            right: _expanded ? 12 : 0,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF5137E6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF5137E6),
                child: Text(
                  widget.initials,
                  style: GoogleFonts.raleway(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _expanded
                    ? Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          widget.name,
                          style: GoogleFonts.raleway(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
