import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoriesweb/theme/darkmode.dart';
import 'package:memoriesweb/theme/lightmode.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Your light and dark theme data

class ThemeCubit extends Cubit<ThemeData> {
  bool _isDarkMode = false;

  ThemeCubit() : super(lightMode) {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    emit(_isDarkMode ? darkMode : lightMode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    emit(_isDarkMode ? darkMode : lightMode);
  }
}
