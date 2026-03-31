import 'package:client/core/theme/theme_cubit.dart';
import 'package:client/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:client/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:client/features/chat/domain/usecases/send_chat_usecase.dart';
import 'package:client/features/chat/presentation/blocs/chat_bloc/chat_bloc.dart';
import 'package:client/firebase_options.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock app to portrait orientation only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final remoteDataSource = ChatRemoteDatasourceImpl();
  final repository = ChatRepositoryImpl(remoteDataSource);
  final useCase = SendChatUsecase(repository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ChatBloc(sendChatUsecase: useCase)),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: DevicePreview(
        enabled: kDebugMode,
        builder: (context) => MyApp(FirebaseUserRepo()),
      ),
    ),
  );
}
