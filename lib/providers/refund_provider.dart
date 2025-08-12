import 'package:flutter/foundation.dart';
import '../models/refund.dart';
import '../models/transaction.dart';
import '../services/refund_service.dart';
import '../services/api_service.dart';

class RefundProvider extends ChangeNotifier {
  final RefundService _refundService = RefundService();

  List<Refund> _refunds = [];
  List<Transaction> _eligibleTransactions = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;
  String? _successMessage;
  
  // Pagination
  int _currentPage = 1;
  bool _hasMoreData = true;
  final int _perPage = 20;

  // Filters
  String? _selectedStatus;

  // Getters
  List<Refund> get refunds => _refunds;
  List<Transaction> get eligibleTransactions => _eligibleTransactions;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasMoreData => _hasMoreData;
  int get currentPage => _currentPage;
  String? get selectedStatus => _selectedStatus;

  /// Charge les demandes de remboursement avec filtres optionnels
  Future<void> loadRefunds({
    bool refresh = false,
    String? status,
  }) async {
    if (refresh) {
      _refunds.clear();
      _currentPage = 1;
      _hasMoreData = true;
    }

    if (_isLoading || !_hasMoreData) return;

    try {
      _setLoading(true);
      _clearMessages();

      _selectedStatus = status;

      final newRefunds = await _refundService.getUserRefunds(
        page: _currentPage,
        perPage: _perPage,
        status: status,
      );

      if (newRefunds.length < _perPage) {
        _hasMoreData = false;
      }

      _refunds.addAll(newRefunds);
      _currentPage++;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Charge plus de demandes de remboursement (pagination)
  Future<void> loadMoreRefunds() async {
    await loadRefunds(status: _selectedStatus);
  }

  /// Rafraîchit la liste des demandes de remboursement
  Future<void> refreshRefunds() async {
    await loadRefunds(refresh: true, status: _selectedStatus);
  }

  /// Charge les statistiques des remboursements
  Future<void> loadStats() async {
    try {
      _setLoading(true);
      _clearMessages();

      _stats = await _refundService.getRefundStats();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Charge les transactions éligibles pour remboursement
  Future<void> loadEligibleTransactions() async {
    try {
      _setLoading(true);
      _clearMessages();

      _eligibleTransactions = await _refundService.getEligibleTransactions();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Crée une nouvelle demande de remboursement
  Future<bool> createRefund({
    required int transactionId,
    required String reason,
    String? description,
  }) async {
    try {
      _setCreating(true);
      _clearMessages();

      final newRefund = await _refundService.createRefund(
        transactionId: transactionId,
        reason: reason,
        description: description,
      );

      // Ajouter la nouvelle demande en tête de liste
      _refunds.insert(0, newRefund);
      _setSuccess('Demande de remboursement créée avec succès');
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setCreating(false);
    }
  }

  /// Charge une demande de remboursement spécifique
  Future<Refund?> getRefund(int refundId) async {
    try {
      _setLoading(true);
      _clearMessages();

      final refund = await _refundService.getRefund(refundId);
      return refund;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Annule une demande de remboursement
  Future<bool> cancelRefund(int refundId) async {
    try {
      _setLoading(true);
      _clearMessages();

      final updatedRefund = await _refundService.cancelRefund(refundId);
      
      // Mettre à jour la demande dans la liste
      final index = _refunds.indexWhere((r) => r.id == refundId);
      if (index != -1) {
        _refunds[index] = updatedRefund;
      }

      _setSuccess('Demande de remboursement annulée');
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Filtre les demandes par statut
  List<Refund> getRefundsByStatus(String status) {
    return _refunds.where((r) => r.status == status).toList();
  }

  /// Calcule le nombre de demandes par statut
  int getRefundCountByStatus(String status) {
    return _refunds.where((r) => r.status == status).length;
  }

  /// Applique des filtres et recharge
  Future<void> applyFilters({String? status}) async {
    await loadRefunds(refresh: true, status: status);
  }

  /// Efface tous les filtres
  Future<void> clearFilters() async {
    await loadRefunds(refresh: true);
  }

  /// Récupère les raisons de remboursement disponibles
  List<Map<String, String>> getRefundReasons() {
    return _refundService.getRefundReasons();
  }

  /// Statistiques calculées
  double get totalRefundAmount {
    return _refunds
        .where((r) => r.isCompleted)
        .fold<double>(0, (sum, r) => sum + r.amount);
  }

  double get pendingRefundAmount {
    return _refunds
        .where((r) => r.isPending || r.isApproved || r.isProcessed)
        .fold<double>(0, (sum, r) => sum + r.amount);
  }

  int get pendingRefundsCount {
    return _refunds.where((r) => r.isPending).length;
  }

  int get completedRefundsCount {
    return _refunds.where((r) => r.isCompleted).length;
  }

  int get rejectedRefundsCount {
    return _refunds.where((r) => r.isRejected).length;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setCreating(bool creating) {
    _isCreating = creating;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String success) {
    _successMessage = success;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Une erreur inattendue s\'est produite';
  }

  @override
  void dispose() {
    _refundService.dispose();
    super.dispose();
  }
}