import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ticket_with_details.dart';
import '../../providers/lottery_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_constants.dart';
import '../../widgets/loading_widget.dart';
import '../products/product_detail_page.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTickets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTickets() {
    context.read<LotteryProvider>().getUserTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Mes Tickets', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tous'),
            Tab(text: 'En cours'),
            Tab(text: 'Gagnants'),
            Tab(text: 'Terminés'),
          ],
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(
            fontFamily: 'AmazonEmberDisplay',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          labelColor: Colors.white,
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: Consumer<LotteryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.userTickets.isEmpty) {
                  return const LoadingWidget();
                }

                if (provider.userTickets.isEmpty) {
                  return _buildEmptyState();
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTicketsList(provider.userTickets),
                    _buildTicketsList(
                      _filterTicketsByStatus(provider.userTickets, 'active'),
                    ),
                    _buildTicketsList(
                      _filterTicketsByStatus(provider.userTickets, 'winner'),
                    ),
                    _buildTicketsList(
                      _filterTicketsByStatus(provider.userTickets, 'completed'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Consumer<LotteryProvider>(
      builder: (context, provider, child) {
        final tickets = provider.userTickets;
        final totalTickets = tickets.length;
        final activeTickets = _filterTicketsByStatus(tickets, 'active').length;
        final winnerTickets = _filterTicketsByStatus(tickets, 'winner').length;
        final totalSpent = tickets.fold<double>(
          0,
          (sum, t) => sum + t.ticket.pricePaid,
        );

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                totalTickets.toString(),
                Icons.confirmation_number,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'En cours',
                activeTickets.toString(),
                Icons.timer,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Gagnants',
                winnerTickets.toString(),
                Icons.emoji_events,
                Colors.amber,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Dépensé',
                '${totalSpent.toInt()} F',
                Icons.account_balance_wallet,
                AppConstants.primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'AmazonEmberDisplay',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'AmazonEmberDisplay',
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsList(List<TicketWithDetails> tickets) {
    final filteredTickets =
        _searchQuery.isEmpty
            ? tickets
            : tickets
                .where(
                  (t) => t.productName.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                )
                .toList();

    if (filteredTickets.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => _loadTickets(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredTickets.length,
        itemBuilder: (context, index) {
          final ticketDetail = filteredTickets[index];
          return _buildTicketCard(ticketDetail);
        },
      ),
    );
  }

  Widget _buildTicketCard(TicketWithDetails ticketDetail) {
    final ticket = ticketDetail.ticket;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTicketDetails(ticketDetail),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child:
                        ticketDetail.productImage.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                ticketDetail.productImage,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Icon(Icons.image_not_supported),
                              ),
                            )
                            : const Icon(Icons.card_giftcard, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticketDetail.productName,
                          style: const TextStyle(
                            fontFamily: 'AmazonEmberDisplay',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ticket #${ticket.ticketNumber}',
                          style: TextStyle(
                            fontFamily: 'AmazonEmberDisplay',
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Prix payé: ${ticket.pricePaid.toInt()} FCFA',
                          style: TextStyle(
                            fontFamily: 'AmazonEmberDisplay',
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(ticketDetail),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Acheté le ${_formatDate(ticket.createdAt)}',
                    style: TextStyle(
                      fontFamily: 'AmazonEmberDisplay',
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  if (ticketDetail.drawDate != null) ...[
                    Icon(Icons.event, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      'Tirage: ${_formatDate(ticketDetail.drawDate!)}',
                      style: TextStyle(
                        fontFamily: 'AmazonEmberDisplay',
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(TicketWithDetails ticketDetail) {
    Color chipColor;
    Color textColor;

    if (ticketDetail.ticket.isWinner) {
      chipColor = Colors.amber;
      textColor = Colors.white;
    } else if (ticketDetail.isLotteryActive) {
      chipColor = Colors.blue;
      textColor = Colors.white;
    } else if (ticketDetail.isLotteryCompleted) {
      chipColor = Colors.grey;
      textColor = Colors.white;
    } else {
      chipColor = AppColors.primary;
      textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        ticketDetail.ticketStatusText,
        style: TextStyle(
          fontFamily: 'AmazonEmberDisplay',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun ticket trouvé',
            style: TextStyle(
              fontFamily: 'AmazonEmberDisplay',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Participez à des tombolas pour voir vos tickets ici',
            style: TextStyle(
              fontFamily: 'AmazonEmberDisplay',
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
            icon: const Icon(Icons.explore),
            label: const Text('Découvrir les produits'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  List<TicketWithDetails> _filterTicketsByStatus(
    List<TicketWithDetails> tickets,
    String status,
  ) {
    switch (status) {
      case 'active':
        return tickets.where((t) => t.isLotteryActive).toList();
      case 'winner':
        return tickets.where((t) => t.ticket.isWinner).toList();
      case 'completed':
        return tickets.where((t) => t.isLotteryCompleted).toList();
      default:
        return tickets;
    }
  }

  void _showTicketDetails(TicketWithDetails ticketDetail) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTicketDetailModal(ticketDetail),
    );
  }

  Widget _buildTicketDetailModal(TicketWithDetails ticketDetail) {
    final ticket = ticketDetail.ticket;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Détails du ticket',
                          style: TextStyle(
                            fontFamily: 'AmazonEmberDisplay',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        _buildStatusChip(ticketDetail),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('Numéro du ticket', ticket.ticketNumber),
                    _buildDetailRow('Produit', ticketDetail.productName),
                    _buildDetailRow(
                      'Prix payé',
                      '${ticket.pricePaid.toInt()} FCFA',
                    ),
                    _buildDetailRow(
                      'Date d\'achat',
                      _formatDate(ticket.createdAt),
                    ),
                    if (ticket.paymentReference != null)
                      _buildDetailRow(
                        'Référence paiement',
                        ticket.paymentReference!,
                      ),
                    if (ticketDetail.drawDate != null)
                      _buildDetailRow(
                        'Date de tirage',
                        _formatDate(ticketDetail.drawDate!),
                      ),
                    const SizedBox(height: 24),
                    if (ticket.isWinner) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              size: 48,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Félicitations ! 🎉',
                              style: TextStyle(
                                fontFamily: 'AmazonEmberDisplay',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Vous avez gagné ce produit !',
                              style: TextStyle(
                                fontFamily: 'AmazonEmberDisplay',
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _claimPrize(ticketDetail),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.orange,
                              ),
                              child: const Text('Réclamer mon prix'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              if (ticketDetail.product != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ProductDetailPage(
                                          productId: ticketDetail.product!.id,
                                        ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.visibility),
                            label: const Text('Voir le produit'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _shareTicket(ticketDetail),
                            icon: const Icon(Icons.share),
                            label: const Text('Partager'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'AmazonEmberDisplay',
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'AmazonEmberDisplay',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _claimPrize(TicketWithDetails ticketDetail) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Réclamer votre prix'),
            content: const Text(
              'Pour réclamer votre prix, veuillez contacter notre service client avec votre numéro de ticket.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implémenter contact service client
                },
                child: const Text('Contacter'),
              ),
            ],
          ),
    );
  }

  void _shareTicket(TicketWithDetails ticketDetail) {
    // TODO: Implémenter partage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité de partage à venir !')),
    );
  }
}
