import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Koumbaya MarketPlace';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'selected_language';
  static const String countryKey = 'selected_country';
  
  // Theme Colors - Koumbaya Brand
  static const Color primaryColor = Color(0xFF0099CC);     // Bleu principal
  static const Color secondaryColor = Color(0xFF000000);   // Noir secondaire
  static const Color accentColor = Color(0xFF0099CC);      // Bleu accent
  static const Color lightAccentColor = Color(0xFFE6F7FF); // Bleu clair
  static const Color lotteryColor = Color(0xFF9333EA);     // Violet pour tombolas
  static const Color lightLotteryColor = Color(0xFFF3E8FF); // Violet clair pour tombolas
  static const Color errorColor = Color(0xFFF44336);       // Rouge erreur
  static const Color successColor = Color(0xFF0099CC);     // Bleu succès
  static const Color warningColor = Color(0xFFFF9800);     // Orange avertissement
  static const Color backgroundColor = Color(0xFFFAFBFC);  // Gris très clair
  static const Color surfaceColor = Color(0xFFFFFFFF);     // Blanc surface
  static const Color textPrimaryColor = Color(0xFF1A1A1A); // Texte principal
  static const Color textSecondaryColor = Color(0xFF666666); // Texte secondaire
  static const Color borderColor = Color(0xFFE0E0E0);      // Bordures
  
  // Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 3);
  
  // Typography - Amazon Ember Display
  static const String primaryFontFamily = 'AmazonEmberDisplay';
  
  // Sizes & Spacing
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  
  // Pagination
  static const int defaultPageSize = 20;
}