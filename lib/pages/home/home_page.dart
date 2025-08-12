import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/lottery_provider.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    final lotteryProvider = Provider.of<LotteryProvider>(context, listen: false);

    await Future.wait([
      productsProvider.loadFeaturedProducts(),
      productsProvider.loadProducts(refresh: true),
      lotteryProvider.loadActiveLotteries(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              height: 32,
              width: 100,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.user != null) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      Text(
                        'Salut ${authProvider.user!.firstName}!',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppConstants.primaryColor,
                        child: Text(
                          authProvider.user!.firstName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: AppConstants.primaryColor,
          tabs: const [
            Tab(
              icon: Icon(Icons.star),
              text: 'Vedettes',
            ),
            Tab(
              icon: Icon(Icons.grid_view),
              text: 'Produits',
            ),
            Tab(
              icon: Icon(Icons.casino),
              text: 'Tombolas',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeaturedTab(),
          _buildProductsTab(),
          _buildLotteriesTab(),
        ],
      ),
    );
  }

  Widget _buildFeaturedTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Consumer<ProductsProvider>(
        builder: (context, productsProvider, child) {
          if (productsProvider.isFeaturedLoading && productsProvider.featuredProducts.isEmpty) {
            return const LoadingWidget(message: 'Chargement des produits vedettes...');
          }

          if (productsProvider.featuredProducts.isEmpty) {
            return const EmptyStateWidget(
              title: 'Aucun produit vedette',
              subtitle: 'Les produits vedettes apparaîtront ici',
              icon: Icons.star_outline,
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produits vedettes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: productsProvider.featuredProducts.length,
                    itemBuilder: (context, index) {
                      final product = productsProvider.featuredProducts[index];
                      return ProductCard(
                        product: product,
                        showProgress: true,
                        onTap: () {
                          productsProvider.selectProduct(product);
                          Navigator.of(context).pushNamed(
                            '/product',
                            arguments: product.id,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsTab() {
    return RefreshIndicator(
      onRefresh: () => Provider.of<ProductsProvider>(context, listen: false)
          .loadProducts(refresh: true),
      child: Consumer<ProductsProvider>(
        builder: (context, productsProvider, child) {
          if (productsProvider.isLoading && productsProvider.products.isEmpty) {
            return const LoadingWidget(message: 'Chargement des produits...');
          }

          if (productsProvider.products.isEmpty) {
            return const EmptyStateWidget(
              title: 'Aucun produit',
              subtitle: 'Les produits apparaîtront ici',
              icon: Icons.shopping_bag_outlined,
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Tous les produits',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/categories');
                      },
                      icon: const Icon(Icons.category),
                      label: const Text('Catégories'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: productsProvider.products.length,
                    itemBuilder: (context, index) {
                      final product = productsProvider.products[index];
                      return ProductCard(
                        product: product,
                        showProgress: true,
                        onTap: () {
                          productsProvider.selectProduct(product);
                          Navigator.of(context).pushNamed(
                            '/product',
                            arguments: product.id,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLotteriesTab() {
    return RefreshIndicator(
      onRefresh: () => Provider.of<LotteryProvider>(context, listen: false)
          .loadActiveLotteries(),
      child: Consumer<LotteryProvider>(
        builder: (context, lotteryProvider, child) {
          if (lotteryProvider.isLoading && lotteryProvider.activeLotteries.isEmpty) {
            return const LoadingWidget(message: 'Chargement des tombolas...');
          }

          if (lotteryProvider.activeLotteries.isEmpty) {
            return const EmptyStateWidget(
              title: 'Aucune tombola active',
              subtitle: 'Les tombolas actives apparaîtront ici',
              icon: Icons.casino_outlined,
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tombolas actives',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: lotteryProvider.activeLotteries.length,
                    itemBuilder: (context, index) {
                      final lottery = lotteryProvider.activeLotteries[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: AppConstants.primaryColor,
                            child: Text(
                              '#${lottery.id}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            lottery.product?.title ?? 'Produit #${lottery.productId}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(lottery.formattedTicketPrice),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: lottery.completionPercentage / 100,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppConstants.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${lottery.soldTickets}/${lottery.totalTickets} billets vendus',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: AppConstants.primaryColor,
                            size: 16,
                          ),
                          onTap: () {
                            lotteryProvider.selectLottery(lottery);
                            Navigator.of(context).pushNamed(
                              '/lottery',
                              arguments: lottery.id,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}