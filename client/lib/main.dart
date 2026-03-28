import 'package:client/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:client/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:client/features/chat/domain/usecases/send_chat_usecase.dart';
import 'package:client/features/chat/presentation/blocs/chat_bloc/chat_bloc.dart';
import 'package:client/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final remoteDataSource = ChatRemoteDatasourceImpl();
  final repository = ChatRepositoryImpl(remoteDataSource);
  final useCase = SendChatUsecase(repository);

  runApp(
    BlocProvider(
      create: (_) => ChatBloc(sendChatUsecase: useCase),
      child: MyApp(FirebaseUserRepo()),
    ),
  );
}
