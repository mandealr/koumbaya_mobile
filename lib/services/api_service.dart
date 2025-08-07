import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/api_response.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../models/country.dart';
import '../models/language.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/lottery.dart';
import '../utils/token_storage.dart';

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
      final token = await TokenStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final body = utf8.decode(response.bodyBytes);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonData = json.decode(body) as Map<String, dynamic>;
      return fromJson(jsonData);
    } else {
      final errorData = json.decode(body) as Map<String, dynamic>;
      throw ApiException(
        message: errorData['message'] ?? 'Une erreur est survenue',
        statusCode: response.statusCode,
        errors: errorData['errors'],
      );
    }
  }

  // Authentication Methods
  Future<AuthResponse> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.login),
      headers: await _getHeaders(includeAuth: false),
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    return _handleResponse(response, (json) => AuthResponse.fromJson(json));
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

  Future<User> getMe() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.me),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) => User.fromJson(json['user']));
  }

  Future<void> logout() async {
    final response = await _client.post(
      Uri.parse(ApiConstants.logout),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      await TokenStorage.removeToken();
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
    final response = await _client.get(
      Uri.parse(ApiConstants.defaultLanguage),
      headers: await _getHeaders(includeAuth: false),
    );

    return _handleResponse(response, (json) => Language.fromJson(json['language']));
  }

  // Categories Methods
  Future<List<Category>> getCategories({bool parentOnly = false}) async {
    final uri = Uri.parse(ApiConstants.categories).replace(
      queryParameters: parentOnly ? {'parent_only': 'true'} : null,
    );

    final response = await _client.get(
      uri,
      headers: await _getHeaders(includeAuth: false),
    );

    return _handleResponse(response, (json) {
      final categories = json['categories'] as List;
      return categories.map((c) => Category.fromJson(c)).toList();
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
      final products = json['products']['data'] as List;
      return products.map((p) => Product.fromJson(p)).toList();
    });
  }

  Future<List<Product>> getFeaturedProducts() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.featuredProducts),
      headers: await _getHeaders(includeAuth: false),
    );

    return _handleResponse(response, (json) {
      final products = json['products'] as List;
      return products.map((p) => Product.fromJson(p)).toList();
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
      final lotteries = json['lotteries'] as List;
      return lotteries.map((l) => Lottery.fromJson(l)).toList();
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