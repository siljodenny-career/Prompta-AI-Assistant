import 'package:client/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:client/features/auth/utils/animated_background.dart';
import 'package:client/features/auth/utils/snackbar.dart';
import 'package:client/features/auth/utils/textfield.dart';
import 'package:client/features/auth/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_repository/user_repository.dart';

import '../utils/prompta_logo.dart';
import '../utils/submit_button.dart';
import 'components/password_strength.dart';
import 'components/terms_checkbox.dart';
import 'components/typewriter_headlines.dart';

// ─── Sign Up Page ─────────────────────────────────────────────────────────────
class SignUpPage extends StatefulWidget {
  final VoidCallback? onNavigateToSignIn;
  const SignUpPage({super.key, this.onNavigateToSignIn});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  // Background
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
  late Animation<double> _f1, _f2, _f3, _f4, _f5;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _password = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _passCtrl.addListener(() => setState(() => _password = _passCtrl.text));

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

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

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentFade = CurvedAnimation(
      parent: _contentCtrl,
      curve: Curves.easeOut,
    ).drive(Tween(begin: 0.0, end: 1.0));
    _contentSlide = CurvedAnimation(
      parent: _contentCtrl,
      curve: Curves.easeOutCubic,
    ).drive(Tween(begin: const Offset(0, 0.10), end: Offset.zero));

    _f1 = CurvedAnimation(
      parent: _contentCtrl,
      curve: const Interval(0.00, 0.55, curve: Curves.easeOut),
    ).drive(Tween(begin: 0.0, end: 1.0));
    _f2 = CurvedAnimation(
      parent: _contentCtrl,
      curve: const Interval(0.15, 0.70, curve: Curves.easeOut),
    ).drive(Tween(begin: 0.0, end: 1.0));
    _f3 = CurvedAnimation(
      parent: _contentCtrl,
      curve: const Interval(0.30, 0.82, curve: Curves.easeOut),
    ).drive(Tween(begin: 0.0, end: 1.0));
    _f4 = CurvedAnimation(
      parent: _contentCtrl,
      curve: const Interval(0.45, 0.92, curve: Curves.easeOut),
    ).drive(Tween(begin: 0.0, end: 1.0));
    _f5 = CurvedAnimation(
      parent: _contentCtrl,
      curve: const Interval(0.58, 1.00, curve: Curves.easeOut),
    ).drive(Tween(begin: 0.0, end: 1.0));

    // Same sequence as sign-in
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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool _signUpRequired = false;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          setState(() => _signUpRequired = false);
          PromptaSnackBar.success(context, 'Account created! Welcome to Prompta.');
        } else if (state is SignUpLoading) {
          setState(() => _signUpRequired = true);
        } else if (state is SignUpFailure) {
          return;
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: PromptaWelcomeTheme.bg,
          body: Stack(
            children: [
              // ── Animated background
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _bgCtrl,
                  builder: (_, __) =>
                      CustomPaint(painter: ParticlePainter(_bgCtrl.value)),
                ),
              ),

              // ── Scrollable form
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
                      const SizedBox(height: 20),

                      // ── Logo (elastic pop — identical to sign-in)
                      Center(
                        child: AnimatedBuilder(
                          animation: _logoCtrl,
                          builder: (_, __) => FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: Column(
                                children: [
                                  PromptaLogo(size: 68),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Prompta',
                                        style: GoogleFonts.raleway(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      AnimatedBuilder(
                                        animation: _logoGlow,
                                        builder: (_, __) => Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: PromptaWelcomeTheme.accent,
                                            boxShadow: [
                                              BoxShadow(
                                                color: PromptaWelcomeTheme
                                                    .accent
                                                    .withOpacity(
                                                      0.8 * _logoGlow.value,
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

                      const SizedBox(height: 36),

                      // ── Content block
                      FadeTransition(
                        opacity: _contentFade,
                        child: SlideTransition(
                          position: _contentSlide,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Typewriter curious headline
                              Column(
                                children: [
                                  SizedBox(
                                    height: 148,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 120,
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: const TypewriterHeadline(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 4),
                                ],
                              ),

                              // ── Name
                              Column(
                                children: [
                                  FadeTransition(
                                    opacity: _f1,
                                    child: PromptaField(
                                      label: 'Full name',
                                      icon: Icons.person_outline_rounded,
                                      controller: _nameCtrl,
                                      keyboardType: TextInputType.name,
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                          ? 'Name is required'
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // ── Email
                                  FadeTransition(
                                    opacity: _f2,
                                    child: PromptaField(
                                      label: 'Email address',
                                      icon: Icons.mail_outline_rounded,
                                      controller: _emailCtrl,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) =>
                                          (v == null || !v.contains('@'))
                                          ? 'Enter a valid email'
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // ── Password
                                  FadeTransition(
                                    opacity: _f3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        PromptaField(
                                          label: 'Create password',
                                          icon: Icons.lock_outline_rounded,
                                          controller: _passCtrl,
                                          obscure: true,
                                          validator: (v) =>
                                              (v == null || v.length < 6)
                                              ? 'Min 6 characters'
                                              : null,
                                        ),
                                        PasswordStrength(password: _password),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // ── Terms and conditions checkbox
                                  FadeTransition(
                                    opacity: _f3,
                                    child: const TermsCheckBox(),
                                  ),

                                  const SizedBox(height: 24),

                                  // ── Create account button
                                  !_signUpRequired
                                      ? FadeTransition(
                                          opacity: _f4,
                                          child: SubmitButton(
                                            text: 'Create Account',
                                            icon: Icons.arrow_forward,
                                            onPressed: () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                MyUser myUser = MyUser.empty;
                                                myUser = myUser.copywith(
                                                  name: _nameCtrl.text.trim(),
                                                  email: _emailCtrl.text.trim(),
                                                );

                                                setState(() {
                                                  context
                                                      .read<SignUpBloc>()
                                                      .add(
                                                        SignUpRequired(
                                                          myUser,
                                                          _passCtrl.text,
                                                        ),
                                                      );
                                                });
                                              }
                                            },
                                          ),
                                        )
                                      : CircularProgressIndicator(),

                                  const SizedBox(height: 14),

                                  // ── Divider
                                  FadeTransition(
                                    opacity: _f4,
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
                                              color:
                                                  PromptaWelcomeTheme.textMuted,
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

                                  const SizedBox(height: 5),

                                  // ── Sign in link
                                  FadeTransition(
                                    opacity: _f5,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Already have an account? ",
                                            style: GoogleFonts.raleway(
                                              color: Colors.white60,
                                              fontSize: 14,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: widget.onNavigateToSignIn,
                                            child: Text(
                                              'Sign In',
                                              style: GoogleFonts.raleway(
                                                color:
                                                    PromptaWelcomeTheme.accent,
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
