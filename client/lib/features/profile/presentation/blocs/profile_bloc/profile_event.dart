import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String userId;
  const LoadProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateName extends ProfileEvent {
  final String userId;
  final String newName;
  const UpdateName({required this.userId, required this.newName});

  @override
  List<Object?> get props => [userId, newName];
}

class UpdateProfileImage extends ProfileEvent {
  final String userId;
  final String filePath;
  const UpdateProfileImage({required this.userId, required this.filePath});

  @override
  List<Object?> get props => [userId, filePath];
}
