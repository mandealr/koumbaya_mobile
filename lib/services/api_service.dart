import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/api_response.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../models/country.dart';
import '../models/language.dart';
import '../models/category.dart' as cat;
import '../models/product.dart';
import '../models/lottery.dart';
import '../models/lottery_ticket.dart';
import '../models/ticket_with_details.dart';
import '../models/notification.dart';
import '../utils/secure_token_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Platform': 'mobile',
      'X-App-Version': '1.0.0', // TODO: Get from package_info
      'User-Agent': 'KoumbayaFlutter/1.0.0',
    };

    if (includeAuth) {
      final token = await SecureTokenStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        if (kDebugMode) {
          print('🔐 Token envoyé: Bearer ${token.substring(0, 20)}...');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ Aucun token trouvé pour authentification');
        }
      }
    }

    return headers;
  }

  Future<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final body = utf8.decode(response.bodyBytes);
    
    // Logging pour debugging en mode debug uniquement
    if (kDebugMode) {
      print('=== API DEBUG ===');
      print('URL: ${response.request?.url}');
      print('Status: ${response.statusCode}');
      print('Body: ${body.length > 500 ? body.substring(0, 500) + '...' : body}');
      print('================');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonData = json.decode(body) as Map<String, dynamic>;
        final result = fromJson(jsonData);
        return result;
      } catch (e) {
        if (kDebugMode) {
          print('JSON Parsing Error: $e');
          print('Error type: ${e.runtimeType}');
          print('Raw JSON: ${body.length > 200 ? body.substring(0, 200) + '...' : body}');
        }
        throw ApiException(
          message: 'Erreur de format de réponse du serveur',
          statusCode: response.statusCode,
        );
      }
    } else {
      Map<String, dynamic>? errorData;
      String errorMessage = 'Erreur du serveur (${response.statusCode})';
      
      try {
        errorData = json.decode(body) as Map<String, dynamic>;
        
        // Extraire le message d'erreur de différentes structures possibles
        if (errorData['message'] != null) {
          errorMessage = errorData['message'] as String;
        } else if (errorData['error'] != null) {
          errorMessage = errorData['error'] as String;
        } else if (errorData['errors'] != null && errorData['errors'] is Map) {
          // Pour les erreurs de validation Laravel
          final errors = errorData['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstField = errors.keys.first;
            final fieldErrors = errors[firstField];
            if (fieldErrors is List && fieldErrors.isNotEmpty) {
              errorMessage = fieldErrors.first.toString();
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing error response: $e');
        }
        // Si ce n'est pas du JSON, utiliser le body directement si court
        if (body.length < 100 && body.isNotEmpty) {
          errorMessage = body;
        }
      }
      
      throw ApiException(
        message: errorMessage,
        statusCode: response.statusCode,
        errors: errorData?['errors'],
      );
    }
  }

  // Authentication Methods
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConstants.login),
        headers: await _getHeaders(includeAuth: false),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response, (json) => AuthResponse.fromJson(json));
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw ApiException(
          message: 'La connexion a expiré. Veuillez réessayer.',
          statusCode: 408,
        );
      }
      rethrow;
    }
  }

  Future<AuthResponse> loginWithIdentifier(String identifier, String password) async {
    try {
      // Déterminer si l'identifiant est un email ou un téléphone
      bool isEmail = identifier.contains('@');

      final response = await _client.post(
        Uri.parse(ApiConstants.login),
        headers: await _getHeaders(includeAuth: false),
        body: json.encode({
          if (isEmail) 'email': identifier else 'phone': identifier,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response, (json) => AuthResponse.fromJson(json));
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw ApiException(
          message: 'La connexion a expiré. Veuillez réessayer.',
          statusCode: 408,
        );
      }
      rethrow;
    }
  }

  /// Social Authentication - Login with OAuth tokens from native SDKs
  Future<AuthResponse> loginWithSocial({
    required String provider,
    String? accessToken,
    String? idToken,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/social/mobile'),
        headers: await _getHeaders(includeAuth: false),
        body: json.encode({
          'provider': provider,
          if (accessToken != null) 'access_token': accessToken,
          if (idToken != null) 'id_token': idToken,
        }),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response, (json) => AuthResponse.fromJson(json));
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw ApiException(
          message: 'La connexion a expiré. Veuillez réessayer.',
          statusCode: 408,
        );
      }
      rethrow;
    }
  }

  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    int? countryId,
    int? languageId,
  }) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.register),
      headers: await _getHeaders(includeAuth: false),
      body: json.encode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'phone': phone,
        'country_id': countryId,
        'language_id': languageId,
        // Le rôle sera déterminé côté serveur selon account_type
        'account_type': 'personal',
        'can_sell': false,
        'can_buy': true,
      }),
    );

    return _handleResponse(response, (json) => AuthResponse.fromJson(json));
  }

  Future<User> getMe({bool autoRemoveTokenOn401 = true}) async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.me),
        headers: await _getHeaders(),
      );

      return _handleResponse(response, (json) => User.fromJson(json['user']));
    } catch (e) {
      if (e is ApiException && e.statusCode == 401 && autoRemoveTokenOn401) {
        // Token expiré ou invalide, on le supprime
        await SecureTokenStorage.removeToken();
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    final response = await _client.post(
      Uri.parse(ApiConstants.logout),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      await SecureTokenStorage.removeToken();
    }
  }

  // Countries Methods
  Future<List<Country>> getCountries({bool activeOnly = true}) async {
    final uri = Uri.parse(ApiConstants.countries).replace(
      queryParameters: activeOnly ? {'active_only': 'true'} : null,
    );

    final response = await _client.get(
      uri,
      headers: await _getHeaders(includeAuth: false),
    );

    return _handleResponse(response, (json) {
      final countries = json['countries'] as List;
      return countries.map((c) => Country.fromJson(c)).toList();
    });
  }

  Future<Country> getCountry(int id) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.country(id)),
      headers: await _getHeaders(includeAuth: false),
    );

    return _handleResponse(response, (json) => Country.fromJson(json['country']));
  }

  // Languages Methods
  Future<List<Language>> getLanguages({bool activeOnly = true}) async {
    final uri = Uri.parse(ApiConstants.languages).replace(
      queryParameters: activeOnly ? {'active_only': 'true'} : null,
    );

    final response = await _client.get(
      uri,
      headers: await _getHeaders(includeAuth: false),
    );

    return _handleResponse(response, (json) {
      final languages = json['languages'] as List;
      return languages.map((l) => Language.fromJson(l)).toList();
    });
  }

  Future<Language> getDefaultLanguage() async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.defaultLanguage),
        headers: await _getHeaders(includeAuth: false),
      );

      return _handleResponse(response, (json) => Language.fromJson(json['language']));
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        // Si pas de langue par défaut configurée, on récupère la première langue disponible
        final languages = await getLanguages();
        if (languages.isNotEmpty) {
          return languages.first;
        }
        
        // Si aucune langue n'existe, essayer d'initialiser les langues par défaut
        try {
          await initializeLanguages();
          final newLanguages = await getLanguages();
          if (newLanguages.isNotEmpty) {
            return newLanguages.first;
          }
        } catch (initError) {
          if (kDebugMode) {
            print('Erreur lors de l\'initialisation des langues: $initError');
          }
        }
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> initializeLanguages() async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/api/languages/initialize'),
      headers: await _getHeaders(includeAuth: false),
    );

    return _handleResponse(response, (json) => json);
  }

  // Categories Methods
  Future<List<cat.Category>> getCategories({bool parentOnly = false}) async {
    final uri = Uri.parse(ApiConstants.categories).replace(
      queryParameters: parentOnly ? {'parent_only': 'true'} : null,
    );

    final response = await _client.get(
      uri,
      headers: await _getHeaders(includeAuth: false),
    );

    return _handleResponse(response, (json) {
      final categories = json['categories'];
      if (categories == null || categories is! List) return <cat.Category>[];
      
      return categories.map((c) => cat.Category.fromJson(c)).toList();
    });
  }

  // Products Methods
  Future<List<Product>> getProducts({int page = 1, int perPage = 20}) async {
    final uri = Uri.parse(ApiConstants.products).replace(
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        'with': 'merchant,category',
      },
    );

    final response = await _client.get(
      uri,
      headers: await _getHeaders(includeAuth: false),
    );

    return _handleResponse(response, (json) {
      // Check if it's the new API structure with "success" and "data"
      if (json.containsKey('success') && json.containsKey('data')) {
        final data = json['data'];
        if (data is Map<String, dynamic> && data.containsKey('products')) {
          final products = data['products'];
          if (products is List) {
            return products.map((p) => Product.fromJson(p)).toList();
          }
        }
      }
      
      // Fallback to old structure
      final productsData = json['products'];
      if (productsData == null || productsData is! Map<String, dynamic>) {
        return <Product>[];
      }
      
      final products = productsData['data'];
      if (products == null || products is! List) return <Product>[];
      
      return products.map((p) {
        try {
          final productMap = p as Map<String, dynamic>;
          if (kDebugMode) {
            print('🔍 Parsing product: ${productMap['name']} (ID: ${productMap['id']})');
          }
          return Product.fromJson(productMap);
        } catch (e, stackTrace) {
          if (kDebugMode) {
            print('❌ Error parsing product in getProducts: $e');
            print('📋 Product data: $p');
            print('📍 Stack trace: $stackTrace');
          }
          return null;
        }
      }).where((p) => p != null).cast<Product>().toList();
    });
  }

  Future<List<Product>> getFeaturedProducts() async {
    final uri = Uri.parse(ApiConstants.featuredProducts).replace(
      queryParameters: {
        'with': 'merchant,category',
      },
    );

    final response = await _client.get(
      uri,
      headers: await _getHeaders(includeAuth: false),
    );

    return _handleResponse(response, (json) {
      try {
        // Check if it's the new API structure with "success" and "data"
        if (json.containsKey('success') && json.containsKey('data')) {
          final data = json['data'];
          if (data is List) {
            return data.map((p) {
              try {
                return Product.fromJson(p as Map<String, dynamic>);
              } catch (e) {
                if (kDebugMode) {
                  print('Error parsing featured product: $e');
                  print('Product data: $p');
                }
                return null;
              }
            }).where((p) => p != null).cast<Product>().toList();
          }
        }
        
        // Fallback to old structure
        final products = json['products'];
        if (products == null || products is! List) return <Product>[];
        
        return products.map((p) {
          try {
            return Product.fromJson(p as Map<String, dynamic>);
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing featured product: $e');
              print('Product data: $p');
            }
            return null;
          }
        }).where((p) => p != null).cast<Product>().toList();
      } catch (e) {
        if (kDebugMode) {
          print('Error in getFeaturedProducts parsing: $e');
        }
        return <Product>[];
      }
    });
  }

  Future<Product> getProduct(int id) async {
    final uri = Uri.parse(ApiConstants.product(id)).replace(
      queryParameters: {
        'with': 'merchant,category,activeLottery',
      },
    );

    final response = await _client.get(
      uri,
      headers: await _getHeaders(includeAuth: false),
    );

    return _handleResponse(response, (json) {
      // Check if it's the new API structure with "success" and "data"
      if (json.containsKey('success') && json.containsKey('data')) {
        final data = json['data'];
        if (data != null) {
          return Product.fromJson(data as Map<String, dynamic>);
        }
      }

      // Fallback to old structure
      final productData = json['product'];
      if (productData != null) {
        return Product.fromJson(productData as Map<String, dynamic>);
      }

      throw Exception('No product data found in response');
    });
  }

  // Lotteries Methods
  Future<List<Lottery>> getActiveLotteries() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.activeLotteries),
      headers: await _getHeaders(includeAuth: false),
    );

    return _handleResponse(response, (json) {
      // Check if it's the new API structure with "success" and "data"
      if (json.containsKey('success') && json.containsKey('data')) {
        final data = json['data'];
        if (data is Map<String, dynamic> && data.containsKey('lotteries')) {
          final lotteries = data['lotteries'];
          if (lotteries is List) {
            return lotteries.map((l) {
              try {
                return Lottery.fromJson(l as Map<String, dynamic>);
              } catch (e) {
                if (kDebugMode) {
                  print('Error parsing lottery: $e');
                  print('Lottery data: $l');
                }
                return null;
              }
            }).where((l) => l != null).cast<Lottery>().toList();
          }
        }
      }
      
      // Fallback to old structure
      final lotteries = json['lotteries'];
      if (lotteries == null || lotteries is! List) return <Lottery>[];
      
      return lotteries.map((l) {
        try {
          return Lottery.fromJson(l as Map<String, dynamic>);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing lottery fallback: $e');
            print('Lottery data: $l');
          }
          return null;
        }
      }).where((l) => l != null).cast<Lottery>().toList();
    });
  }

  Future<Lottery> getLottery(int id) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.lottery(id)),
      headers: await _getHeaders(includeAuth: false),
    );

    return _handleResponse(response, (json) => Lottery.fromJson(json['lottery']));
  }

  Future<Map<String, dynamic>> buyLotteryTicket(int lotteryId, int quantity) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.buyLotteryTicket(lotteryId)),
      headers: await _getHeaders(),
      body: json.encode({
        'quantity': quantity,
      }),
    );

    return _handleResponse(response, (json) => json);
  }

  // New ticket purchase system
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, String? token) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Si l'endpoint commence par /api, on utilise la base URL sans /api
    final url = endpoint.startsWith('/api') 
        ? 'https://koumbaya.com$endpoint'
        : '${ApiConstants.baseUrl}$endpoint';

    final response = await _client.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(data),
    );

    final body = utf8.decode(response.bodyBytes);
    final jsonData = json.decode(body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonData;
    } else {
      throw ApiException(
        message: jsonData['message'] ?? 'Une erreur est survenue',
        statusCode: response.statusCode,
        errors: jsonData['errors'],
      );
    }
  }

  Future<Map<String, dynamic>> get(String endpoint, String? token) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Si l'endpoint commence par /api, on utilise la base URL sans /api
    final url = endpoint.startsWith('/api') 
        ? 'https://koumbaya.com$endpoint'
        : '${ApiConstants.baseUrl}$endpoint';

    final response = await _client.get(
      Uri.parse(url),
      headers: headers,
    );

    final body = utf8.decode(response.bodyBytes);
    final jsonData = json.decode(body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonData;
    } else {
      throw ApiException(
        message: jsonData['message'] ?? 'Une erreur est survenue',
        statusCode: response.statusCode,
        errors: jsonData['errors'],
      );
    }
  }

  // User Tickets Methods
  Future<List<TicketWithDetails>> getUserTicketsWithDetails() async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.userTickets),
        headers: await _getHeaders(),
      );

      return _handleResponse(response, (json) {
        final tickets = json['data'] as List? ?? [];
        return tickets.map((t) {
          try {
            return TicketWithDetails.fromJson(t as Map<String, dynamic>);
          } catch (e) {
            if (kDebugMode) {
              print('Erreur parsing ticket: $e');
              print('Données ticket: $t');
            }
            // En cas d'erreur, on crée un objet minimal
            return TicketWithDetails(
              ticket: LotteryTicket.fromJson(t as Map<String, dynamic>),
              lottery: (t as Map<String, dynamic>)['lottery'] != null 
                ? Lottery.fromJson((t as Map<String, dynamic>)['lottery']) 
                : null,
              product: null,
            );
          }
        }).toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur getUserTicketsWithDetails: $e');
      }
      if (e is ApiException && e.statusCode == 401) {
        // Token expiré ou invalide, on le supprime
        await SecureTokenStorage.removeToken();
      }
      rethrow;
    }
  }

  Future<List<LotteryTicket>> getUserTickets() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.userTickets),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      final tickets = json['data'] as List? ?? json['tickets'] as List? ?? [];
      return tickets.map((t) => LotteryTicket.fromJson(t)).toList();
    });
  }

  // Profile Management
  Future<User> updateProfile(Map<String, dynamic> updateData) async {
    final response = await _client.put(
      Uri.parse('${ApiConstants.baseUrl}/user/profile'),
      headers: await _getHeaders(),
      body: json.encode(updateData),
    );

    return _handleResponse(response, (json) {
      try {
        if (kDebugMode) {
          print('🔍 Parsing updateProfile response...');
          print('Full JSON: $json');
        }
        
        final userData = json['data']?['user'] ?? json['data'] ?? json['user'];
        
        if (kDebugMode) {
          print('User data to parse: $userData');
        }
        
        if (userData == null) {
          throw Exception('No user data found in response');
        }
        
        return User.fromJson(userData as Map<String, dynamic>);
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error parsing user in updateProfile: $e');
          print('JSON structure: $json');
        }
        rethrow;
      }
    });
  }

  Future<void> changePassword(Map<String, dynamic> passwordData) async {
    final response = await _client.put(
      Uri.parse('${ApiConstants.baseUrl}/user/password'),
      headers: await _getHeaders(),
      body: json.encode(passwordData),
    );
    
    // Pour le changement de mot de passe, on vérifie juste que la réponse est réussie
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = utf8.decode(response.bodyBytes);
      try {
        final errorData = json.decode(body) as Map<String, dynamic>;
        throw ApiException(
          message: errorData['message'] ?? errorData['error'] ?? 'Erreur lors du changement de mot de passe',
          statusCode: response.statusCode,
          errors: errorData['errors'],
        );
      } catch (e) {
        throw ApiException(
          message: 'Erreur du serveur (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    }
  }

  // Direct Product Purchase - Creates an order via payment initiation
  Future<Map<String, dynamic>> buyProductDirectly(int productId, int quantity) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.initiatePayment),
      headers: await _getHeaders(),
      body: json.encode({
        'type': 'product_purchase',
        'product_id': productId,
        'quantity': quantity,
      }),
    );

    return _handleResponse(response, (json) => json);
  }

  // Password Reset Methods
  Future<Map<String, dynamic>> sendPasswordResetCode({
    required String identifier,
    required bool isEmail,
  }) async {
    return await sendOtpCode(
      identifier: identifier,
      isEmail: isEmail,
      purpose: 'password_reset',
    );
  }

  /// Méthode générale pour envoyer un OTP
  Future<Map<String, dynamic>> sendOtpCode({
    required String identifier,
    required bool isEmail,
    required String purpose, // 'password_reset', 'registration', 'verification', etc.
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/otp/send'),
      headers: await _getHeaders(includeAuth: false),
      body: json.encode({
        'identifier': identifier,
        'type': isEmail ? 'email' : 'sms',
        'purpose': purpose,
      }),
    );

    return _handleResponse(response, (json) => json);
  }

  Future<Map<String, dynamic>> verifyPasswordResetCode({
    required String identifier,
    required String code,
    required bool isEmail,
  }) async {
    // Pour la vérification, on ne fait rien car l'API vérifie le code lors du reset
    // On retourne juste un succès pour permettre le changement de mot de passe
    return {'success': true};
  }

  Future<Map<String, dynamic>> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
    required String passwordConfirmation,
    required bool isEmail,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/reset-password'),
      headers: await _getHeaders(includeAuth: false),
      body: json.encode({
        'identifier': identifier,
        'otp': code,
        'password': newPassword,
        'password_confirmation': passwordConfirmation,
      }),
    );

    return _handleResponse(response, (json) => json);
  }

  // ===== GESTION DES COMMANDES =====

  /// Récupérer la liste des commandes de l'utilisateur
  Future<ApiResponse<List<dynamic>>> getOrders({int page = 1, String? status}) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': '20',
    };
    
    if (status != null) {
      queryParams['status'] = status;
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/orders').replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(
      uri,
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      return ApiResponse<List<dynamic>>(
        data: json['data'] as List<dynamic>? ?? [],
        message: json['message'] as String?,
        success: json['success'] as bool? ?? false,
        errors: (json['errors'] as List<dynamic>?)?.cast<String>(),
        meta: json['pagination'] as Map<String, dynamic>?,
      );
    });
  }

  /// Récupérer une commande spécifique par son numéro
  Future<ApiResponse<Map<String, dynamic>>> getOrder(String orderNumber) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/orders/$orderNumber'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      return ApiResponse<Map<String, dynamic>>(
        data: json['data'] as Map<String, dynamic>?,
        message: json['message'] as String?,
        success: json['success'] as bool? ?? false,
        errors: (json['errors'] as List<dynamic>?)?.cast<String>(),
      );
    });
  }

  /// Annuler une commande
  Future<ApiResponse<Map<String, dynamic>>> cancelOrder(String orderNumber) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/orders/$orderNumber/cancel'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      return ApiResponse<Map<String, dynamic>>(
        data: json['data'] as Map<String, dynamic>?,
        message: json['message'] as String?,
        success: json['success'] as bool? ?? false,
        errors: (json['errors'] as List<dynamic>?)?.cast<String>(),
      );
    });
  }

  /// Relancer le paiement d'une commande
  Future<ApiResponse<Map<String, dynamic>>> retryOrderPayment(String orderNumber) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/orders/$orderNumber/retry-payment'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      return ApiResponse<Map<String, dynamic>>(
        data: json['data'] as Map<String, dynamic>?,
        message: json['message'] as String?,
        success: json['success'] as bool? ?? false,
        errors: (json['errors'] as List<dynamic>?)?.cast<String>(),
      );
    });
  }

  /// Suivre une commande par son numéro (pour les utilisateurs non authentifiés aussi)
  Future<ApiResponse<Map<String, dynamic>>> trackOrder(String orderNumber, {String? phone}) async {
    final queryParams = <String, String>{};
    
    if (phone != null) {
      queryParams['phone'] = phone;
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/orders/track/$orderNumber').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final response = await _client.get(
      uri,
      headers: await _getHeaders(includeAuth: false),
    );

    return _handleResponse(response, (json) {
      return ApiResponse<Map<String, dynamic>>(
        data: json['data'] as Map<String, dynamic>?,
        message: json['message'] as String?,
        success: json['success'] as bool? ?? false,
        errors: (json['errors'] as List<dynamic>?)?.cast<String>(),
      );
    });
  }

  // ===== GESTION DES TRANSACTIONS =====

  /// Récupérer la liste des transactions de l'utilisateur
  Future<ApiResponse<List<dynamic>>> getTransactions({int page = 1, String? type, String? status}) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': '20',
    };
    
    if (type != null) {
      queryParams['type'] = type;
    }
    
    if (status != null) {
      queryParams['status'] = status;
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/transactions').replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(
      uri,
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      return ApiResponse<List<dynamic>>(
        data: json['data'] as List<dynamic>? ?? [],
        message: json['message'] as String?,
        success: json['success'] as bool? ?? false,
        errors: (json['errors'] as List<dynamic>?)?.cast<String>(),
        meta: json['pagination'] as Map<String, dynamic>?,
      );
    });
  }

  /// Récupérer une transaction spécifique
  Future<ApiResponse<Map<String, dynamic>>> getTransaction(int transactionId) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/transactions/$transactionId'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      return ApiResponse<Map<String, dynamic>>(
        data: json['data'] as Map<String, dynamic>?,
        message: json['message'] as String?,
        success: json['success'] as bool? ?? false,
        errors: (json['errors'] as List<dynamic>?)?.cast<String>(),
      );
    });
  }

  /// Annuler une transaction
  Future<ApiResponse<Map<String, dynamic>>> cancelTransaction(int transactionId) async {
    final response = await _client.patch(
      Uri.parse('${ApiConstants.baseUrl}/transactions/$transactionId/cancel'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      return ApiResponse<Map<String, dynamic>>(
        data: json['data'] as Map<String, dynamic>?,
        message: json['message'] as String?,
        success: json['success'] as bool? ?? false,
        errors: (json['errors'] as List<dynamic>?)?.cast<String>(),
      );
    });
  }

  // Confirmer la livraison d'une commande
  Future<ApiResponse<Map<String, dynamic>>> confirmOrderDelivery(String orderNumber, {String? notes}) async {
    final body = <String, dynamic>{};
    if (notes != null && notes.isNotEmpty) {
      body['notes'] = notes;
    }

    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/orders/$orderNumber/confirm-delivery'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    
    return _handleResponse(response, (json) {
      return ApiResponse<Map<String, dynamic>>(
        data: json['data'] as Map<String, dynamic>?,
        message: json['message'] as String?,
        success: json['success'] as bool? ?? false,
        errors: (json['errors'] as List<dynamic>?)?.cast<String>(),
      );
    });
  }

  // ===== NOTIFICATIONS =====

  /// Récupérer la liste des notifications de l'utilisateur
  Future<NotificationsResponse> getNotifications({int page = 1, bool unreadOnly = false}) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': '20',
    };
    
    if (unreadOnly) {
      queryParams['unread_only'] = 'true';
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/notifications').replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(
      uri,
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      return NotificationsResponse.fromJson(json);
    });
  }

  /// Marquer une notification comme lue
  Future<void> markNotificationAsRead(String notificationId) async {
    final response = await _client.patch(
      Uri.parse('${ApiConstants.baseUrl}/notifications/$notificationId/read'),
      headers: await _getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = utf8.decode(response.bodyBytes);
      try {
        final errorData = json.decode(body) as Map<String, dynamic>;
        throw ApiException(
          message: errorData['message'] ?? 'Erreur lors du marquage de la notification',
          statusCode: response.statusCode,
          errors: errorData['errors'],
        );
      } catch (e) {
        throw ApiException(
          message: 'Erreur du serveur (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllNotificationsAsRead() async {
    final response = await _client.patch(
      Uri.parse('${ApiConstants.baseUrl}/notifications/read-all'),
      headers: await _getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = utf8.decode(response.bodyBytes);
      try {
        final errorData = json.decode(body) as Map<String, dynamic>;
        throw ApiException(
          message: errorData['message'] ?? 'Erreur lors du marquage des notifications',
          statusCode: response.statusCode,
          errors: errorData['errors'],
        );
      } catch (e) {
        throw ApiException(
          message: 'Erreur du serveur (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    }
  }

  /// Supprimer une notification
  Future<void> deleteNotification(String notificationId) async {
    final response = await _client.delete(
      Uri.parse('${ApiConstants.baseUrl}/notifications/$notificationId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = utf8.decode(response.bodyBytes);
      try {
        final errorData = json.decode(body) as Map<String, dynamic>;
        throw ApiException(
          message: errorData['message'] ?? 'Erreur lors de la suppression de la notification',
          statusCode: response.statusCode,
          errors: errorData['errors'],
        );
      } catch (e) {
        throw ApiException(
          message: 'Erreur du serveur (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    }
  }

  /// Récupérer le nombre de notifications non lues
  Future<int> getUnreadNotificationsCount() async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/notifications/unread-count'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      return json['count'] as int? ?? 0;
    });
  }

  // ===== BECOME SELLER =====

  /// Permet à un utilisateur de devenir vendeur individuel
  Future<Map<String, dynamic>> becomeSeller(String sellerType) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/user/become-seller'),
      headers: await _getHeaders(),
      body: json.encode({
        'seller_type': sellerType,
      }),
    );

    return _handleResponse(response, (json) => json);
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}