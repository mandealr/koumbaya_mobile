import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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

  Future<bool> loginWithIdentifier(String identifier, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _apiService.loginWithIdentifier(identifier, password);
      
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

      if (kDebugMode) {
        print('📱 Register Response:');
        print('   - Success: ${response.success}');
        print('   - isSuccess: ${response.isSuccess}');
        print('   - Message: ${response.message}');
        print('   - Has token: ${response.token != null}');
        print('   - Has user: ${response.user != null}');
      }

      // Pour l'inscription, on considère le succès basé sur isSuccess
      if (response.isSuccess) {
        // Si un token est fourni, on le sauvegarde et on connecte l'utilisateur
        if (response.token != null && response.user != null && !response.token!.startsWith('temp_')) {
          await SecureTokenStorage.saveToken(response.token!);
          _user = response.user;
          _status = AuthStatus.authenticated;
          notifyListeners();
        }
        // Retourner true même sans token pour permettre la redirection vers OTP
        return true;
      } else {
        _setError(response.message ?? 'Erreur lors de l\'inscription');
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Register Error: $e');
      }
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

  Future<bool> changePassword(Map<String, dynamic> passwordData) async {
    try {
      _setLoading(true);
      _clearError();

      await _apiService.changePassword(passwordData);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Envoie un code OTP de vérification à l'utilisateur connecté
  Future<bool> sendVerificationOtp() async {
    print('🔍 AuthProvider.sendVerificationOtp called');
    
    if (_user?.email == null) {
      print('❌ No email found for user: $_user');
      _setError('Aucun email trouvé pour envoyer le code de vérification.');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      print('📤 Calling API to send OTP for: ${_user!.email}');
      
      final result = await _apiService.sendOtpCode(
        identifier: _user!.email,
        isEmail: true,
        purpose: 'registration', // Utilise le même purpose que lors de l'inscription
      );

      print('📥 API result: $result');

      if (result['success'] == true) {
        print('✅ OTP sent successfully');
        return true;
      } else {
        print('❌ OTP send failed: ${result['message']}');
        _setError(result['message'] ?? 'Impossible d\'envoyer le code de vérification.');
        return false;
      }
    } catch (e) {
      print('💥 Exception in sendVerificationOtp: $e');
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

  /// Login avec Google Sign In
  Future<bool> loginWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Sign out first to ensure account picker is shown
      await googleSignIn.signOut();

      final GoogleSignInAccount? account = await googleSignIn.signIn();

      if (account == null) {
        _setError('Connexion Google annulée');
        return false;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      if (auth.idToken == null) {
        _setError('Échec de l\'authentification Google');
        return false;
      }

      final response = await _apiService.loginWithSocial(
        provider: 'google',
        idToken: auth.idToken,
        accessToken: auth.accessToken,
      );

      if (response.isSuccess && response.user != null && response.token != null) {
        await SecureTokenStorage.saveToken(response.token!);
        _user = response.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Erreur de connexion avec Google');
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login avec Facebook
  Future<bool> loginWithFacebook() async {
    try {
      _setLoading(true);
      _clearError();

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        _setError('Connexion Facebook annulée');
        return false;
      }

      final AccessToken? accessToken = result.accessToken;

      if (accessToken == null) {
        _setError('Échec de l\'authentification Facebook');
        return false;
      }

      final response = await _apiService.loginWithSocial(
        provider: 'facebook',
        accessToken: accessToken.token,
      );

      if (response.isSuccess && response.user != null && response.token != null) {
        await SecureTokenStorage.saveToken(response.token!);
        _user = response.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Erreur de connexion avec Facebook');
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      // Gérer spécifiquement les erreurs de validation 422
      if (error.statusCode == 422 && error.errors != null) {
        return _formatValidationErrors(error.errors!);
      }
      // Gérer l'erreur de vérification 403
      if (error.statusCode == 403 && error.errors != null) {
        // errors peut être soit un Map soit une List selon l'API
        if (error.errors is Map<String, dynamic> &&
            error.errors!['error_code'] == 'EMAIL_NOT_VERIFIED') {
          _setError('Veuillez vérifier votre compte pour continuer.');
          return 'Veuillez vérifier votre compte pour continuer.';
        }
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
      dynamic fieldErrorsData = errors[field];
      
      if (fieldErrorsData is List) {
        // Si c'est une liste de messages d'erreur
        for (dynamic error in fieldErrorsData) {
          if (error is String) {
            // Si c'est déjà un message formaté
            if (!errorMessages.contains(error)) {
              errorMessages.add(error);
            }
          } else {
            // Sinon, on traduit
            String friendlyMessage = _translateValidationError(field, error.toString());
            if (!errorMessages.contains(friendlyMessage)) {
              errorMessages.add(friendlyMessage);
            }
          }
        }
      } else if (fieldErrorsData is String) {
        // Si c'est un simple message
        if (!errorMessages.contains(fieldErrorsData)) {
          errorMessages.add(fieldErrorsData);
        }
      }
    }
    
    if (errorMessages.isEmpty) {
      return 'Erreur de validation. Veuillez vérifier vos informations.';
    }
    
    // Si un seul message d'erreur, pas de bullet point
    if (errorMessages.length == 1) {
      return errorMessages.first;
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