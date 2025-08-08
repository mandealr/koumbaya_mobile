import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/lottery.dart';
import '../../providers/lottery_provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/loading_widget.dart';
import 'ticket_purchase_page.dart';

class LotteryDetailPage extends StatefulWidget {
  final int lotteryId;

  const LotteryDetailPage({
    super.key,
    required this.lotteryId,
  });

  @override
  State<LotteryDetailPage> createState() => _LotteryDetailPageState();
}

class _LotteryDetailPageState extends State<LotteryDetailPage> {
  bool _isLoading = true;
  Lottery? _lottery;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLotteryDetails();
  }

  Future<void> _loadLotteryDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final lotteryProvider = Provider.of<LotteryProvider>(context, listen: false);
      final lottery = await lotteryProvider.getLotteryDetails(widget.lotteryId);
      
      if (mounted) {
        setState(() {
          _lottery = lottery;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails tombola')),
        body: const LoadingWidget(),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur lors du chargement',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadLotteryDetails,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_lottery == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tombola introuvable')),
        body: const Center(
          child: Text('Cette tombola n\'existe pas.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_lottery!.lotteryNumber),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadLotteryDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductCard(),
              const SizedBox(height: 16),
              _buildLotteryInfo(),
              const SizedBox(height: 16),
              _buildProgressCard(),
              const SizedBox(height: 16),
              _buildTimeRemainingCard(),
              const SizedBox(height: 16),
              _buildMyTicketsCard(),
              const SizedBox(height: 24),
              _buildPurchaseButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du produit
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: _lottery!.product?.hasImages == true
                  ? DecorationImage(
                      image: NetworkImage(_lottery!.product!.displayImage),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: Colors.grey[200],
            ),
            child: _lottery!.product?.hasImages != true
                ? const Icon(Icons.image, size: 64, color: Colors.grey)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _lottery!.product?.name ?? 'Produit non disponible',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _lottery!.product?.description ?? 'Description non disponible',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.category, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _lottery!.product?.category?.name ?? 'Catégorie non disponible',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Valeur: ${(_lottery!.product?.price ?? 0).toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLotteryInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.confirmation_number, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Informations de la tombola',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Numéro:', _lottery!.lotteryNumber),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Prix du ticket:', 
              '${_lottery!.ticketPrice.toStringAsFixed(0)} FCFA'
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Total tickets:', 
              _lottery!.totalTickets.toString()
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Tickets vendus:', 
              _lottery!.soldTickets.toString()
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Statut:', 
              _getStatusText(_lottery!.status),
              statusColor: _getStatusColor(_lottery!.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final progress = _lottery!.soldTickets / _lottery!.totalTickets;
    final percentage = (progress * 100).toInt();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progression',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(AppConstants.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              '${_lottery!.soldTickets} / ${_lottery!.totalTickets} tickets vendus',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRemainingCard() {
    final now = DateTime.now();
    final endDate = _lottery!.endDate;
    final isExpired = now.isAfter(endDate);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isExpired ? Icons.timer_off : Icons.timer,
                  color: isExpired ? Colors.red : AppConstants.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  isExpired ? 'Tombola terminée' : 'Temps restant',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isExpired ? Colors.red : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isExpired) 
              Text(
                'Cette tombola s\'est terminée le ${_formatDate(endDate)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                ),
              )
            else
              _buildTimeRemaining(endDate),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRemaining(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    
    return Row(
      children: [
        if (days > 0) ...[
          _buildTimeUnit(days.toString(), 'Jours'),
          const SizedBox(width: 16),
        ],
        _buildTimeUnit(hours.toString().padLeft(2, '0'), 'Heures'),
        const SizedBox(width: 16),
        _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'Minutes'),
      ],
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildMyTicketsCard() {
    return Consumer<LotteryProvider>(
      builder: (context, lotteryProvider, child) {
        final myTickets = lotteryProvider.getMyTicketsForLottery(widget.lotteryId);
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt, color: AppConstants.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Mes tickets',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (myTickets.isEmpty)
                  Text(
                    'Vous n\'avez pas encore de tickets pour cette tombola.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  )
                else
                  Column(
                    children: [
                      Text(
                        'Vous avez ${myTickets.length} ticket(s)',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...myTickets.map((ticket) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Icon(Icons.confirmation_number, 
                                 size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(ticket.ticketNumber),
                          ],
                        ),
                      )),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPurchaseButton() {
    final isExpired = DateTime.now().isAfter(_lottery!.endDate);
    final isCompleted = _lottery!.status == 'completed';
    final isSoldOut = _lottery!.soldTickets >= _lottery!.totalTickets;
    
    if (isExpired || isCompleted || isSoldOut) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
          ),
          child: Text(
            isExpired 
                ? 'Tombola terminée'
                : isSoldOut 
                    ? 'Tickets épuisés'
                    : 'Tombola clôturée',
          ),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text('Se connecter pour participer'),
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TicketPurchasePage(lottery: _lottery!),
                ),
              );
            },
            child: Text(
              'Acheter des tickets - ${_lottery!.ticketPrice.toStringAsFixed(0)} FCFA',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? statusColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'active':
        return 'Active';
      case 'completed':
        return 'Terminée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}