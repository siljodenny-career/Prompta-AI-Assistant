part of 'sign_in_bloc.dart';

@immutable
sealed class SignInState extends Equatable {
  const SignInState();

  @override
  List<Object?> get props => [];
}

final class SignInInitial extends SignInState {}

final class SignInLoading extends SignInState {}

final class SignInSuccess extends SignInState {
  User? user;
}

final class SignInFailure extends SignInState {
  final String? errorMessage;

  const SignInFailure(this.errorMessage);
}
