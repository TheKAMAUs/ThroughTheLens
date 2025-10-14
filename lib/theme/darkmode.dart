import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData darkMode = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF090909), // main background
    primary: Color(0xFFE0DDDD), // main text/icon color
    secondary: Color(0xFF141414), // secondary surfaces
    tertiary: Color(0xFF1D1D1D), // tertiary surfaces
    inversePrimary: Color(0xFFDCD9D9), // contrasting accent
  ),
  scaffoldBackgroundColor: const Color(0xFF090909),
  textTheme: GoogleFonts.nunitoTextTheme(
    const TextTheme(
      bodyMedium: TextStyle(color: Colors.white), // default body color
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF090909),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
);
