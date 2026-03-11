import 'package:client/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.scaffoldBgColor,
    brightness: Brightness.dark,
    textTheme: GoogleFonts.ralewayTextTheme(),
  );
}
