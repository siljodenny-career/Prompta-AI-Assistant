import 'package:client/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.scaffoldBgColor,
    brightness: Brightness.dark,
    textTheme: GoogleFonts.ralewayTextTheme(
      ThemeData.dark().textTheme,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF0A0A0A),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    brightness: Brightness.light,
    textTheme: GoogleFonts.ralewayTextTheme(
      ThemeData.light().textTheme,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFFF5F5F5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F5F5),
      foregroundColor: Colors.black87,
    ),
  );
}
