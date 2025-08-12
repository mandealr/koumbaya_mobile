import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../models/country.dart';
import '../models/language.dart';
import '../models/category.dart' as cat;
import '../models/product.dart';
import '../models/lottery.dart';
import '../models/lottery_ticket.dart';
import '../models/ticket_with_details.dart';
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
      print('Body: $body');
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
        }
        throw ApiException(
          message: 'Erreur de format de réponse du serveur: $e',
          statusCode: response.statusCode,
        );
      }
    } else {
      try {
        final errorData = json.decode(body) as Map<String, dynamic>;
        throw ApiException(
          message: errorData['message'] ?? errorData['error'] ?? 'Une erreur est survenue',
          statusCode: response.statusCode,
          errors: errorData['errors'],
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error JSON Parsing Error: $e');
        }
        throw ApiException(
          message: 'Erreur du serveur (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
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

  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
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
      }
      rethrow;
    }
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
    final response = await _client.get(
      Uri.parse(ApiConstants.featuredProducts),
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
    final response = await _client.get(
      Uri.parse(ApiConstants.product(id)),
      headers: await _getHeaders(includeAuth: false),
    );

    return _handleResponse(response, (json) => Product.fromJson(json['product']));
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

    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
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

    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
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
        final tickets = json['data'] as List? ?? json['tickets'] as List? ?? [];
        return tickets.map((t) => TicketWithDetails.fromJson(t)).toList();
      });
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        // Token expiré ou invalide, on le supprime
        await SecureTokenStorage.removeToken();
      }
      rethrow;
    }
  }

  Future<List<LotteryTicket>> getUserTickets() async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/api/user/tickets'),
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
      Uri.parse('${ApiConstants.baseUrl}/api/user/profile'),
      headers: await _getHeaders(),
      body: json.encode(updateData),
    );

    return _handleResponse(response, (json) {
      final userData = json['data'] ?? json['user'];
      return User.fromJson(userData);
    });
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