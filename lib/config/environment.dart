import 'package:flutter/foundation.dart';

class Environment {
  static const String _prodUrl = 'https://koumbaya.com';
  static const String _devUrl = 'http://localhost:8000';
  
  // Pour Android emulator, utilisez 10.0.2.2 au lieu de localhost
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8000';
  
  // Ajoutez votre IP locale ici pour les tests sur device physique
  static const String _localNetworkUrl = 'http://192.168.1.100:8000';
  
  static String get baseUrl {
    // FORCER l'utilisation de l'URL de production pour tous les environnements
    // Commentez cette ligne et décommentez le bloc ci-dessous pour le développement local
    return _prodUrl;
    
    /* Configuration pour le développement local (décommentez si nécessaire)
    // En mode release, toujours utiliser l'URL de production
    if (kReleaseMode) {
      return _prodUrl;
    }
    
    // En mode debug, vous pouvez changer cette ligne selon vos besoins
    // Pour Android Emulator:
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidEmulatorUrl;
    }
    
    // Pour iOS Simulator ou web:
    return _devUrl;
    */
  }
  
  static bool get isProduction => kReleaseMode;
  static bool get isDevelopment => !kReleaseMode;
}