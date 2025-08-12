import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service de stockage sécurisé pour les tokens d'authentification
/// Remplace SharedPreferences par un stockage chiffré
class SecureTokenStorage {
  static const _storage = FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Sauvegarde le token d'authentification de manière sécurisée
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Récupère le token d'authentification
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Sauvegarde le refresh token
  static Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Récupère le refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Supprime tous les tokens
  static Future<void> removeTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Supprime uniquement le token principal
  static Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Vérifie si un token existe
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Supprime toutes les données stockées
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}