import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  String? _currentUserId;

  ThemeCubit() : super(ThemeMode.dark);

  static const _keyPrefix = 'theme_mode';

  String get _key => _currentUserId != null ? '${_keyPrefix}_$_currentUserId' : '${_keyPrefix}_guest';

  Future<void> setUserId(String? userId) async {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    await _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? true;
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(newMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, newMode == ThemeMode.dark);
  }
}
