import 'package:flutter/foundation.dart';
import '../models/lottery.dart';
import '../models/lottery_ticket.dart';
import '../models/ticket_with_details.dart';
import '../services/api_service.dart';

class LotteryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Lottery> _activeLotteries = [];
  Lottery? _selectedLottery;
  List<LotteryTicket> _myTickets = [];
  List<TicketWithDetails> _userTickets = [];
  
  bool _isLoading = false;
  bool _isPurchasing = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  List<Lottery> get activeLotteries => _activeLotteries;
  Lottery? get selectedLottery => _selectedLottery;
  List<LotteryTicket> get myTickets => _myTickets;
  List<TicketWithDetails> get userTickets => _userTickets;
  
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Load active lotteries
  Future<void> loadActiveLotteries() async {
    try {
      _setLoading(true);
      _clearMessages();

      _activeLotteries = await _apiService.getActiveLotteries();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  // Load specific lottery
  Future<void> loadLottery(int id) async {
    try {
      _setLoading(true);
      _clearMessages();

      _selectedLottery = await _apiService.getLottery(id);
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  // Buy lottery ticket
  Future<bool> buyTicket(int lotteryId, int quantity) async {
    try {
      _setPurchasing(true);
      _clearMessages();

      await _apiService.buyLotteryTicket(lotteryId, quantity);
      
      _setSuccess('Billet(s) acheté(s) avec succès!');
      
      // Refresh the lottery data
      await loadLottery(lotteryId);
      await loadActiveLotteries();
      
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setPurchasing(false);
    }
  }

  void selectLottery(Lottery? lottery) {
    _selectedLottery = lottery;
    notifyListeners();
  }

  void clearSelectedLottery() {
    _selectedLottery = null;
    notifyListeners();
  }

  // Get lottery by product ID
  Lottery? getLotteryByProductId(int productId) {
    try {
      return _activeLotteries.firstWhere((lottery) => lottery.productId == productId);
    } catch (e) {
      return null;
    }
  }

  // Filter lotteries by completion percentage
  List<Lottery> getLotteriesByCompletion({double minPercentage = 0, double maxPercentage = 100}) {
    return _activeLotteries.where((lottery) {
      final completion = lottery.completionPercentage;
      return completion >= minPercentage && completion <= maxPercentage;
    }).toList();
  }

  // Get lotteries ending soon
  List<Lottery> getLotteriesEndingSoon({Duration within = const Duration(days: 7)}) {
    final now = DateTime.now();
    final cutoff = now.add(within);
    
    return _activeLotteries.where((lottery) {
      return lottery.drawDate?.isAfter(now) == true && lottery.drawDate?.isBefore(cutoff) == true;
    }).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setPurchasing(bool purchasing) {
    _isPurchasing = purchasing;
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
    notifyListeners();
  }

  // Get lottery details (for the mobile pages)
  Future<Lottery?> getLotteryDetails(int lotteryId) async {
    try {
      _setLoading(true);
      _clearMessages();

      final lottery = await _apiService.getLottery(lotteryId);
      return lottery;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Get my tickets for a specific lottery
  List<LotteryTicket> getMyTicketsForLottery(int lotteryId) {
    return _myTickets.where((ticket) => ticket.lotteryId == lotteryId).toList();
  }

  // Load user tickets with details
  Future<void> getUserTickets() async {
    try {
      _setLoading(true);
      _clearMessages();

      final response = await _apiService.getUserTicketsWithDetails();
      _userTickets = response;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  // Get tickets by status
  List<TicketWithDetails> getTicketsByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return _userTickets.where((t) => t.isLotteryActive).toList();
      case 'winner':
        return _userTickets.where((t) => t.ticket.isWinner).toList();
      case 'completed':
        return _userTickets.where((t) => t.isLotteryCompleted).toList();
      default:
        return _userTickets;
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Une erreur inattendue s\'est produite';
  }
}