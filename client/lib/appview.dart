import 'package:client/features/auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:client/features/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:client/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:client/features/chat/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/sign_in/sign_in_screen.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prompta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            return const OnboardingPage();
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
              child: const SignInScreen(),
            );
          }
        },
      ),
    );
  }
}

/// A wrapper that provides the sign-in screen as the default landing,
/// with the option to navigate to sign-up.
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SignInPage();
  }
}
