import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../providers/order_provider.dart';
import '../../widgets/koumbaya_button.dart';
import '../../utils/secure_token_storage.dart';
import 'payment_success_page.dart';

class PaymentProcessingPage extends StatefulWidget {
  final String orderNumber;
  final double amount;
  final String paymentMethod;
  final String? productName;
  final String? orderType;
  
  const PaymentProcessingPage({
    super.key,
    required this.orderNumber,
    required this.amount,
    required this.paymentMethod,
    this.productName,
    this.orderType,
  });

  @override
  State<PaymentProcessingPage> createState() => _PaymentProcessingPageState();
}

class _PaymentProcessingPageState extends State<PaymentProcessingPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  String currentStep = 'phone_input'; // phone_input, processing, success, error, timeout
  String? phoneNumber;
  String? errorMessage;
  bool isLoading = false;

  int remainingSeconds = 90;
  bool isTimerRunning = false;
  bool isCancelled = false;

  final TextEditingController _phoneController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Empêcher le retour pendant le traitement
        return currentStep != 'processing';
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(_getAppBarTitle()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: currentStep != 'processing',
        ),
        body: _buildBody(),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (currentStep) {
      case 'phone_input':
        return 'Numéro de téléphone';
      case 'processing':
        return 'Traitement...';
      case 'success':
        return 'Paiement réussi';
      case 'error':
        return 'Erreur de paiement';
      case 'timeout':
        return 'Délai expiré';
      default:
        return 'Paiement';
    }
  }

  Widget _buildBody() {
    switch (currentStep) {
      case 'phone_input':
        return _buildPhoneInputStep();
      case 'processing':
        return _buildProcessingStep();
      case 'success':
        return _buildSuccessStep();
      case 'error':
        return _buildErrorStep();
      case 'timeout':
        return _buildTimeoutStep();
      default:
        return _buildPhoneInputStep();
    }
  }

  Widget _buildPhoneInputStep() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        // En-tête avec logo de l'opérateur
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _getOperatorColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    _getOperatorLogo(),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _getOperatorName(),
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Saisissez votre numéro de téléphone',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Montant à payer
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Montant à payer',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.amount.toStringAsFixed(0)} FCFA',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Formulaire de saisie
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Numéro de téléphone',
                style: AppTextStyles.label,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 9,
                decoration: InputDecoration(
                  hintText: _getPhoneHint(),
                  hintStyle: AppTextStyles.hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: _getOperatorColor(), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  errorText: errorMessage,
                  counterText: '',
                ),
                style: AppTextStyles.input,
                onChanged: (value) {
                  setState(() {
                    errorMessage = null;
                  });
                  _validatePhoneNumber(value);
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Format: ${_getPhoneHint()} (${_getValidPrefixes()})',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey[500],
                ),
              ),

              const SizedBox(height: 24),

              // Instructions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Instructions de paiement:',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...['Assurez-vous d\'avoir suffisamment de crédit',
                        'Gardez votre téléphone près de vous',
                        'Vous recevrez un code de confirmation USSD']
                        .map((instruction) => Padding(
                          padding: const EdgeInsets.only(left: 24, bottom: 4),
                          child: Text(
                            '• $instruction',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.blue[600],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bouton de paiement
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: SafeArea(
            child: KoumbayaButton(
              text: 'Payer ${widget.amount.toStringAsFixed(0)} FCFA',
              onPressed: _canProceed() ? _processPayment : null,
              isLoading: isLoading,
              backgroundColor: _getOperatorColor(),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildProcessingStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getOperatorColor().withValues(alpha: 0.1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    _getOperatorLogo(),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Traitement du paiement...',
              style: AppTextStyles.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Vérifiez votre téléphone et suivez les instructions USSD',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Timer circulaire
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: remainingSeconds / 90,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(_getOperatorColor()),
                  ),
                ),
                Text(
                  '$remainingSeconds s',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getOperatorColor(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Text(
              'Montant: ${widget.amount.toStringAsFixed(0)} FCFA',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Téléphone: $phoneNumber',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 32),

            // Bouton d'annulation
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  isCancelled = true;
                  isTimerRunning = false;
                  currentStep = 'phone_input';
                });
              },
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Annuler le paiement'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeoutStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.timer_off,
                size: 50,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Délai expiré',
              style: AppTextStyles.h4.copyWith(
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Le délai de 90 secondes est écoulé.\nLe paiement n\'a pas été confirmé.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Montant: ${widget.amount.toStringAsFixed(0)} FCFA',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Téléphone: $phoneNumber',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Retour'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: KoumbayaButton(
                    text: 'Relancer',
                    onPressed: () {
                      setState(() {
                        remainingSeconds = 90;
                        isCancelled = false;
                        currentStep = 'processing';
                      });
                      _retryPayment();
                    },
                    backgroundColor: _getOperatorColor(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessStep() {
    return PaymentSuccessPage(
      orderNumber: widget.orderNumber,
      amount: widget.amount,
      paymentMethod: widget.paymentMethod,
      productName: widget.productName,
      orderType: widget.orderType,
      onContinue: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  Widget _buildErrorStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Paiement échoué',
              style: AppTextStyles.h4.copyWith(
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Une erreur est survenue lors du paiement',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Retour'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: KoumbayaButton(
                    text: 'Réessayer',
                    onPressed: () {
                      setState(() {
                        currentStep = 'phone_input';
                        errorMessage = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Méthodes utilitaires
  String _getOperatorName() {
    switch (widget.paymentMethod) {
      case 'airtel_money':
        return 'Airtel Money';
      case 'moov_money':
        return 'Moov Money';
      default:
        return 'Mobile Money';
    }
  }

  String _getOperatorLogo() {
    switch (widget.paymentMethod) {
      case 'airtel_money':
        return 'assets/images/am.png';
      case 'moov_money':
        return 'assets/images/mm.png';
      default:
        return 'assets/images/logo.png';
    }
  }

  Color _getOperatorColor() {
    switch (widget.paymentMethod) {
      case 'airtel_money':
        return Colors.red;
      case 'moov_money':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }

  String _getPhoneHint() {
    switch (widget.paymentMethod) {
      case 'airtel_money':
        return '074010203';
      case 'moov_money':
        return '065010203';
      default:
        return '0xxxxxxxx';
    }
  }

  String _getValidPrefixes() {
    switch (widget.paymentMethod) {
      case 'airtel_money':
        return '074, 077, 076 pour Airtel';
      case 'moov_money':
        return '065, 062, 066, 060 pour Moov';
      default:
        return 'Préfixes valides';
    }
  }

  bool _validatePhoneNumber(String phone) {
    if (phone.length != 9) return false;

    switch (widget.paymentMethod) {
      case 'airtel_money':
        return phone.startsWith('074') || 
               phone.startsWith('077') || 
               phone.startsWith('076');
      case 'moov_money':
        return phone.startsWith('065') || 
               phone.startsWith('062') || 
               phone.startsWith('066') || 
               phone.startsWith('060');
      default:
        return true;
    }
  }

  bool _canProceed() {
    final phone = _phoneController.text;
    return phone.length == 9 && _validatePhoneNumber(phone) && !isLoading;
  }

  Future<void> _processPayment() async {
    final phone = _phoneController.text;
    
    if (!_validatePhoneNumber(phone)) {
      setState(() {
        errorMessage = 'Numéro de téléphone invalide pour cet opérateur';
      });
      return;
    }

    setState(() {
      isLoading = true;
      phoneNumber = phone;
      currentStep = 'processing';
    });

    try {
      // Appeler l'API pour initier le paiement
      final Map<String, dynamic> paymentData = {
        'phone': phone,
        'operator': widget.paymentMethod == 'airtel_money' ? 'airtel' : 'moov',
      };

      // Pour les loteries, utiliser transaction_id, sinon order_number
      if (widget.orderType == 'lottery') {
        paymentData['transaction_id'] = widget.orderNumber;
      } else {
        paymentData['order_number'] = widget.orderNumber;
      }

      final response = await _apiService.post(
        '/api/payments/initiate-from-transaction',
        paymentData,
        await _getAuthToken(),
      );

      if (response['success'] == true) {
        // Attendre et vérifier le statut du paiement pendant 90 secondes
        await _checkPaymentStatusWithTimeout();
      } else {
        setState(() {
          currentStep = 'error';
          errorMessage = response['message'] ?? 'Erreur lors de l\'initiation du paiement';
        });
      }
    } catch (e) {
      setState(() {
        currentStep = 'error';
        errorMessage = 'Erreur de connexion: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkPaymentStatusWithTimeout() async {
    try {
      isCancelled = false;
      isTimerRunning = true;
      remainingSeconds = 90;

      final orderProvider = context.read<OrderProvider>();
      final startTime = DateTime.now();
      final timeout = const Duration(seconds: 90);

      // Timer pour mettre à jour le compte à rebours chaque seconde
      while (DateTime.now().difference(startTime) < timeout && !isCancelled) {
        // Mettre à jour le temps restant
        final elapsed = DateTime.now().difference(startTime).inSeconds;
        if (mounted) {
          setState(() {
            remainingSeconds = 90 - elapsed;
          });
        }

        // Vérifier le statut toutes les 5 secondes
        if (elapsed % 5 == 0) {
          await orderProvider.loadOrder(widget.orderNumber);

          final order = orderProvider.selectedOrder;
          if (order != null && order.actuallyPaid) {
            if (mounted) {
              setState(() {
                currentStep = 'success';
                isTimerRunning = false;
              });
            }
            return; // Paiement réussi
          }
        }

        // Si l'écran n'est plus monté ou annulé, on arrête
        if (!mounted || isCancelled) {
          isTimerRunning = false;
          return;
        }

        // Attendre 1 seconde avant la prochaine itération
        await Future.delayed(const Duration(seconds: 1));
      }

      // Timeout atteint sans confirmation de paiement
      if (mounted && !isCancelled) {
        setState(() {
          currentStep = 'timeout';
          isTimerRunning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          currentStep = 'error';
          errorMessage = 'Erreur lors de la vérification du paiement: ${e.toString()}';
          isTimerRunning = false;
        });
      }
    }
  }

  Future<void> _retryPayment() async {
    // Relancer la vérification du statut de paiement
    await _checkPaymentStatusWithTimeout();
  }

  Future<String?> _getAuthToken() async {
    return await SecureTokenStorage.getToken();
  }
}