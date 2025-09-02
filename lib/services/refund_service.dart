import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/refund.dart';
import '../models/transaction.dart';
import '../utils/token_storage.dart';
import 'api_service.dart';

class RefundService {
  static final RefundService _instance = RefundService._internal();
  factory RefundService() => _instance;
  RefundService._internal();

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

  /// Récupère les demandes de remboursement de l'utilisateur
  Future<List<Refund>> getUserRefunds({
    int page = 1,
    int perPage = 20,
    String? status,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (status != null) queryParams['status'] = status;

    final uri = Uri.parse('${ApiConstants.baseUrl}/refunds')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      final refunds = json['data'] as List? ?? json['refunds'] as List? ?? [];
      return refunds.map((r) => Refund.fromJson(r)).toList();
    });
  }

  /// Récupère une demande de remboursement spécifique
  Future<Refund> getRefund(int refundId) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/refunds/$refundId'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      final refundData = json['data'] ?? json['refund'];
      return Refund.fromJson(refundData);
    });
  }

  /// Crée une nouvelle demande de remboursement
  Future<Refund> createRefund({
    required int transactionId,
    required String reason,
    String? description,
  }) async {
    final requestBody = {
      'transaction_id': transactionId,
      'reason': reason,
      if (description != null && description.isNotEmpty) 'description': description,
    };

    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/refunds'),
      headers: await _getHeaders(),
      body: json.encode(requestBody),
    );

    return _handleResponse(response, (json) {
      final refundData = json['data'] ?? json['refund'];
      return Refund.fromJson(refundData);
    });
  }

  /// Annule une demande de remboursement (si en attente)
  Future<Refund> cancelRefund(int refundId) async {
    final response = await _client.patch(
      Uri.parse('${ApiConstants.baseUrl}/refunds/$refundId/cancel'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      final refundData = json['data'] ?? json['refund'];
      return Refund.fromJson(refundData);
    });
  }

  /// Récupère les transactions éligibles pour un remboursement
  Future<List<Transaction>> getEligibleTransactions() async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/refunds/eligible-transactions'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      final transactions = json['data'] as List? ?? json['transactions'] as List? ?? [];
      return transactions.map((t) => Transaction.fromJson(t)).toList();
    });
  }

  /// Récupère les statistiques des remboursements
  Future<Map<String, dynamic>> getRefundStats() async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/refunds/stats'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) => json['data'] ?? json);
  }

  /// Récupère les raisons de remboursement disponibles
  List<Map<String, String>> getRefundReasons() {
    return [
      {'value': 'product_not_received', 'label': 'Produit non reçu'},
      {'value': 'product_defective', 'label': 'Produit défectueux'},
      {'value': 'wrong_product', 'label': 'Mauvais produit reçu'},
      {'value': 'lottery_cancelled', 'label': 'Tombola annulée'},
      {'value': 'duplicate_payment', 'label': 'Paiement en double'},
      {'value': 'other', 'label': 'Autre raison'},
    ];
  }

  void dispose() {
    _client.close();
  }
}