import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;

  ProfileBloc({required this.userRepository}) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateName>(_onUpdateName);
    on<UpdateProfileImage>(_onUpdateProfileImage);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = await userRepository.getUserData(event.userId);
      emit(ProfileLoaded(user));
    } catch (e) {
      log(e.toString());
      emit(ProfileError('Failed to load profile'));
    }
  }

  Future<void> _onUpdateName(
    UpdateName event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = _currentUser;
    if (currentUser == null) return;

    emit(ProfileLoading());
    try {
      await userRepository.updateUserName(event.userId, event.newName);
      final updated = currentUser.copywith(name: event.newName);
      emit(ProfileLoaded(updated));
    } catch (e) {
      log(e.toString());
      emit(ProfileError('Failed to update name', user: currentUser));
    }
  }

  Future<void> _onUpdateProfileImage(
    UpdateProfileImage event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = _currentUser;
    if (currentUser == null) return;

    emit(ProfileImageUploading(currentUser));
    try {
      final url = await userRepository.uploadProfileImage(
        event.userId,
        event.filePath,
      );
      final updated = currentUser.copywith(profileImageUrl: url);
      emit(ProfileLoaded(updated));
    } catch (e) {
      log(e.toString());
      emit(ProfileError('Failed to upload image', user: currentUser));
    }
  }

  MyUser? get _currentUser {
    final s = state;
    if (s is ProfileLoaded) return s.user;
    if (s is ProfileImageUploading) return s.user;
    if (s is ProfileError) return s.user;
    return null;
  }
}
