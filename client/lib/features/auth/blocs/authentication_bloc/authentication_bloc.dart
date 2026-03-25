import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:user_repository/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  late final StreamSubscription<User?> _userSubscription;

  AuthenticationBloc({required this.userRepository})
    : super(AuthenticationState.unknown()) {
    _userSubscription = userRepository.user.listen((user) {
      add(AuthenticationUserChanged(user));
    });
    on<AuthenticationUserChanged>((event, emit) {
      emit(
        event.user != null
            ? AuthenticationState.authenticated(event.user!)
            : const AuthenticationState.unauthenticated(),
      );
    });
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
