import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:client/features/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:client/features/chat/presentation/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      icon: Icons.auto_awesome,
      title: 'AI-Powered Conversations',
      description: 'Experience intelligent conversations with our advanced AI assistant. Get instant answers and creative solutions.',
      gradient: [Color(0xFF667eea), Color(0xFF764ba2)],
    ),
    _OnboardingSlide(
      icon: Icons.chat_bubble_outline,
      title: 'Organized Threads',
      description: 'Keep your conversations neatly organized. Switch between multiple chat threads seamlessly.',
      gradient: [Color(0xFFf093fb), Color(0xFFf5576c)],
    ),
    _OnboardingSlide(
      icon: Icons.sync_alt,
      title: 'Sync Everywhere',
      description: 'Your chats follow you across all devices. Start on one, continue on another.',
      gradient: [Color(0xFF4facfe), Color(0xFF00f2fe)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToChat() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => SignInBloc(
            userRepository: context.read<AuthenticationBloc>().userRepository,
          ),
          child: const ChatPage(),
        ),
      ),
    );
  }

  void _onNextPressed() {
    if (_currentPage == _slides.length - 1) {
      _navigateToChat();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D0D0D) : Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // Skip button - top right
              Positioned(
                top: 8,
                right: 8,
                child: TextButton(
                  onPressed: _navigateToChat,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.raleway(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                  ),
                ),
              ),

              // Main content
              Column(
                children: [
                  const SizedBox(height: 60),

                  // PageView
                  Expanded(
                    flex: 3,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      onPageChanged: (index) => setState(() => _currentPage = index),
                      itemBuilder: (context, index) {
                        return _buildSlide(_slides[index], isDark);
                      },
                    ),
                  ),

                  // Bottom controls
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Page indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _slides.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPage == index ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: _currentPage == index
                                      ? AppColors.primaryPurple
                                      : (isDark ? Colors.white24 : Colors.black12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Next / Get Started button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _onNextPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryPurple,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                                    style: GoogleFonts.raleway(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _currentPage == _slides.length - 1
                                        ? Icons.check_rounded
                                        : Icons.arrow_forward_rounded,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(_OnboardingSlide slide, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon container
          _AnimatedIconContainer(
            icon: slide.icon,
            gradient: slide.gradient,
          ).animate().scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1, 1),
            duration: 600.ms,
            curve: Curves.easeOutBack,
          ).fadeIn(duration: 400.ms),

          const SizedBox(height: 48),

          // Title
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.raleway(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              height: 1.3,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(
            begin: 0.2,
            end: 0,
            duration: 500.ms,
            curve: Curves.easeOutCubic,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.raleway(
              fontSize: 15,
              color: isDark ? Colors.white60 : Colors.black54,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 350.ms, duration: 500.ms).slideY(
            begin: 0.2,
            end: 0,
            duration: 500.ms,
            curve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}

class _AnimatedIconContainer extends StatefulWidget {
  final IconData icon;
  final List<Color> gradient;

  const _AnimatedIconContainer({
    required this.icon,
    required this.gradient,
  });

  @override
  State<_AnimatedIconContainer> createState() => _AnimatedIconContainerState();
}

class _AnimatedIconContainerState extends State<_AnimatedIconContainer>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatController.value * -10),
          child: child,
        );
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.gradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.gradient[0].withAlpha(100 + (_pulseController.value * 50).toInt()),
                  blurRadius: 30 + (_pulseController.value * 20),
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              size: 72,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
