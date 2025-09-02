import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/koumbaya_button.dart';
import 'payment_processing_page.dart';

class PaymentMethodSelectionPage extends StatefulWidget {
  final String orderNumber;
  final double amount;
  final String? productName;
  final String? orderType; // 'lottery' ou 'direct'
  
  const PaymentMethodSelectionPage({
    super.key,
    required this.orderNumber,
    required this.amount,
    this.productName,
    this.orderType,
  });

  @override
  State<PaymentMethodSelectionPage> createState() => _PaymentMethodSelectionPageState();
}

class _PaymentMethodSelectionPageState extends State<PaymentMethodSelectionPage> {
  String? selectedMethod;
  bool isLoading = false;
  Order? orderDetails;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    final orderProvider = context.read<OrderProvider>();
    await orderProvider.loadOrder(widget.orderNumber);
    if (mounted) {
      setState(() {
        orderDetails = orderProvider.selectedOrder;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Méthode de paiement'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // En-tête avec logo
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 50,
                ),
                const SizedBox(height: 16),
                Text(
                  'Choisissez votre méthode de paiement',
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sélectionnez votre mode de paiement préféré',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Résumé de la commande
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
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
              children: [
                Text(
                  'Résumé de votre commande',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.orderType == 'lottery' 
                          ? Icons.confirmation_number
                          : Icons.shopping_bag,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orderDetails?.displayTitle ?? widget.productName ?? 'Produit',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.orderType == 'lottery'
                              ? 'Achat de tickets'
                              : 'Achat direct',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${widget.amount.toStringAsFixed(0)} FCFA',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Commande #${widget.orderNumber}',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Méthodes de paiement
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
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
                children: [
                  Text(
                    'Méthodes de paiement',
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 16),
                  
                  // Mobile Money Section
                  Text(
                    'Mobile Money',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Airtel Money
                  _buildPaymentMethodCard(
                    method: 'airtel_money',
                    title: 'Airtel Money',
                    subtitle: 'Paiement mobile',
                    icon: 'assets/images/am.png',
                    color: Colors.red,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Moov Money
                  _buildPaymentMethodCard(
                    method: 'moov_money',
                    title: 'Moov Money',
                    subtitle: 'Paiement mobile',
                    icon: 'assets/images/mm.png',
                    color: Colors.blue,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Méthodes bientôt disponibles
                  Text(
                    'Bientôt disponible',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Carte bancaire (désactivée)
                  _buildPaymentMethodCard(
                    method: 'bank_card',
                    title: 'Carte bancaire',
                    subtitle: 'Visa, Mastercard',
                    icon: null,
                    iconWidget: Icon(Icons.credit_card, color: Colors.grey[400]),
                    color: Colors.grey,
                    enabled: false,
                  ),
                ],
              ),
            ),
          ),
          
          // Boutons d'action
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text('Retour'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: KoumbayaButton(
                      text: 'Continuer',
                      onPressed: selectedMethod != null ? _proceedToPayment : null,
                      isLoading: isLoading,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Sécurité
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security,
                  size: 16,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Paiement 100% sécurisé et chiffré',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String method,
    required String title,
    required String subtitle,
    String? icon,
    Widget? iconWidget,
    required Color color,
    bool enabled = true,
  }) {
    final isSelected = selectedMethod == method;
    
    return GestureDetector(
      onTap: enabled ? () => setState(() => selectedMethod = method) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
              ? color
              : enabled 
                ? Colors.grey[300]!
                : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected 
            ? color.withValues(alpha: 0.05)
            : enabled 
              ? Colors.white
              : Colors.grey[50],
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: iconWidget ?? (icon != null 
                ? Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      icon,
                      fit: BoxFit.contain,
                    ),
                  )
                : Icon(Icons.payment, color: Colors.grey[400])
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: enabled ? Colors.black : Colors.grey[400],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: enabled ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                ? const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  )
                : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _proceedToPayment() async {
    if (selectedMethod == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Navigation vers la page de traitement du paiement
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentProcessingPage(
            orderNumber: widget.orderNumber,
            amount: widget.amount,
            paymentMethod: selectedMethod!,
            productName: orderDetails?.displayTitle ?? widget.productName,
            orderType: widget.orderType,
          ),
        ),
      );

      if (result == true && mounted) {
        // Le paiement a réussi, fermer cette page
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}