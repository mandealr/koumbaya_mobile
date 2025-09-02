import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/refund.dart';
import '../../models/transaction.dart';
import '../../providers/refund_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_constants.dart';
import '../../widgets/loading_widget.dart';

class RefundManagementPage extends StatefulWidget {
  const RefundManagementPage({super.key});

  @override
  State<RefundManagementPage> createState() => _RefundManagementPageState();
}

class _RefundManagementPageState extends State<RefundManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.95) {
      context.read<RefundProvider>().loadMoreRefunds();
    }
  }

  void _loadData() {
    final provider = context.read<RefundProvider>();
    provider.loadRefunds(refresh: true);
    provider.loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Mes remboursements',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateRefundModal,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          _buildSearchAndStats(),
          Expanded(
            child: Consumer<RefundProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.refunds.isEmpty) {
                  return const LoadingWidget();
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRefundsList(provider.refunds),
                    _buildRefundsList(
                        provider.getRefundsByStatus('pending')),
                    _buildRefundsList(
                        provider.getRefundsByStatus('approved')),
                    _buildRefundsList(
                        provider.getRefundsByStatus('completed')),
                    _buildRefundsList(
                        provider.getRefundsByStatus('rejected')),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateRefundModal,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
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
        onTap: _onTabChanged,
        tabs: const [
          Tab(height: 48, child: Text('Toutes')),
          Tab(height: 48, child: Text('En attente')),
          Tab(height: 48, child: Text('Approuvées')),
          Tab(height: 48, child: Text('Terminées')),
          Tab(height: 48, child: Text('Rejetées')),
        ],
      ),
    );
  }

  Widget _buildSearchAndStats() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un remboursement...',
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
    return Consumer<RefundProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Montant reçu',
                '${provider.totalRefundAmount.toInt()} F',
                Icons.account_balance_wallet,
                AppConstants.primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'En attente',
                '${provider.pendingRefundAmount.toInt()} F',
                Icons.hourglass_empty,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Demandes',
                provider.refunds.length.toString(),
                Icons.receipt_long,
                AppColors.primary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRefundsList(List<Refund> refunds) {
    final filteredRefunds = _searchQuery.isEmpty
        ? refunds
        : refunds
            .where((r) => r.displayTitle
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    if (filteredRefunds.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: filteredRefunds.length +
            (context.watch<RefundProvider>().hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= filteredRefunds.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final refund = filteredRefunds[index];
          return _buildRefundCard(refund);
        },
      ),
    );
  }

  Widget _buildRefundCard(Refund refund) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showRefundDetails(refund),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildRefundIcon(refund),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          refund.displayTitle,
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
                          refund.reasonText,
                          style: TextStyle(
                            fontFamily: 'AmazonEmberDisplay',
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${refund.amount.toInt()} FCFA',
                        style: const TextStyle(
                          fontFamily: 'AmazonEmberDisplay',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(refund),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildRefundTimeline(refund),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Demandé le ${_formatDate(refund.createdAt)}',
                    style: TextStyle(
                      fontFamily: 'AmazonEmberDisplay',
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  if (refund.verificationCode != null) ...[
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: AppConstants.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Code: ${refund.verificationCode}',
                      style: TextStyle(
                        fontFamily: 'AmazonEmberDisplay',
                        fontSize: 12,
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w500,
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

  Widget _buildRefundIcon(Refund refund) {
    IconData icon;
    Color color;

    switch (refund.status) {
      case 'pending':
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      case 'approved':
        icon = Icons.check_circle_outline;
        color = Colors.blue;
        break;
      case 'processed':
        icon = Icons.sync;
        color = Colors.purple;
        break;
      case 'completed':
        icon = Icons.check_circle;
        color = AppConstants.primaryColor;
        break;
      case 'rejected':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.keyboard_return;
        color = Colors.grey;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildStatusChip(Refund refund) {
    Color chipColor;
    Color textColor;

    switch (refund.status) {
      case 'completed':
        chipColor = AppConstants.primaryColor;
        textColor = Colors.white;
        break;
      case 'approved':
        chipColor = Colors.blue;
        textColor = Colors.white;
        break;
      case 'processed':
        chipColor = Colors.purple;
        textColor = Colors.white;
        break;
      case 'pending':
        chipColor = Colors.orange;
        textColor = Colors.white;
        break;
      case 'rejected':
        chipColor = Colors.red;
        textColor = Colors.white;
        break;
      default:
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
        refund.statusText,
        style: TextStyle(
          fontFamily: 'AmazonEmberDisplay',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildRefundTimeline(Refund refund) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timeline,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              refund.timelineStatus,
              style: TextStyle(
                fontFamily: 'AmazonEmberDisplay',
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.keyboard_return_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun remboursement trouvé',
            style: TextStyle(
              fontFamily: 'AmazonEmberDisplay',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos demandes de remboursement apparaîtront ici',
            style: TextStyle(
              fontFamily: 'AmazonEmberDisplay',
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateRefundModal,
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle demande'),
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

  void _onTabChanged(int index) {
    final provider = context.read<RefundProvider>();
    String? filterStatus;

    switch (index) {
      case 1:
        filterStatus = 'pending';
        break;
      case 2:
        filterStatus = 'approved';
        break;
      case 3:
        filterStatus = 'completed';
        break;
      case 4:
        filterStatus = 'rejected';
        break;
      default:
        filterStatus = null;
    }

    provider.applyFilters(status: filterStatus);
  }

  void _showCreateRefundModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateRefundModal(),
    );
  }

  void _showRefundDetails(Refund refund) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRefundDetailModal(refund),
    );
  }

  Widget _buildRefundDetailModal(Refund refund) {
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
                          'Détails du remboursement',
                          style: TextStyle(
                            fontFamily: 'AmazonEmberDisplay',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        _buildStatusChip(refund),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('Montant', '${refund.amount.toInt()} FCFA'),
                    _buildDetailRow('Raison', refund.reasonText),
                    if (refund.description != null && refund.description!.isNotEmpty)
                      _buildDetailRow('Description', refund.description!),
                    if (refund.verificationCode != null)
                      _buildDetailRow('Code de vérification', refund.verificationCode!),
                    _buildDetailRow('Statut', refund.statusText),
                    _buildDetailRow('Date de demande', _formatDate(refund.createdAt)),
                    if (refund.processedAt != null)
                      _buildDetailRow('Date de traitement', _formatDate(refund.processedAt!)),
                    if (refund.completedAt != null)
                      _buildDetailRow('Date de completion', _formatDate(refund.completedAt!)),
                    if (refund.isRejected && refund.rejectionReason != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Raison du rejet',
                                  style: TextStyle(
                                    fontFamily: 'AmazonEmberDisplay',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              refund.rejectionReason!,
                              style: TextStyle(
                                fontFamily: 'AmazonEmberDisplay',
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (refund.canBeCancelled) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _cancelRefund(refund),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Annuler la demande'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
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
        '${date.year} à ${date.hour.toString().padLeft(2, '0')}h'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  void _cancelRefund(Refund refund) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la demande'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette demande de remboursement ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<RefundProvider>()
                  .cancelRefund(refund.id);

              if (success && mounted) {
                Navigator.pop(context); // Close refund details
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Demande annulée avec succès'),
                    backgroundColor: AppConstants.primaryColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }
}

class _CreateRefundModal extends StatefulWidget {
  @override
  State<_CreateRefundModal> createState() => _CreateRefundModalState();
}

class _CreateRefundModalState extends State<_CreateRefundModal> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  Transaction? _selectedTransaction;
  String? _selectedReason;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEligibleTransactions();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadEligibleTransactions() async {
    await context.read<RefundProvider>().loadEligibleTransactions();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Nouvelle demande de remboursement',
                  style: TextStyle(
                    fontFamily: 'AmazonEmberDisplay',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Expanded(child: LoadingWidget())
            else
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction à rembourser',
                        style: TextStyle(
                          fontFamily: 'AmazonEmberDisplay',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTransactionSelector(),
                      const SizedBox(height: 20),
                      const Text(
                        'Raison du remboursement',
                        style: TextStyle(
                          fontFamily: 'AmazonEmberDisplay',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildReasonSelector(),
                      const SizedBox(height: 20),
                      const Text(
                        'Description (optionnel)',
                        style: TextStyle(
                          fontFamily: 'AmazonEmberDisplay',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Décrivez votre problème...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Annuler'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Consumer<RefundProvider>(
                              builder: (context, provider, child) {
                                return ElevatedButton(
                                  onPressed: provider.isCreating
                                      ? null
                                      : _createRefund,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: provider.isCreating
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Créer'),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionSelector() {
    return Consumer<RefundProvider>(
      builder: (context, provider, child) {
        if (provider.eligibleTransactions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Text(
              'Aucune transaction éligible pour un remboursement.',
              style: TextStyle(
                fontFamily: 'AmazonEmberDisplay',
                color: Colors.grey,
              ),
            ),
          );
        }

        return DropdownButtonFormField<Transaction>(
          value: _selectedTransaction,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          hint: const Text('Sélectionnez une transaction'),
          items: provider.eligibleTransactions.map((transaction) {
            return DropdownMenuItem<Transaction>(
              value: transaction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    transaction.displayTitle,
                    style: const TextStyle(
                      fontFamily: 'AmazonEmberDisplay',
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${transaction.amount.toInt()} FCFA - ${transaction.statusText}',
                    style: TextStyle(
                      fontFamily: 'AmazonEmberDisplay',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (transaction) {
            setState(() {
              _selectedTransaction = transaction;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Veuillez sélectionner une transaction';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildReasonSelector() {
    final reasons = context.read<RefundProvider>().getRefundReasons();

    return DropdownButtonFormField<String>(
      value: _selectedReason,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      hint: const Text('Sélectionnez une raison'),
      items: reasons.map((reason) {
        return DropdownMenuItem<String>(
          value: reason['value'],
          child: Text(
            reason['label']!,
            style: const TextStyle(
              fontFamily: 'AmazonEmberDisplay',
            ),
          ),
        );
      }).toList(),
      onChanged: (reason) {
        setState(() {
          _selectedReason = reason;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner une raison';
        }
        return null;
      },
    );
  }

  void _createRefund() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<RefundProvider>().createRefund(
          transactionId: _selectedTransaction!.id,
          reason: _selectedReason!,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
        );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande de remboursement créée avec succès !'),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
    }
  }
}