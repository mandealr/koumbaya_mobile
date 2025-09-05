import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/koumbaya_button.dart';
import '../payments/payment_method_selection_page.dart';

class OrderDetailPage extends StatefulWidget {
  final Order order;

  const OrderDetailPage({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Order currentOrder;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentOrder = widget.order;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshOrderDetails();
    });
  }

  Future<void> _refreshOrderDetails() async {
    final orderProvider = context.read<OrderProvider>();
    await orderProvider.loadOrder(currentOrder.orderNumber);
    
    if (mounted && orderProvider.selectedOrder != null) {
      setState(() {
        currentOrder = orderProvider.selectedOrder!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Commande #${currentOrder.orderNumber}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrderDetails,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrderDetails,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de statut
              Center(child: _buildStatusHeader()),
              
              const SizedBox(height: 16),
              
              // Détails de la commande
              _buildOrderDetails(),
              
              const SizedBox(height: 16),
              
              // Détails du produit
              _buildProductDetails(),
              
              const SizedBox(height: 16),
              
              // Informations de paiement
              if (currentOrder.payments != null && currentOrder.payments!.isNotEmpty) _buildPaymentDetails(),
              
              const SizedBox(height: 16),
              
              // Timeline de la commande
              _buildOrderTimeline(),
              
              const SizedBox(height: 24),
              
              // Actions
              _buildActionButtons(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    Color backgroundColor;
    Color textColor;
    IconData statusIcon;

    switch (currentOrder.status) {
      case 'paid':
      case 'shipping':
      case 'fulfilled':
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green[700]!;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
      case 'awaiting_payment':
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange[700]!;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'failed':
      case 'cancelled':
      case 'expired':
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red[700]!;
        statusIcon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey[700]!;
        statusIcon = Icons.info;
    }

    return Container(
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              size: 40,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            currentOrder.statusText,
            style: AppTextStyles.h3.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusDescription(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
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
            'Détails de la commande',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Numéro de commande', '#${currentOrder.orderNumber}'),
          const Divider(height: 24),
          _buildDetailRow('Type', currentOrder.typeText),
          const Divider(height: 24),
          _buildDetailRow('Date de commande', _formatDateTime(currentOrder.createdAt)),
          const Divider(height: 24),
          _buildDetailRow('Montant total', '${currentOrder.totalAmount.toStringAsFixed(0)} FCFA'),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    return Container(
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
          Row(
            children: [
              Icon(
                currentOrder.isLotteryOrder 
                  ? Icons.confirmation_number
                  : Icons.shopping_bag,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                currentOrder.isLotteryOrder ? 'Tickets de tombola' : 'Produit',
                style: AppTextStyles.h4,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  currentOrder.isLotteryOrder 
                    ? Icons.confirmation_number
                    : Icons.shopping_bag,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentOrder.displayTitle,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentOrder.isLotteryOrder ? 'Tickets de tombola' : 'Produit direct',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${currentOrder.totalAmount.toStringAsFixed(0)} FCFA',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    final payment = currentOrder.payments!.first;
    
    return Container(
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
            'Informations de paiement',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Mode de paiement', payment.paymentMethodText),
          const Divider(height: 24),
          _buildDetailRow('Référence', payment.reference),
          const Divider(height: 24),
          _buildDetailRow('Montant', '${payment.amount.toStringAsFixed(0)} FCFA'),
          const Divider(height: 24),
          _buildDetailRow('Statut du paiement', payment.statusText),
          if (payment.paidAt != null) ...[
            const Divider(height: 24),
            _buildDetailRow('Date de paiement', _formatDateTime(payment.paidAt!)),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderTimeline() {
    final events = _getTimelineEvents();
    
    return Container(
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
            'Historique de la commande',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 16),
          ...events.asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            final isLast = index == events.length - 1;
            
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: event['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event['description'] as String,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(event['date'] as DateTime),
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                      if (!isLast) const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Center(
      child: Column(
        children: [
          // Bouton de confirmation de réception (pour produits directs et tickets gagnants payés)
          if (_shouldShowConfirmReceipt()) ...[
            SizedBox(
              width: double.infinity,
              child: KoumbayaButton(
                text: 'Confirmer la réception',
                onPressed: _confirmReceipt,
                icon: const Icon(Icons.check_circle, size: 20, color: Colors.white),
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (currentOrder.canBePaid) ...[
            SizedBox(
              width: double.infinity,
              child: KoumbayaButton(
                text: 'Reprendre le paiement',
                onPressed: _retryPayment,
                icon: const Icon(Icons.payment, size: 20, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (currentOrder.canBeCancelled) ...[
            SizedBox(
              width: double.infinity,
              child: KoumbayaButton.outline(
                text: 'Annuler la commande',
                onPressed: _cancelOrder,
              ),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _shareOrder,
              icon: const Icon(Icons.share, size: 20),
              label: const Text('Partager'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  String _getStatusDescription() {
    switch (currentOrder.status) {
      case 'pending':
        return 'Votre commande est en attente de traitement';
      case 'awaiting_payment':
        return 'En attente de paiement';
      case 'paid':
        return 'Votre commande a été payée avec succès';
      case 'shipping':
        return 'Votre commande est en cours de livraison';
      case 'fulfilled':
        return 'Votre commande a été livrée';
      case 'cancelled':
        return 'Cette commande a été annulée';
      case 'expired':
        return 'Cette commande a expiré';
      case 'failed':
        return 'Le paiement de cette commande a échoué';
      default:
        return 'Statut de la commande';
    }
  }


  List<Map<String, dynamic>> _getTimelineEvents() {
    final events = <Map<String, dynamic>>[];

    // Commande créée
    events.add({
      'title': 'Commande créée',
      'description': 'Votre commande a été créée avec succès',
      'date': currentOrder.createdAt,
      'color': AppColors.primary,
    });

    // Paiement en cours ou traité
    if (currentOrder.status == 'awaiting_payment') {
      events.add({
        'title': 'En attente de paiement',
        'description': 'Paiement en cours de traitement',
        'date': currentOrder.updatedAt,
        'color': Colors.orange,
      });
    } else if ((currentOrder.isPaid || currentOrder.isShipping || currentOrder.isFulfilled) && currentOrder.paidAt != null) {
      events.add({
        'title': 'Paiement confirmé',
        'description': 'Votre paiement a été traité avec succès',
        'date': currentOrder.paidAt!,
        'color': Colors.green,
      });
    }

    // En cours de livraison
    if (currentOrder.status == 'shipping') {
      events.add({
        'title': 'En cours de livraison',
        'description': currentOrder.isLotteryOrder 
          ? 'Vos tickets sont en cours de traitement'
          : 'Votre commande est en cours de livraison',
        'date': currentOrder.updatedAt,
        'color': Colors.orange,
      });
    }

    // Commande livrée
    if (currentOrder.status == 'fulfilled') {
      events.add({
        'title': 'Commande livrée',
        'description': currentOrder.isLotteryOrder 
          ? 'Vos tickets sont disponibles'
          : 'Votre commande a été livrée',
        'date': currentOrder.updatedAt,
        'color': Colors.blue,
      });
    }

    // Commande annulée
    if (currentOrder.status == 'cancelled') {
      events.add({
        'title': 'Commande annulée',
        'description': 'Cette commande a été annulée',
        'date': currentOrder.updatedAt,
        'color': Colors.red,
      });
    }

    return events;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} à ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _retryPayment() async {
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reprendre le paiement'),
          content: Text(
            'Voulez-vous reprendre le paiement pour cette commande de ${currentOrder.totalAmount.toStringAsFixed(0)} FCFA ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continuer'),
            ),
          ],
        ),
      );

      if (result == true && mounted) {
        final paymentResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentMethodSelectionPage(
              orderNumber: currentOrder.orderNumber,
              amount: currentOrder.totalAmount,
              productName: currentOrder.displayTitle,
              orderType: currentOrder.type,
            ),
          ),
        );

        if (paymentResult == true && mounted) {
          _refreshOrderDetails();
        }
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
    }
  }

  Future<void> _cancelOrder() async {
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Annuler la commande'),
          content: const Text(
            'Êtes-vous sûr de vouloir annuler cette commande ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Non'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Annuler la commande'),
            ),
          ],
        ),
      );

      if (result == true && mounted) {
        setState(() {
          isLoading = true;
        });

        final orderProvider = context.read<OrderProvider>();
        final success = await orderProvider.cancelOrder(currentOrder.orderNumber);

        if (success) {
          _refreshOrderDetails();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Commande annulée avec succès'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: ${orderProvider.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareOrder() {
    // TODO: Implémenter le partage de la commande
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de partage à venir'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  bool _shouldShowConfirmReceipt() {
    // Afficher le bouton si:
    // 1. La commande est payée ou en cours de livraison (vérifier le statut réel du paiement)
    // 2. C'est soit un produit direct, soit un ticket gagnant de tombola
    if (!currentOrder.actuallyPaid || currentOrder.isFulfilled) {
      return false;
    }

    // Pour les produits directs (payés ou en cours de livraison)
    if (currentOrder.type == 'direct' && (currentOrder.isPaid || currentOrder.isShipping)) {
      return true;
    }

    // Pour les tickets de tombola gagnants (payés ou en cours de livraison)
    if (currentOrder.type == 'lottery' && (currentOrder.isPaid || currentOrder.isShipping) && currentOrder.meta?['is_winner'] == true) {
      return true;
    }

    return false;
  }

  Future<void> _confirmReceipt() async {
    try {
      final TextEditingController notesController = TextEditingController();
      
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmer la réception'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentOrder.isLotteryOrder
                  ? 'Confirmez-vous avoir reçu votre lot de tombola ?'
                  : 'Confirmez-vous avoir reçu votre produit ?',
              ),
              const SizedBox(height: 16),
              const Text('Commentaire (optionnel) :', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Ajoutez un commentaire...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'confirmed': true,
                'notes': notesController.text.trim(),
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmer'),
            ),
          ],
        ),
      );

      if (result != null && result['confirmed'] == true && mounted) {
        setState(() {
          isLoading = true;
        });

        // Appeler l'API pour confirmer la réception avec les notes
        final orderProvider = context.read<OrderProvider>();
        final notes = result['notes'] as String?;
        final success = await orderProvider.confirmOrderReceipt(
          currentOrder.orderNumber, 
          notes: notes?.isNotEmpty == true ? notes : null,
        );

        if (success) {
          _refreshOrderDetails();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Réception confirmée avec succès'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erreur lors de la confirmation'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}