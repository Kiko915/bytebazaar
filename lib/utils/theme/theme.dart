import 'package:flutter/material.dart';
import '../constants/colors.dart';

class BTheme {
  BTheme._(); // Private constructor to prevent instantiation
  
  // Text Styles
  static const TextTheme customTextTheme = TextTheme(
    // Headers using BebasNeue
    displayLarge: TextStyle(fontFamily: 'BebasNeue', fontSize: 57),
    displayMedium: TextStyle(fontFamily: 'BebasNeue', fontSize: 45),
    displaySmall: TextStyle(fontFamily: 'BebasNeue', fontSize: 36),
    headlineLarge: TextStyle(fontFamily: 'BebasNeue', fontSize: 32),
    headlineMedium: TextStyle(fontFamily: 'BebasNeue', fontSize: 28),
    headlineSmall: TextStyle(fontFamily: 'BebasNeue', fontSize: 24),
    titleLarge: TextStyle(fontFamily: 'BebasNeue', fontSize: 22),
    
    // Body text using Poppins
    bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16),
    bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 14),
    bodySmall: TextStyle(fontFamily: 'Poppins', fontSize: 12),
    labelLarge: TextStyle(fontFamily: 'Poppins', fontSize: 14),
    labelMedium: TextStyle(fontFamily: 'Poppins', fontSize: 12),
    labelSmall: TextStyle(fontFamily: 'Poppins', fontSize: 11),
  );

  static ThemeData byteTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    
    // Colors
    primaryColor: BColors.primary,
    scaffoldBackgroundColor: BColors.background,
    colorScheme: ColorScheme.light(
      primary: BColors.primary,
      surface: BColors.surface,
    ),

    // Text Theme
    textTheme: customTextTheme,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: BColors.background,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: customTextTheme.titleLarge?.copyWith(color: BColors.primary),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BColors.primary,
        foregroundColor: BColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: BColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BColors.white, // Explicitly set to white for clarity
      labelStyle: const TextStyle().copyWith(fontSize: 14, color: BColors.textSecondary), // Modern placeholder style
      hintStyle: const TextStyle().copyWith(fontSize: 14, color: BColors.textSecondary), // Style for hintText if used
      errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
      floatingLabelStyle: const TextStyle().copyWith(color: BColors.textPrimary.withOpacity(0.8)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(width: 1, color: BColors.lightGrey), // Default border
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(width: 1, color: BColors.lightGrey), // Subtle border when enabled
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(width: 1, color: BColors.primary), // Primary color border when focused
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(width: 1, color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(width: 2, color: Colors.orange),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // Card Theme
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: BColors.surface,
    ),
  );
}
