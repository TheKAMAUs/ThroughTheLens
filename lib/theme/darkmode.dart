import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData darkMode = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF0A0A1A), // deep navy background
    primary: Color(0xFFB0C4DE), // light steel blue for text/icons
    secondary: Color(0xFF101830), // darker navy for secondary surfaces
    tertiary: Color(0xFF18203A), // soft navy for tertiary areas
    inversePrimary: Color(0xFF5B84B1), // accent navy blue
  ),
  scaffoldBackgroundColor: const Color(0xFF0A0A1A),
  textTheme: GoogleFonts.nunitoTextTheme(
    const TextTheme(
      bodyMedium: TextStyle(color: Colors.white), // readable text on navy
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0A0A1A),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
);
