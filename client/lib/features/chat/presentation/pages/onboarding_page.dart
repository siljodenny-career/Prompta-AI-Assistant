import 'package:client/core/components/custom_button.dart';
import 'package:client/core/components/screen_config.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:client/features/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:client/features/chat/presentation/pages/chat_page.dart';
import 'package:client/features/chat/presentation/widgets/basic_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingSlide(
      title: 'Welcome to\nPrompta',
      subtitle:
          'This official app is free, syncs your history across devices and brings you the best experience.',
      features: [
        _FeatureData(
          icon: 'assets/images/icons8-binoculars.svg',
          title: 'Prompta can be inaccurate',
          description:
              'Prompta may provide inaccurate information about people, places, or facts.',
        ),
        _FeatureData(
          icon: 'assets/images/icons8-lock.svg',
          title: "Don't share sensitive info",
          description:
              "Chats may be reviewed to improve our systems, so don't share sensitive info.",
        ),
      ],
    ),
    _OnboardingSlide(
      title: 'Powerful AI\nCapabilities',
      subtitle:
          'Get instant answers, creative ideas, and expert help across any topic.',
      features: [
        _FeatureData(
          icon: 'assets/images/icons8-settings.svg',
          title: 'Streaming Responses',
          description:
              'Watch answers appear in real-time with live streaming — no waiting for full responses.',
        ),
        _FeatureData(
          icon: 'assets/images/icons8-binoculars.svg',
          title: 'Code Support',
          description:
              'Get syntax-highlighted code in any language, with one-tap copy for easy use.',
        ),
      ],
    ),
    _OnboardingSlide(
      title: 'Stay\nOrganized',
      subtitle:
          'Your conversations are always saved and easy to find.',
      features: [
        _FeatureData(
          icon: 'assets/images/icons8-lock.svg',
          title: 'Multi-Thread Chats',
          description:
              'Organize conversations into separate threads — switch between topics seamlessly.',
        ),
        _FeatureData(
          icon: 'assets/images/icons8-settings.svg',
          title: 'Control Your History',
          description:
              'Decide whether new chats on this device will appear in your history and be used to improve our systems.',
        ),
      ],
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
            userRepository:
                context.read<AuthenticationBloc>().userRepository,
          ),
          child: const ChatPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLastPage = _currentPage == _pages.length - 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Container(
            width: ScreenConfig.screenWidth,
            height: ScreenConfig.screenHeight,
            padding: EdgeInsets.symmetric(
              horizontal: ScreenConfig.screenWidth * 0.07,
              vertical: ScreenConfig.screenWidth * 0.04,
            ),
            child: Column(
              children: [
                // Skip button row
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _navigateToChat,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.raleway(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white54
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ),
                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final slide = _pages[index];
                      return _buildSlide(slide, isDark);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Page indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == index
                            ? AppColors.primaryPurple
                            : (isDark
                                ? Colors.white24
                                : AppColors.lightBorder),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Next / Get Started button
                Center(
                  child: CustomButton(
                    text: isLastPage ? 'Get Started' : 'Next',
                    icon: Icons.arrow_forward,
                    onPressed: () {
                      if (isLastPage) {
                        _navigateToChat();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenConfig.screenWidth * 0.25,
                    ),
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(_OnboardingSlide slide, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 1),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                slide.title,
                style: GoogleFonts.raleway(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 16),
            SvgPicture.asset(
              'assets/images/prompt_icon.svg',
              width: 60,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          slide.subtitle,
          style: GoogleFonts.raleway(
            fontSize: 16,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const Spacer(flex: 1),
        ...slide.features.map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: BasicFeatures(
              icon: f.icon,
              title: f.title,
              description: f.description,
            ),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String subtitle;
  final List<_FeatureData> features;

  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.features,
  });
}

class _FeatureData {
  final String icon;
  final String title;
  final String description;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
