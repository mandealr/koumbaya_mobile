import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_constants.dart';

class KoumbayaTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Famille de police principale
      fontFamily: AppConstants.primaryFontFamily,
      
      // Schéma de couleurs Koumbaya
      colorScheme: const ColorScheme.light(
        primary: AppConstants.primaryColor,
        secondary: AppConstants.secondaryColor,
        surface: AppConstants.surfaceColor,
        background: AppConstants.backgroundColor,
        error: AppConstants.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppConstants.textPrimaryColor,
        onBackground: AppConstants.textPrimaryColor,
        onError: Colors.white,
      ),
      
      // Configuration AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: AppConstants.elevationLow,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppConstants.primaryFontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Configuration des boutons élevés
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: AppConstants.elevationLow,
          shadowColor: AppConstants.primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: AppConstants.primaryFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Configuration des boutons texte
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          textStyle: const TextStyle(
            fontFamily: AppConstants.primaryFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Configuration des boutons outline
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          side: const BorderSide(color: AppConstants.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: AppConstants.primaryFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Configuration des cartes
      cardTheme: CardTheme(
        color: AppConstants.surfaceColor,
        elevation: AppConstants.elevationLow,
        shadowColor: AppConstants.secondaryColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      
      // Configuration des champs de saisie
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          borderSide: const BorderSide(color: AppConstants.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          borderSide: const BorderSide(color: AppConstants.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          borderSide: const BorderSide(color: AppConstants.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          borderSide: const BorderSide(color: AppConstants.errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          fontFamily: AppConstants.primaryFontFamily,
          color: AppConstants.textSecondaryColor,
        ),
        labelStyle: TextStyle(
          fontFamily: AppConstants.primaryFontFamily,
          color: AppConstants.textSecondaryColor,
        ),
      ),
      
      // Configuration des Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppConstants.lightAccentColor,
        selectedColor: AppConstants.primaryColor,
        disabledColor: AppConstants.borderColor,
        labelStyle: const TextStyle(
          fontFamily: AppConstants.primaryFontFamily,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: AppConstants.primaryFontFamily,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: AppConstants.elevationLow,
      ),
      
      // Configuration du NavigationBar (bottom navigation)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppConstants.surfaceColor,
        elevation: AppConstants.elevationMedium,
        indicatorColor: AppConstants.lightAccentColor,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontFamily: AppConstants.primaryFontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Configuration des SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppConstants.secondaryColor,
        contentTextStyle: const TextStyle(
          fontFamily: AppConstants.primaryFontFamily,
          color: Colors.white,
          fontSize: 16,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
      ),
      
      // Configuration des boîtes de dialogue
      dialogTheme: DialogTheme(
        backgroundColor: AppConstants.surfaceColor,
        elevation: AppConstants.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: AppConstants.primaryFontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimaryColor,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: AppConstants.primaryFontFamily,
          fontSize: 16,
          color: AppConstants.textSecondaryColor,
        ),
      ),
      
      // Configuration des indicateurs de progression
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppConstants.primaryColor,
        linearTrackColor: AppConstants.lightAccentColor,
        circularTrackColor: AppConstants.lightAccentColor,
      ),
      
      // Configuration des dividers
      dividerTheme: const DividerThemeData(
        color: AppConstants.borderColor,
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  // Thème sombre (optionnel)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppConstants.primaryFontFamily,
      
      colorScheme: ColorScheme.dark(
        primary: AppConstants.primaryColor,
        secondary: AppConstants.primaryColor.withOpacity(0.8),
        surface: const Color(0xFF1A1A1A),
        background: const Color(0xFF0F0F0F),
        error: AppConstants.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),
    );
  }
}