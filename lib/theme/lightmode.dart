import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    surface: Color(0xFFF5F5F5), // light grey background
    primary: Color(0xFF1E1E1E), // dark grey for text/icons
    secondary: Color(0xFFE2DADA), // soft secondary elements
    tertiary: Color(0xFFFAFAFA), // almost white panels
    inversePrimary: Color(0xFF1D1D1D), // inverse text
  ),
  scaffoldBackgroundColor: const Color(0xFFF0ECEC), // soft warm grey
  textTheme: GoogleFonts.nunitoTextTheme(
    const TextTheme(
      bodyMedium: TextStyle(
        color: Colors.black87,
      ), // readable default body text
      bodyLarge: TextStyle(color: Colors.black87),
      titleMedium: TextStyle(color: Colors.black87),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFF7F3F3),
    foregroundColor: Colors.black, // text/icons on appbar
    elevation: 0,
  ),
);
