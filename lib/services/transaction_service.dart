import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/transaction.dart';
import '../utils/token_storage.dart';
import 'api_service.dart';

class TransactionService {
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

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

  /// Récupère l'historique des transactions de l'utilisateur connecté
  Future<List<Transaction>> getUserTransactions({
    int page = 1,
    int perPage = 20,
    String? type,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (type != null) queryParams['type'] = type;
    if (status != null) queryParams['status'] = status;
    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String().substring(0, 10);
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String().substring(0, 10);
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/user/transactions')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      final transactions = json['data'] as List? ?? json['transactions'] as List? ?? [];
      return transactions.map((t) => Transaction.fromJson(t)).toList();
    });
  }

  /// Récupère une transaction spécifique par ID
  Future<Transaction> getTransaction(int transactionId) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/api/user/transactions/$transactionId'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      final transactionData = json['data'] ?? json['transaction'];
      return Transaction.fromJson(transactionData);
    });
  }

  /// Récupère les statistiques des transactions
  Future<Map<String, dynamic>> getTransactionStats() async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/api/user/transactions/stats'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) => json['data'] ?? json);
  }

  /// Annule une transaction (si possible)
  Future<Transaction> cancelTransaction(int transactionId) async {
    final response = await _client.patch(
      Uri.parse('${ApiConstants.baseUrl}/api/user/transactions/$transactionId/cancel'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      final transactionData = json['data'] ?? json['transaction'];
      return Transaction.fromJson(transactionData);
    });
  }

  /// Récupère les transactions par type spécifique
  Future<List<Transaction>> getTransactionsByType(String type, {
    int page = 1,
    int perPage = 20,
  }) async {
    return getUserTransactions(
      type: type,
      page: page,
      perPage: perPage,
    );
  }

  /// Récupère les transactions de tombola (achat de tickets)
  Future<List<Transaction>> getLotteryTransactions({
    int page = 1,
    int perPage = 20,
  }) async {
    return getTransactionsByType('lottery_ticket', page: page, perPage: perPage);
  }

  /// Récupère les transactions de remboursement
  Future<List<Transaction>> getRefundTransactions({
    int page = 1,
    int perPage = 20,
  }) async {
    return getTransactionsByType('refund', page: page, perPage: perPage);
  }

  /// Récupère les achats directs de produits
  Future<List<Transaction>> getDirectPurchaseTransactions({
    int page = 1,
    int perPage = 20,
  }) async {
    return getTransactionsByType('product_purchase', page: page, perPage: perPage);
  }

  void dispose() {
    _client.close();
  }
}