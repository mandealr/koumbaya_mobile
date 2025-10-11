import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product.dart';
import '../../providers/products_provider.dart';
import '../../providers/lottery_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_constants.dart';
import '../../constants/koumbaya_lexicon.dart';
import '../../widgets/loading_widget.dart';
import '../payments/payment_method_selection_page.dart';
import '../lottery/ticket_purchase_page.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProduct();
    });
  }

  Future<void> _loadProduct() async {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    await productsProvider.loadProduct(widget.productId);
  }


  Future<void> _tryLuck() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      Navigator.of(context).pushNamed('/login');
      return;
    }

    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    final product = productsProvider.selectedProduct;

    if (product?.hasLottery != true || product!.activeLottery == null) return;

    // Rediriger vers la page d'achat de tickets
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketPurchasePage(
          lottery: product.activeLottery!,
        ),
      ),
    );

    // Si l'achat est réussi, rafraîchir les données du produit
    if (result == true && mounted) {
      await _loadProduct();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.casino, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Bonne chance ! Vos ${KoumbayaLexicon.tickets.toLowerCase()} ont été achetés !')),
              ],
            ),
            backgroundColor: AppConstants.lotteryColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _buyDirectly() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      Navigator.of(context).pushNamed('/login');
      return;
    }

    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    final purchaseProvider = Provider.of<PurchaseProvider>(context, listen: false);
    final product = productsProvider.selectedProduct;
    if (product == null) return;

    // Afficher une confirmation avant l'achat
    final shouldProceed = await _showPurchaseConfirmation(product);
    if (!shouldProceed) return;

    // Procéder à l'achat via le PurchaseProvider
    final result = await purchaseProvider.buyProductDirectly(product.id);

    if (mounted) {
      if (result != null && result['success'] == true) {
        // Rediriger vers la page de paiement
        final orderData = result['data'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentMethodSelectionPage(
              orderNumber: orderData['order_number'],
              amount: double.parse(orderData['amount']),
              productName: product.name,
              orderType: 'direct',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'achat: ${purchaseProvider.error ?? "Erreur inconnue"}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<bool> _showPurchaseConfirmation(Product product) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer l\'achat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir acheter cet ${KoumbayaLexicon.article.toLowerCase()} ?'),
            const SizedBox(height: 16),
            Text(
              product.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${KoumbayaLexicon.directPrice}: ${product.formattedPrice}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Acheter'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProductsProvider>(
        builder: (context, productsProvider, child) {
          if (productsProvider.isLoading || productsProvider.selectedProduct == null) {
            return const Scaffold(
              body: LoadingWidget(message: 'Chargement du produit...'),
            );
          }

          final product = productsProvider.selectedProduct!;

          return CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppConstants.primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: product.displayImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 60),
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.displayName,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: product.hasLottery
                                  ? AppConstants.lotteryColor
                                  : AppConstants.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              product.formattedPrice,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Badges
                      Row(
                        children: [
                          if (product.isFeatureProduct)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppConstants.accentColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'VEDETTE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (product.hasLottery) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppConstants.lotteryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'TOMBOLA ACTIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Vendeur Section
                      if (product.merchant != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: product.hasLottery
                                ? AppConstants.lightLotteryColor
                                : AppConstants.lightAccentColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: product.hasLottery
                                  ? AppConstants.lotteryColor.withValues(alpha: 0.3)
                                  : AppConstants.primaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: product.hasLottery
                                    ? AppConstants.lotteryColor
                                    : AppConstants.primaryColor,
                                radius: 24,
                                child: Text(
                                  (product.merchant!.businessName?.isNotEmpty == true
                                    ? product.merchant!.businessName![0]
                                    : product.merchant!.firstName[0]).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.merchant!.businessName ?? product.merchant!.fullName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: product.hasLottery
                                            ? AppConstants.lotteryColor
                                            : AppConstants.primaryColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      KoumbayaLexicon.seller,
                                      style: TextStyle(
                                        color: product.hasLottery
                                            ? AppConstants.lotteryColor.withValues(alpha: 0.7)
                                            : AppConstants.primaryColor.withValues(alpha: 0.7),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.displayDescription,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),

                      // Lottery Information
                      if (product.hasLottery) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        
                        Text(
                          'Information Tombola',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Progress
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progression',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              '${product.activeLottery!.completionPercentage.toInt()}%',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: product.activeLottery!.completionPercentage / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            product.hasLottery
                                ? AppConstants.lotteryColor
                                : AppConstants.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Lottery Stats
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                '${KoumbayaLexicon.tickets} vendus',
                                '${product.activeLottery!.soldTickets}',
                                Icons.confirmation_number,
                                product,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                KoumbayaLexicon.ticketsRemaining,
                                '${product.activeLottery!.remainingTickets}',
                                Icons.inventory,
                                product,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildStatCard(
                          KoumbayaLexicon.ticketPrice,
                          product.activeLottery!.formattedTicketPrice,
                          Icons.local_offer,
                          product,
                          fullWidth: true,
                        ),

                        const SizedBox(height: 24),

                      ],

                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer3<ProductsProvider, LotteryProvider, PurchaseProvider>(
        builder: (context, productsProvider, lotteryProvider, purchaseProvider, child) {
          final product = productsProvider.selectedProduct;
          if (product == null) {
            return const SizedBox.shrink();
          }

          final hasLottery = product.hasLottery;
          final totalPrice = hasLottery ? product.activeLottery!.ticketPrice : product.price;
          final buttonText = hasLottery ? 'Tenter votre chance' : KoumbayaLexicon.buyDirectly;
          final buttonIcon = hasLottery ? Icons.casino : Icons.shopping_cart;
          final priceLabel = hasLottery ? KoumbayaLexicon.ticketPrice : KoumbayaLexicon.directPrice;

          return Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        priceLabel,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${totalPrice.toStringAsFixed(0)} FCFA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: hasLottery
                              ? AppConstants.lotteryColor
                              : AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (lotteryProvider.isPurchasing || purchaseProvider.isPurchasing) ? null : (hasLottery ? _tryLuck : _buyDirectly),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasLottery
                                  ? AppConstants.lotteryColor
                                  : AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                              ),
                            ),
                            child: (lotteryProvider.isPurchasing || purchaseProvider.isPurchasing)
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        buttonIcon,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        buttonText,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
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
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Product product, {bool fullWidth = false}) {
    final color = product.hasLottery ? AppConstants.lotteryColor : AppConstants.primaryColor;
    final bgColor = product.hasLottery ? AppConstants.lightLotteryColor : AppConstants.lightAccentColor;

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}