import 'package:client/appview.dart';
import 'package:client/features/auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'core/components/screen_config.dart';

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  const MyApp(this.userRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    ScreenConfig.init(context);
    return RepositoryProvider<UserRepository>(
      create: (context) => userRepository,
      child: BlocProvider<AuthenticationBloc>(
        create: (context) => AuthenticationBloc(userRepository: userRepository),
        child: MyAppView(),
      ),
    );
  }
}
