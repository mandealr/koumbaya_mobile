import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/secure_token_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _user;
  AuthStatus _status = AuthStatus.unknown;
  String? _errorMessage;
  bool _isLoading = false;

  User? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isVerified => _user?.verifiedAt != null;

  Future<String?> get token async {
    return await SecureTokenStorage.getToken();
  }

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      _setLoading(true);
      final hasToken = await SecureTokenStorage.hasToken();
      
      if (kDebugMode) {
        print('🔍 AuthProvider: Checking auth status...');
        print('🔑 Has token: $hasToken');
      }
      
      if (hasToken) {
        try {
          final user = await _apiService.getMe(autoRemoveTokenOn401: false);
          _user = user;
          _status = AuthStatus.authenticated;
          if (kDebugMode) {
            print('✅ AuthProvider: User authenticated - ${user.email}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ AuthProvider: Error getting user - $e');
          }
          // Ne supprimer le token que si c'est une erreur d'authentification (401)
          if (e is ApiException && e.statusCode == 401) {
            _status = AuthStatus.unauthenticated;
            await SecureTokenStorage.removeToken();
            _user = null;
            if (kDebugMode) {
              print('🚫 AuthProvider: Token expired/invalid, user needs to login again');
            }
          } else {
            // Pour les autres erreurs (réseau, serveur), garder le token et rester connecté
            _status = AuthStatus.authenticated;
            if (kDebugMode) {
              print('⚠️ AuthProvider: Network error, keeping authenticated state');
            }
          }
        }
      } else {
        _status = AuthStatus.unauthenticated;
        if (kDebugMode) {
          print('🔓 AuthProvider: No token, unauthenticated');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('💥 AuthProvider: General error - $e');
      }
      // Erreur générale, ne pas supprimer le token
      if (await SecureTokenStorage.hasToken()) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } finally {
      _setLoading(false);
      if (kDebugMode) {
        print('🏁 AuthProvider: Final status - $_status');
      }
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _apiService.login(email, password);
      
      if (response.isSuccess && response.user != null) {
        // Vérifier qu'un token valide est fourni par l'API
        if (response.token != null && !response.token!.startsWith('temp_')) {
          await SecureTokenStorage.saveToken(response.token!);
        } else {
          _setError('Token d\'authentification invalide reçu du serveur');
          return false;
        }
        
        _user = response.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Erreur de connexion');
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    int? countryId,
    int? languageId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _apiService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
        countryId: countryId,
        languageId: languageId,
      );

      if (response.isSuccess && response.token != null && response.user != null) {
        await SecureTokenStorage.saveToken(response.token!);
        _user = response.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Erreur lors de l\'inscription');
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
    } finally {
      _user = null;
      _status = AuthStatus.unauthenticated;
      await SecureTokenStorage.removeTokens();
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    if (!isAuthenticated) return;

    try {
      final user = await _apiService.getMe(autoRemoveTokenOn401: false);
      _user = user;
      notifyListeners();
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        // Token expiré, déconnecter l'utilisateur
        await logout();
      } else {
        debugPrint('Erreur lors du rafraîchissement de l\'utilisateur: $e');
      }
    }
  }

  /// Détermine la route d'accueil selon les rôles de l'utilisateur
  String getHomeRoute() {
    if (_user == null) return '/guest';
    
    debugPrint('🔄 Détermination de la route selon les rôles:');
    debugPrint('   - Utilisateur: ${_user!.fullName}');
    debugPrint('   - Rôles: ${_user!.roleNames}');
    debugPrint('   - isMerchant: ${_user!.isMerchant}');
    debugPrint('   - hasParticulier: ${_user!.hasRole("Particulier")}');
    debugPrint('   - hasBusiness: ${_user!.hasRole("Business")}');
    
    // Logique simplifiée : Business = espace marchand, Particulier = espace client
    if (_user!.isMerchant) {
      debugPrint('   → Redirection vers espace marchand (Business)');
      return '/home'; // Temporairement /home, plus tard /merchant-home
    }
    
    debugPrint('   → Redirection vers espace client (Particulier)');
    // Par défaut, espace client
    return '/home';
  }

  Future<bool> updateProfile(Map<String, dynamic> updateData) async {
    try {
      _setLoading(true);
      _clearError();

      final updatedUser = await _apiService.updateProfile(updateData);
      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      // Gérer spécifiquement les erreurs de validation 422
      if (error.statusCode == 422 && error.errors != null) {
        return _formatValidationErrors(error.errors!);
      }
      // Gérer l'erreur de vérification 403
      if (error.statusCode == 403 && error.errors != null && 
          error.errors!['error_code'] == 'EMAIL_NOT_VERIFIED') {
        _setError('Veuillez vérifier votre compte pour continuer.');
        return 'Veuillez vérifier votre compte pour continuer.';
      }
      return error.message;
    }
    
    // Gestion des erreurs de connectivité
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('socketexception') || 
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
    }
    
    if (errorString.contains('timeout')) {
      return 'La connexion a expiré. Veuillez réessayer.';
    }
    
    if (errorString.contains('formatexception')) {
      return 'Erreur de format de réponse du serveur.';
    }
    
    // Log l'erreur pour le debugging
    debugPrint('Erreur de connexion non gérée: $error');
    
    return 'Une erreur inattendue s\'est produite. Veuillez réessayer.';
  }

  String _formatValidationErrors(Map<String, dynamic> errors) {
    List<String> errorMessages = [];
    
    for (String field in errors.keys) {
      List<dynamic> fieldErrors = errors[field] as List<dynamic>;
      
      for (String errorKey in fieldErrors) {
        String friendlyMessage = _translateValidationError(field, errorKey);
        if (!errorMessages.contains(friendlyMessage)) {
          errorMessages.add(friendlyMessage);
        }
      }
    }
    
    if (errorMessages.isEmpty) {
      return 'Erreur de validation. Veuillez vérifier vos informations.';
    }
    
    return '• ' + errorMessages.join('\n• ');
  }

  String _translateValidationError(String field, String errorKey) {
    // Traduction des noms de champs
    Map<String, String> fieldNames = {
      'email': 'Email',
      'phone': 'Numéro de téléphone',
      'first_name': 'Prénom',
      'last_name': 'Nom',
      'password': 'Mot de passe',
      'password_confirmation': 'Confirmation du mot de passe',
      'country_id': 'Pays',
      'language_id': 'Langue',
    };

    // Traduction des messages d'erreur
    Map<String, String> errorMessages = {
      'validation.required': 'est obligatoire',
      'validation.email': 'doit être une adresse email valide',
      'validation.unique': 'est déjà utilisé par un autre compte',
      'validation.min.string': 'est trop court',
      'validation.max.string': 'est trop long',
      'validation.confirmed': 'et sa confirmation ne correspondent pas',
      'validation.regex': 'a un format invalide',
    };

    String fieldName = fieldNames[field] ?? field;
    String errorMessage = errorMessages[errorKey] ?? errorKey;
    
    return '$fieldName $errorMessage';
  }
}