import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Classe contenant tous les styles de texte avec les polices Amazon Ember Display
class AppTextStyles {
  static const String _fontFamily = 'AmazonEmberDisplay';

  // Styles de titres
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle h5 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle h6 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // Styles de corps de texte
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Styles spécialisés
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textOnPrimary,
    height: 1.2,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textOnPrimary,
    height: 1.2,
    letterSpacing: 0.3,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textLight,
    height: 1.3,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textLight,
    height: 1.2,
    letterSpacing: 1.5,
  );

  // Styles pour les AppBar
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textOnPrimary,
    height: 1.2,
  );

  static const TextStyle appBarSubtitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textOnPrimary,
    height: 1.3,
  );

  // Styles pour les prix et montants
  static const TextStyle priceMain = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.primary,
    height: 1.2,
  );

  static const TextStyle priceSecondary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textSecondary,
    height: 1.2,
  );

  static const TextStyle priceSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.primary,
    height: 1.2,
  );

  // Styles pour les badges et chips
  static const TextStyle badge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textOnPrimary,
    height: 1.2,
  );

  static const TextStyle chip = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    height: 1.2,
  );

  // Styles pour les formulaires
  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle hint = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textLight,
    height: 1.4,
  );

  static const TextStyle input = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle error = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.error,
    height: 1.3,
  );

  // Styles pour navigation
  static const TextStyle navLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500, // Medium
    height: 1.2,
  );

  static const TextStyle navLabelSelected = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.primary,
    height: 1.2,
  );

  // Méthodes utilitaires pour modifier les couleurs
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withOpacity(opacity));
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}