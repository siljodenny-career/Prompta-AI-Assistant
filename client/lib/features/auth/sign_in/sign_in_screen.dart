import 'package:client/features/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:client/features/auth/utils/animated_background.dart';
import 'package:client/features/auth/utils/snackbar.dart';
import 'package:client/features/auth/utils/textfield.dart';
import 'package:client/features/auth/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/prompta_logo.dart';
import '../utils/submit_button.dart';

// ─── Sign In Page ─────────────────────────────────────────────────────────────
class SignInPage extends StatefulWidget {
  final VoidCallback? onNavigateToSignUp;
  const SignInPage({super.key, this.onNavigateToSignUp});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  // Background animation
  late AnimationController _bgCtrl;

  // Logo entrance
  late AnimationController _logoCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _logoGlow;

  // Content stagger
  late AnimationController _contentCtrl;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  // Fields stagger offsets
  late Animation<double> _f1, _f2, _f3, _f4;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // ── Background slow loop
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // ── Logo pop-in
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = CurvedAnimation(
      parent: _logoCtrl,
      curve: Curves.elasticOut,
    ).drive(Tween(begin: 0.3, end: 1.0));
    _logoFade = CurvedAnimation(
      parent: _logoCtrl,
      curve: Curves.easeOut,
    ).drive(Tween(begin: 0.0, end: 1.0));
    _logoGlow = CurvedAnimation(
      parent: _logoCtrl,
      curve: Curves.easeOut,
    ).drive(Tween(begin: 0.0, end: 1.0));

    // ── Content fade+slide
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _contentFade = CurvedAnimation(
      parent: _contentCtrl,
      curve: Curves.easeOut,
    ).drive(Tween(begin: 0.0, end: 1.0));
    _contentSlide = CurvedAnimation(
      parent: _contentCtrl,
      curve: Curves.easeOutCubic,
    ).drive(Tween(begin: const Offset(0, 0.10), end: Offset.zero));

    // ── Stagger individual field rows
    _f1 = CurvedAnimation(
      parent: _contentCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ).drive(Tween(begin: 0.0, end: 1.0));
    _f2 = CurvedAnimation(
      parent: _contentCtrl,
      curve: const Interval(0.15, 0.75, curve: Curves.easeOut),
    ).drive(Tween(begin: 0.0, end: 1.0));
    _f3 = CurvedAnimation(
      parent: _contentCtrl,
      curve: const Interval(0.30, 0.90, curve: Curves.easeOut),
    ).drive(Tween(begin: 0.0, end: 1.0));
    _f4 = CurvedAnimation(
      parent: _contentCtrl,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    ).drive(Tween(begin: 0.0, end: 1.0));

    // ── Sequence: logo first, then content
    Future.delayed(const Duration(milliseconds: 200), () {
      _logoCtrl.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 150), () {
          _contentCtrl.forward();
        });
      });
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _logoCtrl.dispose();
    _contentCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool signInRequired = false;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) {
        if (state is SignInLoading) {
          setState(() => signInRequired = true);
        } else if (state is SignInSuccess) {
          setState(() => signInRequired = false);
          // Navigation is handled by AuthenticationBloc in appview.dart
          // The successful sign-in triggers Firebase auth state change,
          // which AuthenticationBloc listens to and rebuilds the app
          // showing OnboardingPage.
        } else if (state is SignInFailure) {
          setState(() => signInRequired = false);
          PromptaSnackBar.error(context, 'Invalid email or password.');
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: PromptaWelcomeTheme.bg,
          body: Stack(
            children: [
              // ── Animated background particles + glows
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _bgCtrl,
                  builder: (_, _) => CustomPaint(
                    painter: ParticlePainter(_bgCtrl.value),
                  ),
                ),
              ),

              // ── Scrollable content
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenW * 0.09,
                  vertical: screenW * 0.05,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // ── Logo entrance animation
                      Center(
                        child: AnimatedBuilder(
                          animation: _logoCtrl,
                          builder: (_, _) => FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: Column(
                                children: [
                                  // Logo mark
                                  PromptaLogo(size: 72),
                                  const SizedBox(height: 14),

                                  // App name beside logo — matches onboarding style
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Prompta',
                                        style: GoogleFonts.raleway(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      // Glowing dot accent
                                      AnimatedBuilder(
                                        animation: _logoGlow,
                                        builder: (_, _) => Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: PromptaWelcomeTheme.accent,
                                            boxShadow: [
                                              BoxShadow(
                                                color: PromptaWelcomeTheme
                                                    .accent
                                                    .withValues(
                                                      alpha: 0.8 * _logoGlow.value,
                                                    ),
                                                blurRadius: 10,
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
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Rest of content with slide+fade
                      FadeTransition(
                        opacity: _contentFade,
                        child: SlideTransition(
                          position: _contentSlide,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Heading — same Raleway bold style as onboarding
                              Text(
                                'Welcome\nback.',
                                style: GoogleFonts.raleway(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.15,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign in to continue your Prompta experience.',
                                style: GoogleFonts.raleway(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white60,
                                ),
                              ),

                              const SizedBox(height: 36),

                              // ── Email field (staggered)
                              FadeTransition(
                                opacity: _f1,
                                child: PromptaField(
                                  label: 'Email address',
                                  icon: Icons.mail_outline_rounded,
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Enter a valid email';
                                    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                                    return emailRegex.hasMatch(v) ? null : 'Enter a valid email';
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),

                              // ── Password field (staggered)
                              FadeTransition(
                                opacity: _f2,
                                child: PromptaField(
                                  label: 'Password',
                                  icon: Icons.lock_outline_rounded,
                                  controller: _passCtrl,
                                  obscure: true,
                                  validator: (v) {
                                    if (v == null || v.length < 6) return 'Min 6 characters';
                                    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Need at least one uppercase letter';
                                    if (!RegExp(r'[a-z]').hasMatch(v)) return 'Need at least one lowercase letter';
                                    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Need at least one number';
                                    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v)) return 'Need at least one special character';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              // ── Forgot password
                              FadeTransition(
                                opacity: _f2,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 0,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Forgot password?',
                                      style: GoogleFonts.raleway(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: PromptaWelcomeTheme.accent,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ── Sign In button (staggered)
                              if (!signInRequired)
                                FadeTransition(
                                  opacity: _f3,
                                  child: SubmitButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<SignInBloc>().add(
                                          SignInRequired(
                                            _emailCtrl.text,
                                            _passCtrl.text,
                                          ),
                                        );
                                      }
                                    },
                                    text: 'Sign In',
                                    icon: Icons.arrow_forward,
                                  ),
                                ),

                              const SizedBox(height: 28),

                              // ── Divider
                              FadeTransition(
                                opacity: _f3,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: PromptaWelcomeTheme.border,
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      child: Text(
                                        'or',
                                        style: GoogleFonts.raleway(
                                          color: PromptaWelcomeTheme.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: PromptaWelcomeTheme.border,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 26),

                              // ── Sign up link
                              FadeTransition(
                                opacity: _f4,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: GoogleFonts.raleway(
                                          color: Colors.white60,
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: widget.onNavigateToSignUp,
                                        child: Text(
                                          'Sign up',
                                          style: GoogleFonts.raleway(
                                            color: PromptaWelcomeTheme.accent,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
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
        ),
      ),
    );
  }
}


