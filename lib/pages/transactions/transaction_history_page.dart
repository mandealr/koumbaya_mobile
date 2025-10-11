import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/koumbaya_lexicon.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/date_range_picker_widget.dart';
import '../products/product_detail_page.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  String _searchQuery = '';

  // Filtres avancés
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _filterStatus;
  double? _filterMinAmount;
  double? _filterMaxAmount;
  String _sortBy = 'date_desc'; // date_desc, date_asc, amount_desc, amount_asc

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      context.read<TransactionProvider>().loadMoreTransactions();
    }
  }

  void _loadData() {
    final provider = context.read<TransactionProvider>();
    provider.loadTransactions(refresh: true);
    provider.loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Historique des transactions',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterModal,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          _buildSearchAndStats(),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                if (kDebugMode) {
                  print('💰 TransactionHistoryPage - Provider state:');
                  print('   isLoading: ${provider.isLoading}');
                  print('   transactions.length: ${provider.transactions.length}');
                  print('   errorMessage: ${provider.errorMessage}');
                }

                if (provider.isLoading && provider.transactions.isEmpty) {
                  return const LoadingWidget();
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTransactionsList(provider.transactions),
                    _buildTransactionsList(
                      provider.getTransactionsByType('lottery_ticket')
                    ),
                    _buildTransactionsList(
                      provider.getTransactionsByType('product_purchase')
                    ),
                    _buildTransactionsList(
                      provider.getTransactionsByType('refund')
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
        isScrollable: false,
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
        onTap: _onTabChanged,
        tabs: [
          const Tab(height: 48, child: Text('Toutes')),
          Tab(height: 48, child: Text(KoumbayaLexicon.tickets)),
          Tab(height: 48, child: Text(KoumbayaLexicon.directPurchase)),
          const Tab(height: 48, child: Text('Remboursements')),
        ],
      ),
    );
  }

  Widget _buildSearchAndStats() {
    final hasActiveFilters = _filterStartDate != null ||
        _filterEndDate != null ||
        _filterStatus != null ||
        _filterMinAmount != null ||
        _filterMaxAmount != null ||
        _sortBy != 'date_desc';

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
              hintText: 'Rechercher une transaction...',
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
          if (hasActiveFilters) ...[
            const SizedBox(height: 12),
            _buildActiveFiltersChips(),
          ],
          const SizedBox(height: 12),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    final filters = <Widget>[];

    if (_filterStartDate != null && _filterEndDate != null) {
      filters.add(
        Chip(
          label: Text(
            '${_formatDateShort(_filterStartDate!)} - ${_formatDateShort(_filterEndDate!)}',
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: AppColors.primary.withOpacity(0.1),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() {
              _filterStartDate = null;
              _filterEndDate = null;
            });
          },
        ),
      );
    }

    if (_filterStatus != null) {
      filters.add(
        Chip(
          label: Text(
            'Statut: $_filterStatus',
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: AppColors.primary.withOpacity(0.1),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() {
              _filterStatus = null;
            });
          },
        ),
      );
    }

    if (_filterMinAmount != null || _filterMaxAmount != null) {
      final amountText = _filterMinAmount != null && _filterMaxAmount != null
          ? '${_filterMinAmount!.toInt()} - ${_filterMaxAmount!.toInt()} FCFA'
          : _filterMinAmount != null
              ? '≥ ${_filterMinAmount!.toInt()} FCFA'
              : '≤ ${_filterMaxAmount!.toInt()} FCFA';

      filters.add(
        Chip(
          label: Text(
            amountText,
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: AppColors.primary.withOpacity(0.1),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() {
              _filterMinAmount = null;
              _filterMaxAmount = null;
            });
          },
        ),
      );
    }

    if (_sortBy != 'date_desc') {
      final sortText = {
        'date_asc': 'Plus ancien',
        'amount_desc': 'Montant ↓',
        'amount_asc': 'Montant ↑',
      }[_sortBy] ?? '';

      filters.add(
        Chip(
          label: Text(
            'Tri: $sortText',
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: AppColors.primary.withOpacity(0.1),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() {
              _sortBy = 'date_desc';
            });
          },
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: filters,
    );
  }

  String _formatDateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  Widget _buildStatsRow() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final totalSpent = provider.totalSpent;
        final totalRefunded = provider.totalRefunded;
        final totalTransactions = provider.transactions.length;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total dépensé',
                '${totalSpent.toInt()} F',
                Icons.trending_up,
                Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Remboursements',
                '${totalRefunded.toInt()} F',
                Icons.trending_down,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Transactions',
                totalTransactions.toString(),
                Icons.receipt,
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

  Widget _buildTransactionsList(List<Transaction> transactions) {
    var filteredTransactions = transactions;

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      filteredTransactions = filteredTransactions.where((t) =>
        t.displayTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.reference?.toLowerCase().contains(_searchQuery.toLowerCase()) == true
      ).toList();
    }

    // Filtrer par période
    if (_filterStartDate != null && _filterEndDate != null) {
      filteredTransactions = filteredTransactions.where((t) {
        return t.createdAt.isAfter(_filterStartDate!.subtract(const Duration(days: 1))) &&
               t.createdAt.isBefore(_filterEndDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Filtrer par statut
    if (_filterStatus != null) {
      filteredTransactions = filteredTransactions
          .where((t) => t.status == _filterStatus)
          .toList();
    }

    // Filtrer par montant
    if (_filterMinAmount != null) {
      filteredTransactions = filteredTransactions
          .where((t) => t.amount >= _filterMinAmount!)
          .toList();
    }
    if (_filterMaxAmount != null) {
      filteredTransactions = filteredTransactions
          .where((t) => t.amount <= _filterMaxAmount!)
          .toList();
    }

    // Trier
    switch (_sortBy) {
      case 'date_asc':
        filteredTransactions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'date_desc':
        filteredTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'amount_asc':
        filteredTransactions.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'amount_desc':
        filteredTransactions.sort((a, b) => b.amount.compareTo(a.amount));
        break;
    }

    if (filteredTransactions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: filteredTransactions.length + 
            (context.watch<TransactionProvider>().hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= filteredTransactions.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          
          final transaction = filteredTransactions[index];
          return _buildTransactionCard(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTransactionDetails(transaction),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTransactionIcon(transaction),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.displayTitle,
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
                          transaction.typeText,
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
                        '${transaction.isRefund ? '+' : '-'}${transaction.amount.toInt()} FCFA',
                        style: TextStyle(
                          fontFamily: 'AmazonEmberDisplay',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: transaction.isRefund ? AppColors.primary : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(transaction),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(transaction.createdAt),
                    style: TextStyle(
                      fontFamily: 'AmazonEmberDisplay',
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  if (transaction.reference != null) ...[
                    Icon(
                      Icons.numbers,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      transaction.reference!,
                      style: TextStyle(
                        fontFamily: 'AmazonEmberDisplay',
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
              if (transaction.quantity != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.confirmation_number,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Quantité: ${transaction.quantity}',
                      style: TextStyle(
                        fontFamily: 'AmazonEmberDisplay',
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionIcon(Transaction transaction) {
    IconData icon;
    Color color;

    switch (transaction.type) {
      case 'lottery_ticket':
        icon = Icons.confirmation_number;
        color = AppColors.primary;
        break;
      case 'product_purchase':
        icon = Icons.shopping_cart;
        color = AppColors.primary;
        break;
      case 'refund':
        icon = Icons.keyboard_return;
        color = Colors.orange;
        break;
      default:
        icon = Icons.receipt;
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

  Widget _buildStatusChip(Transaction transaction) {
    Color chipColor;
    Color textColor;
    
    switch (transaction.status) {
      case 'completed':
        chipColor = AppColors.primary;
        textColor = Colors.white;
        break;
      case 'pending':
        chipColor = Colors.orange;
        textColor = Colors.white;
        break;
      case 'failed':
        chipColor = Colors.red;
        textColor = Colors.white;
        break;
      case 'cancelled':
        chipColor = Colors.grey;
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
        transaction.statusText,
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
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune transaction trouvée',
            style: TextStyle(
              fontFamily: 'AmazonEmberDisplay',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos transactions apparaîtront ici',
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
            label: Text('Découvrir les ${KoumbayaLexicon.articles.toLowerCase()}'),
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
    final provider = context.read<TransactionProvider>();
    String? filterType;
    
    switch (index) {
      case 1:
        filterType = 'lottery_ticket';
        break;
      case 2:
        filterType = 'product_purchase';
        break;
      case 3:
        filterType = 'refund';
        break;
      default:
        filterType = null;
    }
    
    provider.applyFilters(type: filterType);
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterModal(),
    );
  }

  Widget _buildFilterModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Text(
                  'Filtrer les transactions',
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
          ),
          const Divider(height: 1),

          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtre par période
                  DateRangePickerWidget(
                    startDate: _filterStartDate,
                    endDate: _filterEndDate,
                    onDateRangeSelected: (start, end) {
                      setState(() {
                        _filterStartDate = start;
                        _filterEndDate = end;
                      });
                    },
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Filtre par statut
                  const Text(
                    'Statut',
                    style: TextStyle(
                      fontFamily: 'AmazonEmberDisplay',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildStatusFilter('Tous', null),
                      _buildStatusFilter('Complété', 'completed'),
                      _buildStatusFilter('En attente', 'pending'),
                      _buildStatusFilter('Échoué', 'failed'),
                      _buildStatusFilter('Annulé', 'cancelled'),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Filtre par montant
                  const Text(
                    'Montant',
                    style: TextStyle(
                      fontFamily: 'AmazonEmberDisplay',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Minimum (FCFA)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _filterMinAmount = double.tryParse(value);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Maximum (FCFA)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _filterMaxAmount = double.tryParse(value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Tri
                  const Text(
                    'Trier par',
                    style: TextStyle(
                      fontFamily: 'AmazonEmberDisplay',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSortFilter('Plus récent', 'date_desc'),
                      _buildSortFilter('Plus ancien', 'date_asc'),
                      _buildSortFilter('Montant ↓', 'amount_desc'),
                      _buildSortFilter('Montant ↑', 'amount_asc'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Footer avec boutons d'action
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _filterStartDate = null;
                        _filterEndDate = null;
                        _filterStatus = null;
                        _filterMinAmount = null;
                        _filterMaxAmount = null;
                        _sortBy = 'date_desc';
                      });
                      context.read<TransactionProvider>().clearFilters();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Réinitialiser'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _applyFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Appliquer'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(String label, String? value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontFamily: 'AmazonEmberDisplay',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: isSelected ? Colors.white : Colors.grey[700],
      ),
      backgroundColor: Colors.grey[100],
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildSortFilter(String label, String value) {
    final isSelected = _sortBy == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortBy = value;
        });
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontFamily: 'AmazonEmberDisplay',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: isSelected ? Colors.white : Colors.grey[700],
      ),
      backgroundColor: Colors.grey[100],
      checkmarkColor: Colors.white,
    );
  }

  void _applyFilters() {
    // Cette méthode appliquera les filtres localement
    // car le TransactionProvider ne semble pas avoir de méthodes pour tous ces filtres
    setState(() {}); // Force rebuild avec les nouveaux filtres
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTransactionDetailModal(transaction),
    );
  }

  Widget _buildTransactionDetailModal(Transaction transaction) {
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
                        Expanded(
                          child: Text(
                            'Détails de la transaction',
                            style: const TextStyle(
                              fontFamily: 'AmazonEmberDisplay',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(transaction),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('Type', transaction.typeText),
                    _buildDetailRow('Montant', '${transaction.amount.toInt()} FCFA'),
                    if (transaction.reference != null)
                      _buildDetailRow('Référence', transaction.reference!),
                    if (transaction.paymentReference != null)
                      _buildDetailRow('Référence paiement', transaction.paymentReference!),
                    if (transaction.paymentMethod != null)
                      _buildDetailRow('Méthode de paiement', transaction.paymentMethod!),
                    if (transaction.quantity != null)
                      _buildDetailRow('Quantité', transaction.quantity.toString()),
                    _buildDetailRow('Date de création', _formatDate(transaction.createdAt)),
                    _buildDetailRow('Dernière mise à jour', _formatDate(transaction.updatedAt)),
                    const SizedBox(height: 24),
                    if (transaction.product != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailPage(
                                      productId: transaction.product!.id,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.visibility),
                              label: const Text('Voir le produit'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (transaction.isPending)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _cancelTransaction(transaction),
                                icon: const Icon(Icons.cancel),
                                label: const Text('Annuler'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
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

  void _cancelTransaction(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la transaction'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette transaction ? Cette action est irréversible.',
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
                  .read<TransactionProvider>()
                  .cancelTransaction(transaction.id);
              
              if (success && mounted) {
                Navigator.pop(context); // Close transaction details
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction annulée avec succès'),
                    backgroundColor: AppColors.primary,
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