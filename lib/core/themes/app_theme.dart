import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color deepForest = Color(0xFF3A5A40);
  static const Color darkOlive = Color(0xFF344E41);
  static const Color vintageCream = Color(0xFFFAF3E0);
  static const Color dustyBrown = Color(0xFF7F5539);
  static const Color mutedBeige = Color(0xFFE9D8C4);
  static const Color antiqueGold = Color(0xFFC2A878);
  static const Color primaryText = Color(0xFF2E2E2E);
  static const Color secondaryText = Color(0xFF6B6B6B);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: vintageCream,
    primaryColor: deepForest,
    colorScheme: const ColorScheme.light(
      primary: deepForest,
      secondary: antiqueGold,
      surface: Colors.white,
      error: Colors.red,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: deepForest,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      margin: const EdgeInsets.all(8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: dustyBrown,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        color: primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      titleLarge: GoogleFonts.montserrat(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      bodyMedium: GoogleFonts.poppins(color: secondaryText, fontSize: 14),
      labelLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
    ),
  );
}
