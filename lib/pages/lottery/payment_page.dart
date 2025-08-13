import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../models/lottery.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/loading_widget.dart';

class PaymentPage extends StatefulWidget {
  final Lottery lottery;
  final int quantity;
  final double totalAmount;
  final String phoneNumber;

  const PaymentPage({
    super.key,
    required this.lottery,
    required this.quantity,
    required this.totalAmount,
    required this.phoneNumber,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final ApiService _apiService = ApiService();
  
  String _paymentStatus = 'initiating'; // initiating, pending, success, failed
  String? _transactionId;
  String? _errorMessage;
  Timer? _statusTimer;
  int _timeoutCounter = 0;
  static const int _maxTimeout = 300; // 5 minutes

  @override
  void initState() {
    super.initState();
    _initiatePayment();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      setState(() {
        _paymentStatus = 'initiating';
        _errorMessage = null;
      });

      final token = await authProvider.token;
      final response = await _apiService.post('/tickets/purchase', {
        'lottery_id': widget.lottery.id,
        'quantity': widget.quantity,
        'phone_number': widget.phoneNumber,
        'total_amount': widget.totalAmount,
      }, token);

      if (response['success'] == true) {
        setState(() {
          _transactionId = response['data']['transaction_id'];
          _paymentStatus = 'pending';
        });
        _startStatusCheck();
      } else {
        setState(() {
          _paymentStatus = 'failed';
          _errorMessage = response['message'] ?? 'Erreur lors de l\'initiation du paiement';
        });
      }
    } catch (e) {
      setState(() {
        _paymentStatus = 'failed';
        _errorMessage = 'Erreur de connexion: ${e.toString()}';
      });
    }
  }

  void _startStatusCheck() {
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _checkPaymentStatus();
      _timeoutCounter += 5;
      
      if (_timeoutCounter >= _maxTimeout) {
        timer.cancel();
        if (_paymentStatus == 'pending') {
          setState(() {
            _paymentStatus = 'failed';
            _errorMessage = 'Le paiement a pris trop de temps. Veuillez réessayer.';
          });
        }
      }
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_transactionId == null || _paymentStatus != 'pending') return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.token;
      final response = await _apiService.get(
        '/transactions/$_transactionId/status', 
        token
      );

      if (response['success'] == true) {
        final status = response['data']['status'];
        
        if (status == 'completed') {
          setState(() {
            _paymentStatus = 'success';
          });
          _statusTimer?.cancel();
        } else if (status == 'failed' || status == 'cancelled') {
          setState(() {
            _paymentStatus = 'failed';
            _errorMessage = response['data']['message'] ?? 'Paiement échoué';
          });
          _statusTimer?.cancel();
        }
      }
    } catch (e) {
      // Continue checking unless it's a critical error
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_paymentStatus == 'success') {
          Navigator.of(context).pop(true);
          return false;
        } else if (_paymentStatus == 'pending') {
          return await _showExitConfirmation();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paiement'),
          automaticallyImplyLeading: _paymentStatus != 'pending',
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildOrderSummary(),
              const SizedBox(height: 24),
              Expanded(
                child: _buildPaymentContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Récapitulatif de commande',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: widget.lottery.product?.hasImages == true
                        ? DecorationImage(
                            image: NetworkImage(widget.lottery.product!.displayImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[200],
                  ),
                  child: widget.lottery.product?.hasImages != true
                      ? const Icon(Icons.image, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lottery.product?.name ?? 'Produit non disponible',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Tombola ${widget.lottery.lotteryNumber}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${widget.quantity} ticket(s)'),
                Text('${widget.totalAmount.toStringAsFixed(0)} FCFA'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Téléphone:'),
                Text(widget.phoneNumber),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.totalAmount.toStringAsFixed(0)} FCFA',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentContent() {
    switch (_paymentStatus) {
      case 'initiating':
        return _buildInitiatingState();
      case 'pending':
        return _buildPendingState();
      case 'success':
        return _buildSuccessState();
      case 'failed':
        return _buildFailedState();
      default:
        return const SizedBox();
    }
  }

  Widget _buildInitiatingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingWidget(),
          SizedBox(height: 16),
          Text(
            'Initiation du paiement...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingState() {
    final remainingTime = _maxTimeout - _timeoutCounter;
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.phone_android,
              size: 64,
              color: Colors.orange[700],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Paiement en cours...',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Vérifiez votre téléphone et suivez les instructions pour confirmer le paiement Mobile Money.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Numéro: ${widget.phoneNumber}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppConstants.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Temps restant: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          if (_transactionId != null) ...[
            const SizedBox(height: 8),
            Text(
              'Transaction ID: $_transactionId',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 64,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Paiement réussi !',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Vos ${widget.quantity} ticket(s) ont été achetés avec succès.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Vous pouvez maintenant consulter vos tickets dans la section "Mes participations".',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Continuer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Paiement échoué',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Une erreur s\'est produite lors du paiement.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    _initiatePayment();
                  },
                  child: const Text(
                    'Réessayer le paiement',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text(
                    'Annuler',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter le paiement ?'),
        content: const Text(
          'Le paiement est en cours. Si vous quittez maintenant, vous devrez peut-être vérifier le statut de votre transaction plus tard.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Rester'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}