import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/profile/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'package:client/features/profile/presentation/blocs/profile_bloc/profile_event.dart';
import 'package:client/features/profile/presentation/blocs/profile_bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_repository/user_repository.dart';

class ProfilePage extends StatelessWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        userRepository: context.read<UserRepository>(),
      )..add(LoadProfile(userId)),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade400,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading && state is! ProfileImageUploading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = _userFromState(state);
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final isUploading = state is ProfileImageUploading;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profile Image
                _ProfileAvatar(
                  user: user,
                  isUploading: isUploading,
                  isDark: isDark,
                ),
                const SizedBox(height: 32),
                // Name Section
                _ProfileField(
                  label: 'Name',
                  value: user.name,
                  isDark: isDark,
                  onEdit: () => _showEditNameDialog(context, user),
                ),
                const SizedBox(height: 16),
                // Email Section (read-only)
                _ProfileField(
                  label: 'Email',
                  value: user.email,
                  isDark: isDark,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  MyUser? _userFromState(ProfileState state) {
    if (state is ProfileLoaded) return state.user;
    if (state is ProfileImageUploading) return state.user;
    if (state is ProfileError) return state.user;
    return null;
  }

  void _showEditNameDialog(BuildContext context, MyUser user) {
    final controller = TextEditingController(text: user.name);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileBloc = context.read<ProfileBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Name',
          style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.raleway(),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: GoogleFonts.raleway(
              color: isDark ? Colors.white38 : AppColors.lightTextTertiary,
            ),
            filled: true,
            fillColor: isDark ? Colors.white12 : AppColors.lightInputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.raleway(
                color: isDark ? Colors.white54 : AppColors.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != user.name) {
                profileBloc.add(
                  UpdateName(userId: user.userId, newName: newName),
                );
              }
              Navigator.pop(dialogContext);
            },
            child: Text(
              'Save',
              style: GoogleFonts.raleway(
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final MyUser user;
  final bool isUploading;
  final bool isDark;

  const _ProfileAvatar({
    required this.user,
    required this.isUploading,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 56,
          backgroundColor: AppColors.primaryPurple.withAlpha(30),
          backgroundImage: user.profileImageUrl != null
              ? NetworkImage(user.profileImageUrl!)
              : null,
          child: user.profileImageUrl == null
              ? Text(
                  _getInitials(user.name),
                  style: GoogleFonts.raleway(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryPurple,
                  ),
                )
              : null,
        ),
        if (isUploading)
          const Positioned.fill(
            child: CircleAvatar(
              radius: 56,
              backgroundColor: Colors.black38,
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: isUploading ? null : () => _pickAndCropImage(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.black : Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndCropImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (picked == null) return;
    if (!context.mounted) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 70,
      maxWidth: 512,
      maxHeight: 512,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Photo',
          toolbarColor: AppColors.primaryPurple,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.primaryPurple,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Profile Photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (cropped == null) return;
    if (!context.mounted) return;

    context.read<ProfileBloc>().add(
      UpdateProfileImage(userId: user.userId, filePath: cropped.path),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    final first = parts[0][0].toUpperCase();
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '$first${parts[1][0].toUpperCase()}';
    }
    return first;
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final VoidCallback? onEdit;

  const _ProfileField({
    required this.label,
    required this.value,
    required this.isDark,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(10) : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.raleway(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white38
                        : AppColors.lightTextTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.raleway(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white
                        : AppColors.lightTextPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: Icon(
                Icons.edit_rounded,
                size: 20,
                color: AppColors.primaryPurple,
              ),
            ),
        ],
      ),
    );
  }
}
