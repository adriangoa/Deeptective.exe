import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _terminalBlack = Color(0xFF0C0C0C);
  static const Color _phosphorGreen = Color(0xFF32CD32);
  static const Color _dimGreen = Color(0xFF1A5C1A);

  static ThemeData get detectiveTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _terminalBlack,
      primaryColor: _phosphorGreen,
      
      colorScheme: const ColorScheme.dark(
        primary: _phosphorGreen,
        secondary: _dimGreen,
        surface: _terminalBlack,
        onSurface: _phosphorGreen,
      ),

      // Tipografía Monoespaciada Global
      textTheme: GoogleFonts.firaCodeTextTheme().apply(
        bodyColor: _phosphorGreen,
        displayColor: _phosphorGreen,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: _terminalBlack,
        elevation: 0,
        titleTextStyle: GoogleFonts.firaCode(
          color: _phosphorGreen,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: _phosphorGreen),
        shape: const Border(
          bottom: BorderSide(color: _phosphorGreen, width: 1.0),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _terminalBlack,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _dimGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _phosphorGreen, width: 2),
        ),
        hintStyle: TextStyle(color: _dimGreen.withOpacity(0.7)),
        prefixIconColor: _phosphorGreen,
      ),
    );
  }
}