import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/koumbaya_button.dart';
import '../../widgets/loading_widget.dart';
import 'order_detail_page.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String selectedStatus = 'all';

  final Map<String, String> statusFilters = {
    'all': 'Toutes',
    'pending': 'En attente',
    'awaiting_payment': 'Attente paiement',
    'paid': 'Payées',
    'fulfilled': 'Livrées',
    'cancelled': 'Annulées',
    'expired': 'Expirées',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statusFilters.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    final orderProvider = context.read<OrderProvider>();
    await orderProvider.loadOrders(
      page: 1,
      status: selectedStatus == 'all' ? null : selectedStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Mes Commandes', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (kDebugMode) {
            print('🛒 OrderTrackingPage - Provider state:');
            print('   isLoading: ${orderProvider.isLoading}');
            print('   orders.length: ${orderProvider.orders.length}');
            print('   error: ${orderProvider.error}');
          }

          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
            return const Center(child: LoadingWidget());
          }

          return Column(
            children: [
              // Stats Cards
              _buildStatsCards(orderProvider.getOrderStats()),
              
              // Filtres par onglets
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: AppTextStyles.navLabel.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: AppTextStyles.navLabel.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  onTap: (index) {
                    final status = statusFilters.keys.elementAt(index);
                    setState(() {
                      selectedStatus = status;
                    });
                    _loadOrders();
                  },
                  tabs: statusFilters.values
                      .map((label) => Tab(
                        height: 48,
                        child: Text(label),
                      ))
                      .toList(),
                ),
              ),

              // Liste des commandes
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: _buildOrdersList(orderProvider),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/products'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Nouvelle commande'),
      ),
    );
  }

  Widget _buildStatsCards(Map<String, int> stats) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard(
            'Total',
            stats['total']?.toString() ?? '0',
            AppColors.primary,
            Icons.shopping_bag,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Payées',
            stats['paid']?.toString() ?? '0',
            Colors.green,
            Icons.check_circle,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'En attente',
            stats['pending']?.toString() ?? '0',
            Colors.orange,
            Icons.hourglass_empty,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Livrées',
            stats['fulfilled']?.toString() ?? '0',
            Colors.blue,
            Icons.local_shipping,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.h5.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(OrderProvider orderProvider) {
    if (orderProvider.orders.isEmpty) {
      return _buildEmptyState();
    }

    final filteredOrders = selectedStatus == 'all'
        ? orderProvider.orders
        : orderProvider.getOrdersByStatus(selectedStatus);

    if (filteredOrders.isEmpty) {
      return _buildEmptyFilterState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToOrderDetail(order),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête de la commande
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.displayTitle,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '#${order.orderNumber}',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(order.status, order.statusText),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Détails de la commande
                Row(
                  children: [
                    Icon(
                      order.isLotteryOrder 
                        ? Icons.confirmation_number
                        : Icons.shopping_cart,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.typeText,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(order.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${order.totalAmount.toStringAsFixed(0)} FCFA',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                // Actions selon le statut
                if (order.canBePaid || order.canBeCancelled) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (order.canBePaid) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _retryPayment(order),
                            icon: const Icon(Icons.payment, size: 16),
                            label: const Text('Payer'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                        if (order.canBeCancelled) const SizedBox(width: 12),
                      ],
                      if (order.canBeCancelled)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _cancelOrder(order),
                            icon: const Icon(Icons.cancel, size: 16),
                            label: const Text('Annuler'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, String statusText) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'paid':
      case 'fulfilled':
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green[700]!;
        break;
      case 'pending':
      case 'awaiting_payment':
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange[700]!;
        break;
      case 'failed':
      case 'cancelled':
      case 'expired':
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red[700]!;
        break;
      default:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune commande',
              style: AppTextStyles.h4.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous n\'avez pas encore passé de commande.\nCommencez par explorer nos articles !',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            KoumbayaButton(
              text: 'Découvrir les articles',
              onPressed: () => Navigator.pushNamed(context, '/products'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune commande ${statusFilters[selectedStatus]?.toLowerCase()}',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune commande ne correspond à ce filtre',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToOrderDetail(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailPage(order: order),
      ),
    );
  }

  Future<void> _retryPayment(Order order) async {
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reprendre le paiement'),
          content: Text(
            'Voulez-vous reprendre le paiement pour la commande #${order.orderNumber} ?',
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
        // Rediriger vers la page de paiement
        Navigator.pushNamed(
          context,
          '/payment/method',
          arguments: {
            'orderNumber': order.orderNumber,
            'amount': order.totalAmount,
            'productName': order.displayTitle,
            'orderType': order.type,
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelOrder(Order order) async {
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Annuler la commande'),
          content: Text(
            'Êtes-vous sûr de vouloir annuler la commande #${order.orderNumber} ?',
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
        final orderProvider = context.read<OrderProvider>();
        final success = await orderProvider.cancelOrder(order.orderNumber);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Commande annulée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${orderProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher une commande'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Numéro de commande (ex: ORD-123)',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            if (value.isNotEmpty) {
              _searchOrder(value);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Future<void> _searchOrder(String orderNumber) async {
    try {
      final orderProvider = context.read<OrderProvider>();
      await orderProvider.loadOrder(orderNumber);
      
      final order = orderProvider.selectedOrder;
      if (order != null && mounted) {
        _navigateToOrderDetail(order);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande non trouvée'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de recherche: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}