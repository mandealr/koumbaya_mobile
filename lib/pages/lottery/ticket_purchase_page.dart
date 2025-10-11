import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/lottery.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lottery_provider.dart';
import '../../constants/app_constants.dart';
import '../../constants/koumbaya_lexicon.dart';
import '../payments/payment_method_selection_page.dart';

class TicketPurchasePage extends StatefulWidget {
  final Lottery lottery;

  const TicketPurchasePage({super.key, required this.lottery});

  @override
  State<TicketPurchasePage> createState() => _TicketPurchasePageState();
}

class _TicketPurchasePageState extends State<TicketPurchasePage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  int _selectedQuantity = 1;
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotal();
    _loadUserPhone();
  }

  void _loadUserPhone() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.phone != null) {
      _phoneController.text = authProvider.user!.phone!;
    }
  }

  void _calculateTotal() {
    setState(() {
      _totalAmount = widget.lottery.ticketPrice * _selectedQuantity;
    });
  }

  void _onQuantityChanged(String value) {
    final quantity = int.tryParse(value) ?? 1;
    final maxTickets = widget.lottery.remainingTickets;
    if (quantity > 0 && quantity <= maxTickets) {
      setState(() {
        _selectedQuantity = quantity;
        _calculateTotal();
      });
    }
  }

  Future<void> _proceedToPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Créer la transaction/commande via LotteryProvider
      final lotteryProvider = Provider.of<LotteryProvider>(context, listen: false);

      final result = await lotteryProvider.buyTicket(
        widget.lottery.id,
        _selectedQuantity,
      );

      if (result && mounted) {
        // Transaction créée avec succès, récupérer la référence
        final transactionRef = lotteryProvider.lastTransactionReference;

        if (transactionRef != null) {
          // Rediriger vers la page de sélection de méthode de paiement
          final paymentResult = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentMethodSelectionPage(
                orderNumber: transactionRef,
                amount: _totalAmount,
                productName: widget.lottery.title,
                orderType: 'lottery',
              ),
            ),
          );

          if (paymentResult == true && mounted) {
            // Paiement réussi
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${KoumbayaLexicon.tickets} achetés avec succès !'),
                backgroundColor: AppConstants.lotteryColor,
              ),
            );
          }
        } else {
          throw Exception('Référence de transaction manquante');
        }
      } else {
        throw Exception('Échec de la création de la transaction');
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Acheter des ${KoumbayaLexicon.tickets.toLowerCase()}'), elevation: 0),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductSummary(),
                    const SizedBox(height: 24),
                    _buildQuantitySelector(),
                    const SizedBox(height: 24),
                    _buildPhoneNumberField(),
                    const SizedBox(height: 24),
                    _buildPriceSummary(),
                    const SizedBox(height: 24),
                    _buildPaymentInfo(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image:
                    widget.lottery.product?.hasImages == true
                        ? DecorationImage(
                          image: NetworkImage(
                            widget.lottery.product!.displayImage,
                          ),
                          fit: BoxFit.cover,
                        )
                        : null,
                color: Colors.grey[200],
              ),
              child:
                  widget.lottery.product?.hasImages != true
                      ? const Icon(Icons.image, color: Colors.grey)
                      : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lottery.product?.name ?? 'Produit non disponible',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tombola ${widget.lottery.lotteryNumber}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.lottery.ticketPrice.toStringAsFixed(0)} FCFA/${KoumbayaLexicon.ticket.toLowerCase()}',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre de ${KoumbayaLexicon.tickets.toLowerCase()}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Boutons -/+
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed:
                            _selectedQuantity > 1
                                ? () {
                                  setState(() {
                                    _selectedQuantity--;
                                    _quantityController.text =
                                        _selectedQuantity.toString();
                                    _calculateTotal();
                                  });
                                }
                                : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextFormField(
                          controller: _quantityController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: _onQuantityChanged,
                          validator: (value) {
                            final quantity = int.tryParse(value ?? '');
                            if (quantity == null || quantity < 1) {
                              return 'Min: 1';
                            }
                            if (quantity > widget.lottery.remainingTickets) {
                              return 'Max: ${widget.lottery.remainingTickets}';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        onPressed:
                            _selectedQuantity < widget.lottery.remainingTickets
                                ? () {
                                  setState(() {
                                    _selectedQuantity++;
                                    _quantityController.text =
                                        _selectedQuantity.toString();
                                    _calculateTotal();
                                  });
                                }
                                : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Disponibles: ${widget.lottery.remainingTickets} ${KoumbayaLexicon.tickets.toLowerCase()}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Boutons rapides
            Wrap(
              spacing: 8,
              children:
                  [1, 2, 3, 5, 10, 20, 50].where((q) => q <= widget.lottery.remainingTickets).map((quantity) {
                    return FilterChip(
                      label: Text('$quantity'),
                      selected: _selectedQuantity == quantity,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedQuantity = quantity;
                            _quantityController.text = quantity.toString();
                            _calculateTotal();
                          });
                        }
                      },
                      selectedColor: AppConstants.lotteryColor.withValues(alpha: 0.2),
                      checkmarkColor: AppConstants.lotteryColor,
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Numéro de téléphone',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Numéro pour le paiement Mobile Money',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone',
                hintText: 'Ex: 074123456',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.buttonBorderRadius,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer votre numéro';
                }
                if (value.trim().length < 8) {
                  return 'Numéro trop court';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé du prix',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Prix unitaire:'),
                Text('${widget.lottery.ticketPrice.toStringAsFixed(0)} FCFA'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quantité:'),
                Text(
                  KoumbayaLexicon.ticketCount(_selectedQuantity),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
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
                  '${_totalAmount.toStringAsFixed(0)} FCFA',
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

  Widget _buildPaymentInfo() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Paiement Mobile Money',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• Vous serez redirigé vers le paiement Mobile Money\n'
              '• Opérateurs supportés: Airtel Money, Moov Money\n'
              '• Suivez les instructions sur votre téléphone\n'
              '• Vos ${KoumbayaLexicon.tickets.toLowerCase()} seront créés après paiement confirmé',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.blue[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total à payer:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${_totalAmount.toStringAsFixed(0)} FCFA',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _proceedToPayment,
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                      : const Text(
                        'Procéder au paiement',
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
}
