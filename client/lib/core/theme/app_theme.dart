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
    scaffoldBackgroundColor: AppColors.lightScaffoldBg,
    brightness: Brightness.light,
    textTheme: GoogleFonts.ralewayTextTheme(
      ThemeData.light().textTheme,
    ).apply(
      bodyColor: AppColors.lightTextPrimary,
      displayColor: AppColors.lightTextPrimary,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.lightSurface,
      elevation: 0,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightScaffoldBg,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightDivider,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.lightTextSecondary,
    ),
  );
}
