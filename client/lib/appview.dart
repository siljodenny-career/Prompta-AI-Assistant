import 'package:client/core/theme/theme_cubit.dart';
import 'package:client/features/auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:client/features/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:client/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:client/features/auth/utils/prompta_logo.dart';
import 'package:client/features/chat/presentation/blocs/chat_bloc/chat_bloc.dart';
import 'package:client/features/chat/presentation/pages/chat_page.dart';
import 'package:client/features/chat/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/sign_in/sign_in_screen.dart';
import 'features/auth/sign_up/sign_up_screen.dart';

class MyAppView extends StatefulWidget {
  const MyAppView({super.key});

  @override
  State<MyAppView> createState() => _MyAppViewState();
}

class _MyAppViewState extends State<MyAppView> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'Prompta',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: _showSplash
              ? const _SplashScreen()
              : BlocListener<AuthenticationBloc, AuthenticationState>(
                  listenWhen: (previous, current) =>
                      previous.user?.uid != current.user?.uid,
                  listener: (context, state) {
                    final userId =
                        state.status == AuthenticationStatus.authenticated
                            ? state.user?.uid
                            : null;
                    context.read<ThemeCubit>().setUserId(userId);
                  },
                  child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                    builder: (context, state) {
                      if (state.status == AuthenticationStatus.authenticated) {
                        context
                            .read<ChatBloc>()
                            .add(SetUserIdEvent(state.user!.uid));
                        return _LoadingTransition(
                          userId: state.user!.uid,
                        );
                      } else {
                        return MultiBlocProvider(
                          providers: [
                            BlocProvider<SignInBloc>(
                              create: (context) => SignInBloc(
                                userRepository: context
                                    .read<AuthenticationBloc>()
                                    .userRepository,
                              ),
                            ),
                            BlocProvider<SignUpBloc>(
                              create: (context) => SignUpBloc(
                                userRepository: context
                                    .read<AuthenticationBloc>()
                                    .userRepository,
                              ),
                            ),
                          ],
                          child: const AuthNavigator(),
                        );
                      }
                    },
                  ),
                ),
        );
      },
    );
  }
}

/// Splash screen with PromptaLogo breathing/pulse animation.
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathCtrl;
  late Animation<double> _scale;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.15, end: 0.55).animate(
      CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _breathCtrl,
              builder: (_, child) => Transform.scale(
                scale: _scale.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5137E6)
                            .withValues(alpha: _glow.value),
                        blurRadius: 40,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
              child: const PromptaLogo(size: 80),
            ),
            const SizedBox(height: 28),
            Text(
              'Prompta',
              style: GoogleFonts.raleway(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading transition after auth — shows onboarding only for new sign-ups.
class _LoadingTransition extends StatefulWidget {
  final String userId;
  const _LoadingTransition({required this.userId});

  @override
  State<_LoadingTransition> createState() => _LoadingTransitionState();
}

class _LoadingTransitionState extends State<_LoadingTransition> {
  bool _showLoading = true;
  bool? _showOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final isNewSignUp = prefs.getBool('is_new_signup') ?? false;

    // Clear the flag immediately so it doesn't persist
    if (isNewSignUp) {
      await prefs.remove('is_new_signup');
    }

    // Small delay for loading animation
    await Future.delayed(const Duration(milliseconds: 1800));

    if (mounted) {
      setState(() {
        _showLoading = false;
        _showOnboarding = isNewSignUp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_showLoading || _showOnboarding == null) {
      return Scaffold(
        key: const ValueKey('loading'),
        body: Center(
          child: Lottie.asset(
            'assets/animations/infinity_loading.json',
            width: 100,
            repeat: true,
            animate: true,
            filterQuality: FilterQuality.high,
          ),
        ),
      );
    }

    if (_showOnboarding!) {
      return const OnboardingPage(key: ValueKey('onboarding'));
    }

    return BlocProvider(
      key: const ValueKey('chat'),
      create: (context) => SignInBloc(
        userRepository: context.read<AuthenticationBloc>().userRepository,
      ),
      child: const ChatPage(),
    );
  }
}

/// Manages navigation between SignIn and SignUp within the auth flow.
class AuthNavigator extends StatefulWidget {
  const AuthNavigator({super.key});

  @override
  State<AuthNavigator> createState() => _AuthNavigatorState();
}

class _AuthNavigatorState extends State<AuthNavigator> {
  bool _showSignIn = true;

  void _toggleAuth() {
    setState(() => _showSignIn = !_showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _showSignIn
          ? SignInPage(
              key: const ValueKey('signIn'),
              onNavigateToSignUp: _toggleAuth)
          : SignUpPage(
              key: const ValueKey('signUp'),
              onNavigateToSignIn: _toggleAuth),
    );
  }
}
