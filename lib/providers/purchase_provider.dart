import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class PurchaseProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isPurchasing = false;
  String? _error;

  bool get isPurchasing => _isPurchasing;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isPurchasing = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Acheter un produit directement (sans tombola)
  Future<Map<String, dynamic>?> buyProductDirectly(int productId, {int quantity = 1}) async {
    try {
      _setLoading(true);
      _clearError();

      if (kDebugMode) {
        print('🛒 Achat direct du produit $productId (quantité: $quantity)');
      }

      // Appel à l'API pour acheter le produit
      final result = await _apiService.buyProductDirectly(productId, quantity);
      
      if (kDebugMode) {
        print('✅ Achat réussi: $result');
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de l\'achat: $e');
      }
      
      _setError(_getErrorMessage(e));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Obtenir l'historique des achats directs
  Future<List<Map<String, dynamic>>> getPurchaseHistory() async {
    try {
      _clearError();
      
      // TODO: Implémenter l'endpoint pour récupérer l'historique des achats
      // final result = await _apiService.getUserPurchases();
      
      // Pour l'instant, retourner une liste vide
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la récupération de l\'historique: $e');
      }
      
      _setError(_getErrorMessage(e));
      return [];
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('ApiException')) {
      return error.toString().replaceAll('ApiException: ', '');
    }
    
    if (error.toString().contains('SocketException')) {
      return 'Problème de connexion internet. Veuillez vérifier votre connexion.';
    }
    
    if (error.toString().contains('TimeoutException')) {
      return 'La connexion a expiré. Veuillez réessayer.';
    }
    
    if (error.toString().contains('FormatException')) {
      return 'Erreur de format des données. Veuillez réessayer.';
    }
    
    return 'Une erreur inattendue s\'est produite. Veuillez réessayer.';
  }

  void clearError() {
    _clearError();
  }
}