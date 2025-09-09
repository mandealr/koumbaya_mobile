import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/transaction.dart';
import '../models/product.dart';
import '../models/lottery_ticket.dart';
import '../utils/secure_token_storage.dart';
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
      final token = await SecureTokenStorage.getToken();
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
    
    // Logging for debugging in debug mode only
    if (kDebugMode) {
      print('=== TRANSACTION API DEBUG ===');
      print('URL: ${response.request?.url}');
      print('Status: ${response.statusCode}');
      print('Body: $body');
      print('============================');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonData = json.decode(body) as Map<String, dynamic>;
        return fromJson(jsonData);
      } catch (e) {
        if (kDebugMode) {
          print('Transaction JSON Parsing Error: $e');
          print('Raw JSON: $body');
        }
        throw ApiException(
          message: 'Erreur de format de réponse du serveur: $e',
          statusCode: response.statusCode,
        );
      }
    } else {
      final errorData = json.decode(body) as Map<String, dynamic>;
      throw ApiException(
        message: errorData['message'] ?? 'Une erreur est survenue',
        statusCode: response.statusCode,
        errors: errorData['errors'],
      );
    }
  }

  /// Récupère l'historique des paiements de l'utilisateur connecté
  /// Utilise les endpoints existants /user/tickets et /orders
  Future<List<Transaction>> getUserTransactions({
    int page = 1,
    int perPage = 20,
    String? type,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (kDebugMode) {
        print('💰 Starting getUserTransactions - page: $page, perPage: $perPage, type: $type, status: $status');
      }
      
      final List<Transaction> allTransactions = [];
      
      // Récupérer l'historique des paiements via les endpoints disponibles
      if (kDebugMode) {
        print('💰 Step 1: Fetching orders...');
      }
      await _getOrdersAsTransactions(allTransactions, page: page, status: status);
      
      if (kDebugMode) {
        print('💰 Step 2: Fetching tickets...');
      }
      await _getTicketsAsTransactions(allTransactions);
      
      if (kDebugMode) {
        print('💰 Total transactions before filtering: ${allTransactions.length}');
      }
      
      // Appliquer les filtres
      var filteredTransactions = allTransactions;
      
      if (type != null) {
        filteredTransactions = filteredTransactions.where((t) => t.type == type).toList();
      }
      
      if (status != null) {
        filteredTransactions = filteredTransactions.where((t) => t.status == status).toList();
      }
      
      if (startDate != null) {
        filteredTransactions = filteredTransactions.where((t) => t.createdAt.isAfter(startDate)).toList();
      }
      
      if (endDate != null) {
        filteredTransactions = filteredTransactions.where((t) => t.createdAt.isBefore(endDate)).toList();
      }
      
      // Trier par date (plus récent en premier)
      filteredTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Pagination
      final startIndex = (page - 1) * perPage;
      final endIndex = (startIndex + perPage).clamp(0, filteredTransactions.length);
      
      if (startIndex >= filteredTransactions.length) {
        return [];
      }
      
      return filteredTransactions.sublist(startIndex, endIndex);
      
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user payment history: $e');
      }
      rethrow;
    }
  }
  
  /// Récupère les commandes et les convertit en transactions
  Future<void> _getOrdersAsTransactions(List<Transaction> transactions, {int page = 1, String? status}) async {
    try {
      if (kDebugMode) {
        print('🛒 Fetching orders for transactions...');
      }
      
      // Use existing working API method from ApiService
      final apiService = ApiService();
      final response = await apiService.getOrders(page: page, status: status);
      
      if (kDebugMode) {
        print('🛒 Orders API response success: ${response.success}');
        print('🛒 Found ${response.data?.length ?? 0} orders to convert to transactions');
      }
      
      if (response.success && response.data != null) {
        for (var orderData in response.data!) {
          try {
            final order = orderData as Map<String, dynamic>;
            
            if (kDebugMode) {
              print('🛒 Converting order to transaction: ${order['order_number'] ?? order['id']}');
            }
            
            // Convertir la commande en transaction
            final transaction = _convertOrderToTransaction(order);
            transactions.add(transaction);
          } catch (e) {
            if (kDebugMode) {
              print('❌ Error converting order to transaction: $e');
              print('Order data: $orderData');
            }
          }
        }
        
        if (kDebugMode) {
          print('🛒 Successfully converted orders to transactions');
        }
      } else {
        if (kDebugMode) {
          print('❌ Orders API failed or returned no data');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting orders: $e');
      }
    }
  }
  
  /// Récupère les tickets et les convertit en transactions
  Future<void> _getTicketsAsTransactions(List<Transaction> transactions) async {
    try {
      if (kDebugMode) {
        print('🎫 Fetching tickets for transactions...');
      }
      
      // Use existing working API method from ApiService
      final apiService = ApiService();
      final tickets = await apiService.getUserTickets();
      
      if (kDebugMode) {
        print('🎫 Found ${tickets.length} tickets to convert to transactions');
      }
      
      int initialTransactionCount = transactions.length;
      
      for (var ticket in tickets) {
        try {
          if (kDebugMode) {
            print('🎫 Converting ticket to transaction: ${ticket.ticketNumber}');
          }
          
          // Convertir le ticket en transaction
          final transaction = _convertLotteryTicketToTransaction(ticket);
          transactions.add(transaction);
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error converting ticket to transaction: $e');
            print('Ticket: ${ticket.ticketNumber}');
          }
        }
      }
      
      if (kDebugMode) {
        print('🎫 Successfully converted ${transactions.length - initialTransactionCount} tickets to transactions');
        print('🎫 Total transactions now: ${transactions.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting tickets: $e');
      }
    }
  }
  
  /// Convertit une commande en transaction
  Transaction _convertOrderToTransaction(Map<String, dynamic> order) {
    try {
      // Safe parsing helpers
      int _safeParseInt(dynamic value, int defaultValue) {
        if (value == null) return defaultValue;
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value) ?? defaultValue;
        return defaultValue;
      }
      
      int? _safeParseNullableInt(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value);
        return null;
      }
      
      double _safeParseDouble(dynamic value, double defaultValue) {
        if (value == null) return defaultValue;
        if (value is double) return value;
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? defaultValue;
        return defaultValue;
      }
      
      String _safeParseString(dynamic value, String defaultValue) {
        if (value == null) return defaultValue;
        return value.toString();
      }
      
      String? _safeParseNullableString(dynamic value) {
        if (value == null) return null;
        if (value is String && value.isEmpty) return null;
        return value.toString();
      }
      
      DateTime _safeParseDateTime(dynamic value, DateTime defaultValue) {
        if (value == null) return defaultValue;
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (e) {
            return defaultValue;
          }
        }
        return defaultValue;
      }

      // Extract product_id and lottery_id from nested objects if not directly available
      int? productId = _safeParseNullableInt(order['product_id']);
      int? lotteryId = _safeParseNullableInt(order['lottery_id']);
      
      // If not found directly, try to extract from nested product/lottery
      if (productId == null && order['product'] != null) {
        productId = _safeParseNullableInt(order['product']['id']);
      }
      if (lotteryId == null && order['lottery'] != null) {
        lotteryId = _safeParseNullableInt(order['lottery']['id']);
      }

      return Transaction(
        id: _safeParseInt(order['id'], 0),
        userId: _safeParseInt(order['user_id'] ?? order['customer_id'] ?? 0, 0),
        type: order['type'] == 'lottery' ? 'lottery_ticket' : 'product_purchase',
        amount: _safeParseDouble(order['total_amount'], 0.0),
        status: _mapPaymentStatusToTransactionStatus(_safeParseNullableString(order['latest_payment_status']) ?? _safeParseString(order['status'], 'pending')),
        paymentMethod: _safeParseNullableString(order['payment_method']),
        reference: _safeParseNullableString(order['order_number']),
        paymentReference: _safeParseNullableString(order['payment_reference']),
        metadata: order['meta'] is Map<String, dynamic> ? order['meta'] as Map<String, dynamic> : null,
        productId: productId,
        lotteryId: lotteryId,
        quantity: 1, // Par défaut pour les commandes
        createdAt: _safeParseDateTime(order['created_at'], DateTime.now()),
        updatedAt: _safeParseDateTime(order['updated_at'], DateTime.now()),
        product: order['product'] is Map<String, dynamic> ? Product.fromJson(order['product'] as Map<String, dynamic>) : null,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in _convertOrderToTransaction: $e');
        print('📋 Order data: $order');
      }
      rethrow;
    }
  }
  
  /// Convertit un LotteryTicket en transaction
  Transaction _convertLotteryTicketToTransaction(LotteryTicket ticket) {
    // Si le ticket a un statut "reserved" mais qu'il a été acheté (a une date d'achat), 
    // alors il est considéré comme payé/complété
    String transactionStatus = 'pending';
    if (ticket.isPaid || ticket.purchasedAt != null) {
      transactionStatus = 'completed';
    } else if (ticket.status == 'reserved') {
      // "reserved" généralement signifie que le ticket est acheté/payé
      transactionStatus = 'completed'; 
    } else {
      transactionStatus = _mapPaymentStatusToTransactionStatus(ticket.status);
    }

    return Transaction(
      id: ticket.id + 1000000, // Offset pour éviter les conflits d'ID
      userId: ticket.userId,
      type: 'lottery_ticket',
      amount: ticket.pricePaid.toDouble(),
      status: transactionStatus,
      paymentMethod: null, // LotteryTicket n'a pas ce champ
      reference: ticket.ticketNumber,
      paymentReference: ticket.paymentReference,
      metadata: null,
      productId: null,
      lotteryId: ticket.lotteryId,
      quantity: 1,
      createdAt: ticket.createdAt,
      updatedAt: ticket.updatedAt,
      product: null,
    );
  }

  
  /// Mappe les statuts de paiement vers les statuts de transaction
  String _mapPaymentStatusToTransactionStatus(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
      case 'completed':
      case 'success':
      case 'successful':
        return 'completed';
      case 'pending':
      case 'awaiting_payment':
      case 'processing':
        return 'pending';
      case 'failed':
      case 'error':
      case 'declined':
        return 'failed';
      case 'cancelled':
      case 'expired':
      case 'canceled':
        return 'cancelled';
      default:
        return 'pending';
    }
  }

  /// Mappe les statuts de commande vers les statuts de transaction (fallback)
  String _mapOrderStatusToTransactionStatus(String orderStatus) {
    switch (orderStatus) {
      case 'paid':
      case 'fulfilled':
        return 'completed';
      case 'pending':
      case 'awaiting_payment':
        return 'pending';
      case 'failed':
        return 'failed';
      case 'cancelled':
      case 'expired':
        return 'cancelled';
      default:
        return 'pending';
    }
  }

  /// Récupère une transaction spécifique par ID
  Future<Transaction> getTransaction(int transactionId) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/transactions/$transactionId'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, (json) {
      final transactionData = json['data'] ?? json['transaction'];
      return Transaction.fromJson(transactionData);
    });
  }

  /// Récupère les statistiques des paiements
  /// Calcule les stats à partir des données disponibles
  Future<Map<String, dynamic>> getTransactionStats() async {
    try {
      // Récupérer toutes les transactions pour calculer les stats
      final transactions = await getUserTransactions(perPage: 1000); // Grande limite pour les stats
      
      double totalSpent = 0.0;
      double totalRefunded = 0.0;
      int totalCount = transactions.length;
      int completedCount = 0;
      int pendingCount = 0;
      int failedCount = 0;
      
      for (var transaction in transactions) {
        switch (transaction.status) {
          case 'completed':
            completedCount++;
            if (transaction.type == 'refund') {
              totalRefunded += transaction.amount;
            } else {
              totalSpent += transaction.amount;
            }
            break;
          case 'pending':
            pendingCount++;
            break;
          case 'failed':
          case 'cancelled':
            failedCount++;
            break;
        }
      }
      
      return {
        'total_spent': totalSpent,
        'total_refunded': totalRefunded,
        'total_transactions': totalCount,
        'completed_transactions': completedCount,
        'pending_transactions': pendingCount,
        'failed_transactions': failedCount,
        'lottery_tickets': transactions.where((t) => t.type == 'lottery_ticket').length,
        'product_purchases': transactions.where((t) => t.type == 'product_purchase').length,
        'refunds': transactions.where((t) => t.type == 'refund').length,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating transaction stats: $e');
      }
      // Retourner des stats par défaut en cas d'erreur
      return {
        'total_spent': 0.0,
        'total_refunded': 0.0,
        'total_transactions': 0,
        'completed_transactions': 0,
        'pending_transactions': 0,
        'failed_transactions': 0,
        'lottery_tickets': 0,
        'product_purchases': 0,
        'refunds': 0,
      };
    }
  }

  /// Annule une transaction (si possible)
  Future<Transaction> cancelTransaction(int transactionId) async {
    final response = await _client.patch(
      Uri.parse('${ApiConstants.baseUrl}/transactions/$transactionId/cancel'),
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

  /// Récupère les transactions de tirage spécial (achat de tickets)
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

  /// Récupère les achats directs d'articles
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