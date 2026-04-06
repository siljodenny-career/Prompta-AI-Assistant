import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final MyUser user;
  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileImageUploading extends ProfileState {
  final MyUser user;
  const ProfileImageUploading(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;
  final MyUser? user;
  const ProfileError(this.message, {this.user});

  @override
  List<Object?> get props => [message, user];
}
