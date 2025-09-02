import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  Order? _selectedOrder;
  
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Order? get selectedOrder => _selectedOrder;

  // Charger la liste des commandes
  Future<void> loadOrders({int page = 1, String? status}) async {
    try {
      _setLoading(true);
      _setError(null);
      
      if (kDebugMode) {
        print('🛒 Loading orders - page: $page, status: $status');
      }
      
      final response = await _apiService.getOrders(page: page, status: status);
      
      if (kDebugMode) {
        print('🛒 Orders API response - success: ${response.success}, data: ${response.data}');
      }
      
      if (response.success && response.data != null) {
        if (page == 1) {
          _orders = (response.data as List)
              .map((json) {
                try {
                  if (kDebugMode) {
                    print('🛒 Parsing order: $json');
                  }
                  return Order.fromJson(json);
                } catch (e) {
                  if (kDebugMode) {
                    print('❌ Error parsing order: $e');
                    print('📋 Order data: $json');
                  }
                  rethrow;
                }
              })
              .toList();
        } else {
          // Pagination - ajouter à la liste existante
          final newOrders = (response.data as List)
              .map((json) {
                try {
                  return Order.fromJson(json);
                } catch (e) {
                  if (kDebugMode) {
                    print('❌ Error parsing paginated order: $e');
                    print('📋 Order data: $json');
                  }
                  rethrow;
                }
              })
              .toList();
          _orders.addAll(newOrders);
        }
        
        if (kDebugMode) {
          print('✅ Orders loaded: ${_orders.length}');
          for (var order in _orders.take(3)) {
            print('   - ${order.orderNumber}: ${order.displayTitle} (${order.status})');
          }
        }
        
        notifyListeners();
      } else {
        if (kDebugMode) {
          print('❌ Orders loading failed: ${response.message}');
        }
        _setError(response.message ?? 'Erreur lors du chargement des commandes');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Orders loading exception: $e');
      }
      _setError('Erreur de connexion: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Charger une commande spécifique
  Future<void> loadOrder(String orderNumber) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final response = await _apiService.getOrder(orderNumber);
      
      if (response.success && response.data != null) {
        _selectedOrder = Order.fromJson(response.data!);
        notifyListeners();
      } else {
        _setError(response.message ?? 'Commande non trouvée');
      }
    } catch (e) {
      _setError('Erreur de connexion: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Annuler une commande
  Future<bool> cancelOrder(String orderNumber) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final response = await _apiService.cancelOrder(orderNumber);
      
      if (response.isSuccess) {
        // Mettre à jour la commande dans la liste locale
        final index = _orders.indexWhere((order) => order.orderNumber == orderNumber);
        if (index != -1) {
          // Créer une nouvelle instance avec le statut mis à jour
          _orders[index] = Order(
            id: _orders[index].id,
            orderNumber: _orders[index].orderNumber,
            userId: _orders[index].userId,
            type: _orders[index].type,
            productId: _orders[index].productId,
            lotteryId: _orders[index].lotteryId,
            totalAmount: _orders[index].totalAmount,
            currency: _orders[index].currency,
            status: 'cancelled',
            paymentReference: _orders[index].paymentReference,
            paidAt: _orders[index].paidAt,
            fulfilledAt: _orders[index].fulfilledAt,
            cancelledAt: DateTime.now(),
            refundedAt: _orders[index].refundedAt,
            notes: _orders[index].notes,
            meta: _orders[index].meta,
            createdAt: _orders[index].createdAt,
            updatedAt: DateTime.now(),
            product: _orders[index].product,
            lottery: _orders[index].lottery,
            user: _orders[index].user,
            payments: _orders[index].payments,
          );
        }
        
        // Mettre à jour la commande sélectionnée si c'est la même
        if (_selectedOrder?.orderNumber == orderNumber) {
          _selectedOrder = _orders[index];
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Impossible d\'annuler la commande');
        return false;
      }
    } catch (e) {
      _setError('Erreur de connexion: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Relancer un paiement
  Future<Map<String, dynamic>?> retryPayment(String orderNumber) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final response = await _apiService.retryOrderPayment(orderNumber);
      
      if (response.success && response.data != null) {
        return response.data;
      } else {
        _setError(response.message ?? 'Impossible de relancer le paiement');
        return null;
      }
    } catch (e) {
      _setError('Erreur de connexion: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Filtrer les commandes par statut
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Obtenir les commandes récentes
  List<Order> getRecentOrders({int limit = 5}) {
    final sortedOrders = List<Order>.from(_orders);
    sortedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedOrders.take(limit).toList();
  }

  // Obtenir une commande par son numéro
  Order? getOrderByNumber(String orderNumber) {
    try {
      return _orders.firstWhere((order) => order.orderNumber == orderNumber);
    } catch (e) {
      return null;
    }
  }

  // Statistiques des commandes
  Map<String, int> getOrderStats() {
    final stats = <String, int>{
      'total': _orders.length,
      'pending': 0,
      'paid': 0,
      'failed': 0,
      'cancelled': 0,
      'fulfilled': 0,
    };

    for (final order in _orders) {
      stats[order.status] = (stats[order.status] ?? 0) + 1;
    }

    return stats;
  }

  // Calculer le montant total dépensé
  double getTotalSpent() {
    return _orders
        .where((order) => order.isPaid || order.isFulfilled)
        .fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  // Nettoyer les données
  void clear() {
    _orders.clear();
    _selectedOrder = null;
    _error = null;
    notifyListeners();
  }

  // Méthodes utilitaires privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) {
      notifyListeners();
    }
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }
}