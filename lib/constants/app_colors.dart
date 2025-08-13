import 'package:flutter/material.dart';

/// Classe contenant toutes les couleurs de l'application Koumbaya MarketPlace
class AppColors {
  // Couleurs principales Koumbaya
  static const Color primary = Color(0xFF0099CC);     // Bleu Koumbaya #0099cc
  static const Color secondary = Color(0xFF000000);   // Noir
  static const Color accent = Color(0xFF0099CC);      // Bleu accent (même que primary)
  
  // Variations du bleu principal
  static const Color primaryLight = Color(0xFF33AADD); // Bleu plus clair
  static const Color primaryDark = Color(0xFF007799);  // Bleu plus foncé
  static const Color primaryUltraLight = Color(0xFFE6F7FF); // Bleu très clair pour backgrounds
  
  // Couleurs de statut
  static const Color success = Color(0xFF0099CC);     // Vert succès
  static const Color error = Color(0xFFF44336);       // Rouge erreur
  static const Color warning = Color(0xFFFF9800);     // Orange avertissement
  static const Color info = Color(0xFF2196F3);        // Bleu information
  
  // Couleurs de fond
  static const Color background = Color(0xFFFAFBFC);  // Gris très clair
  static const Color surface = Color(0xFFFFFFFF);     // Blanc
  static const Color surfaceLight = Color(0xFFF8F9FA); // Gris ultra-clair
  
  // Couleurs de texte
  static const Color textPrimary = Color(0xFF1A1A1A);   // Noir principal
  static const Color textSecondary = Color(0xFF666666); // Gris moyen
  static const Color textLight = Color(0xFF999999);     // Gris clair
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Blanc sur primary
  
  // Couleurs de bordure
  static const Color border = Color(0xFFE0E0E0);       // Gris bordure
  static const Color borderLight = Color(0xFFF0F0F0);  // Gris bordure clair
  static const Color divider = Color(0xFFEEEEEE);      // Gris divider
  
  // Couleurs spécifiques aux composants
  static const Color cardShadow = Color(0x1A000000);   // Ombre des cartes
  static const Color overlay = Color(0x80000000);      // Overlay sombre
  static const Color disabled = Color(0xFFBDBDBD);     // Éléments désactivés
  
  // Couleurs pour les statuts de transaction/ticket
  static const Color statusPending = Color(0xFFFF9800);    // Orange
  static const Color statusCompleted = Color(0xFF0099CC);  // Vert
  static const Color statusFailed = Color(0xFFF44336);     // Rouge
  static const Color statusCancelled = Color(0xFF757575);  // Gris
  static const Color statusActive = Color(0xFF2196F3);     // Bleu
  static const Color statusWinner = Color(0xFFFFC107);     // Jaune/doré
  
  // Gradients Koumbaya
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0099CC),
      Color(0xFF007799),
    ],
  );
  
  static const Gradient accentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE6F7FF),
      Color(0xFFFFFFFF),
    ],
  );
  
  // Méthodes utilitaires pour les couleurs avec opacité
  static Color primaryWithOpacity(double opacity) => primary.withOpacity(opacity);
  static Color secondaryWithOpacity(double opacity) => secondary.withOpacity(opacity);
  static Color successWithOpacity(double opacity) => success.withOpacity(opacity);
  static Color errorWithOpacity(double opacity) => error.withOpacity(opacity);
  static Color warningWithOpacity(double opacity) => warning.withOpacity(opacity);
  
  // Couleurs de statut pour les chips/badges
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'en attente':
        return statusPending;
      case 'completed':
      case 'terminé':
      case 'payé':
        return statusCompleted;
      case 'failed':
      case 'échoué':
        return statusFailed;
      case 'cancelled':
      case 'annulé':
        return statusCancelled;
      case 'active':
      case 'actif':
        return statusActive;
      case 'winner':
      case 'gagnant':
        return statusWinner;
      default:
        return primary;
    }
  }
}