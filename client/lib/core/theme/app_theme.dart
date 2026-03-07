import 'package:client/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.scaffoldBgColor,
    brightness: Brightness.dark,
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.textBoldColor,
        fontSize: 30,
        fontWeight: FontWeight.w900,

      ),
      headlineMedium: TextStyle(
        color: AppColors.textBoldColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textLightColor,
        fontSize: 18,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        color: AppColors.textLightColor,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}
