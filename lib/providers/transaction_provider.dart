import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../services/api_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  List<Transaction> _transactions = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  
  // Pagination
  int _currentPage = 1;
  bool _hasMoreData = true;
  final int _perPage = 20;

  // Filters
  String? _selectedType;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters
  List<Transaction> get transactions => _transactions;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasMoreData => _hasMoreData;
  int get currentPage => _currentPage;
  String? get selectedType => _selectedType;
  String? get selectedStatus => _selectedStatus;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  /// Charge les transactions avec filtres optionnels
  Future<void> loadTransactions({
    bool refresh = false,
    String? type,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (refresh) {
      _transactions.clear();
      _currentPage = 1;
      _hasMoreData = true;
    }

    if (_isLoading || !_hasMoreData) return;

    try {
      _setLoading(true);
      _clearMessages();

      // Update filters
      _selectedType = type;
      _selectedStatus = status;
      _startDate = startDate;
      _endDate = endDate;

      final newTransactions = await _transactionService.getUserTransactions(
        page: _currentPage,
        perPage: _perPage,
        type: type,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );

      if (newTransactions.length < _perPage) {
        _hasMoreData = false;
      }

      _transactions.addAll(newTransactions);
      _currentPage++;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Charge plus de transactions (pagination)
  Future<void> loadMoreTransactions() async {
    await loadTransactions(
      type: _selectedType,
      status: _selectedStatus,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  /// Rafraîchit la liste des transactions
  Future<void> refreshTransactions() async {
    await loadTransactions(
      refresh: true,
      type: _selectedType,
      status: _selectedStatus,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  /// Charge les statistiques des transactions
  Future<void> loadStats() async {
    try {
      _setLoading(true);
      _clearMessages();

      _stats = await _transactionService.getTransactionStats();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Charge une transaction spécifique
  Future<Transaction?> getTransaction(int transactionId) async {
    try {
      _setLoading(true);
      _clearMessages();

      final transaction = await _transactionService.getTransaction(transactionId);
      return transaction;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Annule une transaction
  Future<bool> cancelTransaction(int transactionId) async {
    try {
      _setLoading(true);
      _clearMessages();

      final updatedTransaction = await _transactionService.cancelTransaction(transactionId);
      
      // Mettre à jour la transaction dans la liste
      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index != -1) {
        _transactions[index] = updatedTransaction;
      }

      _setSuccess('Transaction annulée avec succès');
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Filtre les transactions par type
  List<Transaction> getTransactionsByType(String type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  /// Filtre les transactions par statut
  List<Transaction> getTransactionsByStatus(String status) {
    return _transactions.where((t) => t.status == status).toList();
  }

  /// Calcule le total des dépenses
  double get totalSpent {
    return _transactions
        .where((t) => t.isCompleted && !t.isRefund)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// Calcule le total des remboursements
  double get totalRefunded {
    return _transactions
        .where((t) => t.isCompleted && t.isRefund)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// Nombre de transactions par type
  int getTransactionCountByType(String type) {
    return _transactions.where((t) => t.type == type).length;
  }

  /// Applique des filtres et recharge
  Future<void> applyFilters({
    String? type,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await loadTransactions(
      refresh: true,
      type: type,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Efface tous les filtres
  Future<void> clearFilters() async {
    await loadTransactions(refresh: true);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
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
    _transactionService.dispose();
    super.dispose();
  }
}