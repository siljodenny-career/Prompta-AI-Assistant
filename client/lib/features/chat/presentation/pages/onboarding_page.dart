import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback? onComplete;
  const OnboardingPage({super.key, this.onComplete});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _navigateToChat() {
    // Call onComplete callback to notify _LoadingTransition to show ChatPage
    // instead of using pushReplacement, so the navigation stack stays intact
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isVerySmallScreen = size.height < 600;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Stack(
            children: [
              // Animated background gradient
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _getGradientColors(isDark),
                    ),
                  ),
                ),
              ),

              // Skip button
              Positioned(
                top: isSmallScreen ? 8 : 16,
                right: isSmallScreen ? 8 : 16,
                child: TextButton(
                  onPressed: _navigateToChat,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 8 : 10,
                    ),
                    backgroundColor: Colors.white.withAlpha(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.white.withAlpha(30)),
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.raleway(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),

              // Main content
              Column(
                children: [
                  SizedBox(height: isVerySmallScreen ? 50 : (isSmallScreen ? 60 : 80)),

                  // PageView with demos
                  Expanded(
                    flex: isVerySmallScreen ? 5 : 4,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: 4,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        return _buildSlide(index, isDark, size, isSmallScreen, isVerySmallScreen);
                      },
                    ),
                  ),

                  // Bottom controls
                  Expanded(
                    flex: isVerySmallScreen ? 2 : 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 24 : 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Page indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              4,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPage == index ? 28 : 8,
                                height: isSmallScreen ? 6 : 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: _currentPage == index
                                      ? Colors.white
                                      : Colors.white30,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 20 : 32),

                          // Next/Get Started button
                          SizedBox(
                            width: double.infinity,
                            height: isSmallScreen ? 48 : 56,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentPage == 3) {
                                  _navigateToChat();
                                } else {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOutCubic,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: _getButtonColor(),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentPage == 3 ? 'Get Started' : 'Next',
                                    style: GoogleFonts.raleway(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      _currentPage == 3
                                          ? Icons.arrow_forward_rounded
                                          : Icons.arrow_forward_ios_rounded,
                                      size: isSmallScreen ? 18 : 20,
                                      key: ValueKey('icon_$_currentPage'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

  List<Color> _getGradientColors(bool isDark) {
    final gradients = [
      // Slide 0: AI Chat - Purple/Blue
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      // Slide 1: Threads - Pink/Orange
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      // Slide 2: Sync - Blue/Cyan
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      // Slide 3: Welcome - Dark elegant
      isDark
          ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
          : [const Color(0xFF2d3436), const Color(0xFF636e72)],
    ];
    return gradients[_currentPage];
  }

  Color _getButtonColor() {
    final colors = [
      const Color(0xFF764ba2),
      const Color(0xFFf5576c),
      const Color(0xFF00f2fe),
      const Color(0xFF2d3436),
    ];
    return colors[_currentPage];
  }

  Widget _buildSlide(int index, bool isDark, Size screenSize, bool isSmallScreen, bool isVerySmallScreen) {
    switch (index) {
      case 0:
        return _buildChatDemoSlide(isDark, screenSize, isSmallScreen, isVerySmallScreen);
      case 1:
        return _buildThreadsDemoSlide(isDark, screenSize, isSmallScreen, isVerySmallScreen);
      case 2:
        return _buildSyncDemoSlide(isDark, screenSize, isSmallScreen, isVerySmallScreen);
      case 3:
        return _buildWelcomeSlide(isDark, screenSize, isSmallScreen, isVerySmallScreen);
      default:
        return const SizedBox.shrink();
    }
  }

  // Slide 1: AI Chat Demo
  Widget _buildChatDemoSlide(bool isDark, Size screenSize, bool isSmallScreen, bool isVerySmallScreen) {
    final mockupWidth = screenSize.width * 0.75;
    final mockupHeight = isVerySmallScreen ? 200 : (isSmallScreen ? 220 : 240);
    final titleSize = isSmallScreen ? 22.0 : 28.0;
    final descSize = isSmallScreen ? 13.0 : 15.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated chat mockup
          Container(
            height: isVerySmallScreen ? 180 : (isSmallScreen ? 200 : 280),
            margin: EdgeInsets.only(bottom: isSmallScreen ? 20 : 40),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glassmorphism card
                Container(
                  width: mockupWidth.clamp(200, 280),
                  height: mockupHeight.toDouble(),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white.withAlpha(15),
                    border: Border.all(color: Colors.white.withAlpha(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),

                // User message
                Positioned(
                  top: isSmallScreen ? 25 : 40,
                  right: isSmallScreen ? 12 : 20,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 8 : 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5137E6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Explain quantum\ncomputing',
                      style: GoogleFonts.raleway(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.5, end: 0),

                // AI typing indicator
                Positioned(
                  top: isSmallScreen ? 70 : 100,
                  left: isSmallScreen ? 12 : 20,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 8 : 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _buildDot(0.ms, isSmallScreen),
                        SizedBox(width: isSmallScreen ? 3 : 4),
                        _buildDot(200.ms, isSmallScreen),
                        SizedBox(width: isSmallScreen ? 3 : 4),
                        _buildDot(400.ms, isSmallScreen),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.5, end: 0),

                // AI response
                Positioned(
                  top: isSmallScreen ? 110 : 150,
                  left: isSmallScreen ? 12 : 20,
                  child: Container(
                    width: mockupWidth.clamp(160, 200) - (isSmallScreen ? 20 : 0),
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Quantum computing leverages quantum mechanics to process information...',
                      style: GoogleFonts.raleway(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 10 : 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 1200.ms).slideX(begin: -0.3, end: 0),
              ],
            ),
          ),

          // Title
          Text(
            'AI-Powered Conversations',
            textAlign: TextAlign.center,
            style: GoogleFonts.raleway(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

          SizedBox(height: isSmallScreen ? 12 : 16),

          // Description
          Text(
            'Experience intelligent conversations with our advanced AI. Get instant answers and creative ideas.',
            textAlign: TextAlign.center,
            style: GoogleFonts.raleway(
              fontSize: descSize,
              color: Colors.white70,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildDot(Duration delay, bool isSmallScreen) {
    return Container(
      width: isSmallScreen ? 6 : 8,
      height: isSmallScreen ? 6 : 8,
      decoration: const BoxDecoration(
        color: Colors.white70,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 600.ms, delay: delay)
        .then()
        .scale(begin: const Offset(1, 1), end: const Offset(0.5, 0.5), duration: 600.ms);
  }

  // Slide 2: Threads Demo
  Widget _buildThreadsDemoSlide(bool isDark, Size screenSize, bool isSmallScreen, bool isVerySmallScreen) {
    final mockupWidth = screenSize.width * 0.75;
    final titleSize = isSmallScreen ? 22.0 : 28.0;
    final descSize = isSmallScreen ? 13.0 : 15.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated threads mockup
          Container(
            height: isVerySmallScreen ? 180 : (isSmallScreen ? 200 : 280),
            margin: EdgeInsets.only(bottom: isSmallScreen ? 20 : 40),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glassmorphism card
                Container(
                  width: mockupWidth.clamp(200, 280),
                  height: isVerySmallScreen ? 160 : (isSmallScreen ? 180 : 240),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white.withAlpha(15),
                    border: Border.all(color: Colors.white.withAlpha(30)),
                  ),
                ),

                // Thread items
                Positioned(
                  top: isSmallScreen ? 15 : 30,
                  left: isSmallScreen ? 12 : 20,
                  right: isSmallScreen ? 12 : 20,
                  child: _buildThreadItem(
                    'Project Ideas',
                    '2m ago',
                    isActive: false,
                    delay: 200.ms,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
                Positioned(
                  top: isSmallScreen ? 60 : 90,
                  left: isSmallScreen ? 12 : 20,
                  right: isSmallScreen ? 12 : 20,
                  child: _buildThreadItem(
                    'Travel Planning',
                    '1h ago',
                    isActive: true,
                    delay: 400.ms,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
                Positioned(
                  top: isSmallScreen ? 105 : 150,
                  left: isSmallScreen ? 12 : 20,
                  right: isSmallScreen ? 12 : 20,
                  child: _buildThreadItem(
                    'Code Review',
                    'Yesterday',
                    isActive: false,
                    delay: 600.ms,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
              ],
            ),
          ),

          // Title
          Text(
            'Organized Conversations',
            textAlign: TextAlign.center,
            style: GoogleFonts.raleway(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 200.ms),

          SizedBox(height: isSmallScreen ? 12 : 16),

          // Description
          Text(
            'Keep your chats neatly organized in threads. Switch between topics seamlessly.',
            textAlign: TextAlign.center,
            style: GoogleFonts.raleway(
              fontSize: descSize,
              color: Colors.white70,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildThreadItem(String title, String time, {required bool isActive, required Duration delay, required bool isSmallScreen}) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withAlpha(30) : Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: Colors.white.withAlpha(50))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: isSmallScreen ? 16 : 18,
            color: isActive ? Colors.white : Colors.white60,
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.raleway(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 11 : 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.raleway(
                    color: Colors.white54,
                    fontSize: isSmallScreen ? 10 : 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay).slideX(begin: -0.3, end: 0);
  }

  // Slide 3: Sync Demo
  Widget _buildSyncDemoSlide(bool isDark, Size screenSize, bool isSmallScreen, bool isVerySmallScreen) {
    final containerSize = isVerySmallScreen ? 220.0 : (isSmallScreen ? 260.0 : 320.0);
    final cloudSize = isSmallScreen ? 70.0 : 90.0;
    final iconSize = isSmallScreen ? 40.0 : 48.0;
    final titleSize = isSmallScreen ? 22.0 : 28.0;
    final descSize = isSmallScreen ? 13.0 : 15.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated sync visualization
          Container(
            height: containerSize,
            width: containerSize,
            margin: EdgeInsets.only(bottom: isSmallScreen ? 20 : 40),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Central cloud
                Container(
                  width: cloudSize,
                  height: cloudSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(20),
                    border: Border.all(color: Colors.white.withAlpha(40), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withAlpha(30),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.cloud_done_outlined,
                    size: isSmallScreen ? 28 : 36,
                    color: Colors.white.withAlpha(80),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2000.ms)
                    .then()
                    .scale(begin: const Offset(1.05, 1.05), end: const Offset(1, 1), duration: 2000.ms),

                // Device icons orbiting
                _buildDeviceIcon(Icons.phone_iphone, -45, -22, 0.ms, iconSize, isSmallScreen),
                _buildDeviceIcon(Icons.tablet_mac, 45, -22, 400.ms, iconSize, isSmallScreen),
                _buildDeviceIcon(Icons.laptop_mac, 0, 50, 800.ms, iconSize, isSmallScreen),
              ],
            ),
          ),

          // Title
          Text(
            'Sync Everywhere',
            textAlign: TextAlign.center,
            style: GoogleFonts.raleway(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 200.ms),

          SizedBox(height: isSmallScreen ? 12 : 16),

          // Description
          Text(
            'Your conversations follow you across all devices. Start on your phone, continue on your laptop.',
            textAlign: TextAlign.center,
            style: GoogleFonts.raleway(
              fontSize: descSize,
              color: Colors.white70,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildDeviceIcon(IconData icon, double x, double y, Duration delay, double size, bool isSmallScreen) {
    final baseOffset = isSmallScreen ? 110.0 : 140.0;
    final orbitRadius = isSmallScreen ? 12.0 : 15.0;
    return Positioned(
      left: baseOffset + x - size / 2,
      top: baseOffset + y - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withAlpha(15),
          border: Border.all(color: Colors.white.withAlpha(30)),
        ),
        child: Icon(icon, color: Colors.white70, size: isSmallScreen ? 20 : 24),
      )
          .animate(onPlay: (c) => c.repeat())
          .custom(
            duration: 3000.ms,
            delay: delay,
            builder: (context, value, child) {
              final angle = value * 2 * pi;
              return Transform.translate(
                offset: Offset(
                  cos(angle) * orbitRadius,
                  sin(angle) * orbitRadius,
                ),
                child: child,
              );
            },
          ),
    );
  }

  // Slide 4: Welcome
  Widget _buildWelcomeSlide(bool isDark, Size screenSize, bool isSmallScreen, bool isVerySmallScreen) {
    final logoSize = isVerySmallScreen ? 80.0 : (isSmallScreen ? 100.0 : 140.0);
    final topMargin = isVerySmallScreen ? 20.0 : (isSmallScreen ? 30.0 : 50.0);
    final titleSize = isVerySmallScreen ? 22.0 : (isSmallScreen ? 26.0 : 32.0);
    final descSize = isSmallScreen ? 13.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo animation
          Container(
            width: logoSize,
            height: logoSize,
            margin: EdgeInsets.only(bottom: isSmallScreen ? 24 : 40, top: topMargin),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF5137E6),
                  const Color(0xFF7B61FF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5137E6).withAlpha(isSmallScreen ? 60 : 80),
                  blurRadius: isSmallScreen ? 30 : 50,
                  spreadRadius: isSmallScreen ? 10 : 15,
                ),
              ],
            ),
            child: Icon(
              Icons.auto_awesome,
              size: isSmallScreen ? 36 : 48,
              color: Colors.white,
            ),
          )
              .animate()
              .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 800.ms, curve: Curves.elasticOut)
              .then()
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2000.ms),

          // Title
          Text(
            'Welcome to Prompta',
            textAlign: TextAlign.center,
            style: GoogleFonts.raleway(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 300.ms),

          SizedBox(height: isSmallScreen ? 12 : 16),

          // Description
          Text(
            'Your personal AI assistant is ready. Let\'s start exploring the future of conversations together.',
            textAlign: TextAlign.center,
            style: GoogleFonts.raleway(
              fontSize: descSize,
              color: Colors.white70,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 500.ms),

          SizedBox(height: isSmallScreen ? 16 : 24),

          // Feature pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildFeaturePill('AI Chat', delay: 700.ms, isSmallScreen: isSmallScreen),
              _buildFeaturePill('Smart Threads', delay: 800.ms, isSmallScreen: isSmallScreen),
              _buildFeaturePill('Cloud Sync', delay: 900.ms, isSmallScreen: isSmallScreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(String label, {required Duration delay, required bool isSmallScreen}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 6 : 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Text(
        label,
        style: GoogleFonts.raleway(
          color: Colors.white70,
          fontSize: isSmallScreen ? 11 : 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    ).animate().fadeIn(delay: delay).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }
}
