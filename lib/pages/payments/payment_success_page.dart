import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/koumbaya_button.dart';

class PaymentSuccessPage extends StatelessWidget {
  final String orderNumber;
  final double amount;
  final String paymentMethod;
  final String? productName;
  final String? orderType;
  final VoidCallback? onContinue;

  const PaymentSuccessPage({
    super.key,
    required this.orderNumber,
    required this.amount,
    required this.paymentMethod,
    this.productName,
    this.orderType,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Animation de succès
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withValues(alpha: 0.1),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Colors.green,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Titre de succès
              Text(
                'Paiement réussi !',
                style: AppTextStyles.h2.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Message de confirmation
              Text(
                _getSuccessMessage(),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Détails du paiement
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Commande', '#$orderNumber'),
                    const Divider(height: 24),
                    _buildDetailRow('Produit', productName ?? 'Produit'),
                    const Divider(height: 24),
                    _buildDetailRow('Montant payé', '${amount.toStringAsFixed(0)} FCFA'),
                    const Divider(height: 24),
                    _buildDetailRow('Mode de paiement', _getPaymentMethodText()),
                    const Divider(height: 24),
                    _buildDetailRow('Date', _getCurrentDateTime()),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Informations sur la suite
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Que se passe-t-il ensuite ?',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getNextStepsMessage(),
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Boutons d'action
              Column(
                children: [
                  KoumbayaButton(
                    text: _getPrimaryButtonText(),
                    onPressed: () => _handlePrimaryAction(context),
                    icon: Icon(_getPrimaryButtonIcon(), size: 20, color: Colors.white),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  OutlinedButton(
                    onPressed: onContinue ?? () => Navigator.of(context).popUntil((route) => route.isFirst),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Retour à l\'accueil',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Bouton de partage (optionnel)
                  TextButton.icon(
                    onPressed: () => _shareSuccess(context),
                    icon: const Icon(Icons.share, size: 20),
                    label: const Text('Partager'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getSuccessMessage() {
    switch (orderType) {
      case 'lottery':
        return 'Votre achat de tickets de tirage spécial a été confirmé avec succès.';
      case 'direct':
        return 'Votre achat a été confirmé avec succès.';
      default:
        return 'Votre paiement a été traité avec succès.';
    }
  }

  String _getPaymentMethodText() {
    switch (paymentMethod) {
      case 'airtel_money':
        return 'Airtel Money';
      case 'moov_money':
        return 'Moov Money';
      default:
        return paymentMethod;
    }
  }

  String _getCurrentDateTime() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} à ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _getNextStepsMessage() {
    switch (orderType) {
      case 'lottery':
        return 'Vos tickets sont maintenant disponibles dans la section "Mes Tickets". Le tirage aura lieu à la date prévue.';
      case 'direct':
        return 'Votre commande est en cours de traitement. Vous recevrez une notification quand elle sera prête.';
      default:
        return 'Votre transaction a été enregistrée et vous pouvez la suivre dans l\'historique.';
    }
  }

  String _getPrimaryButtonText() {
    switch (orderType) {
      case 'lottery':
        return 'Voir mes tickets';
      case 'direct':
        return 'Suivre ma commande';
      default:
        return 'Voir l\'historique';
    }
  }

  IconData _getPrimaryButtonIcon() {
    switch (orderType) {
      case 'lottery':
        return Icons.confirmation_number;
      case 'direct':
        return Icons.track_changes;
      default:
        return Icons.history;
    }
  }

  void _handlePrimaryAction(BuildContext context) {
    switch (orderType) {
      case 'lottery':
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/tickets',
          (route) => route.isFirst,
        );
        break;
      case 'direct':
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/orders',
          (route) => route.isFirst,
        );
        break;
      default:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/transactions',
          (route) => route.isFirst,
        );
        break;
    }
  }

  void _shareSuccess(BuildContext context) {
    // TODO: Implémenter le partage du succès du paiement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de partage à venir'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}