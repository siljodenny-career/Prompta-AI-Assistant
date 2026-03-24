import 'package:client/core/components/screen_config.dart';
import 'package:client/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:client/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:client/features/chat/domain/usecases/send_chat_usecase.dart';
import 'package:client/features/chat/presentation/blocs/chat_bloc/chat_bloc.dart';
import 'package:client/features/chat/presentation/pages/onboarding_page.dart';
import 'package:client/core/theme/app_theme.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  final remoteDataSource = ChatRemoteDatasourceImpl();
  final repository = ChatRepositoryImpl(remoteDataSource);
  final useCase = SendChatUsecase(repository);

  runApp(
    BlocProvider(
      create: (_) => ChatBloc(sendChatUsecase: useCase),
      child: DevicePreview(
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenConfig.init(context);
    return MaterialApp(
      title: 'Prompta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: OnboardingPage(),
    );
  }
}
