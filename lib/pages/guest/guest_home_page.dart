import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_constants.dart';
import '../../providers/products_provider.dart';
import '../../providers/lottery_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../models/product.dart';
import '../../models/lottery.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<ProductsProvider>().loadFeaturedProducts();
    context.read<LotteryProvider>().loadActiveLotteries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(),
                _buildStatsSection(),
                _buildHowItWorksSection(),
                _buildFeaturedProducts(),
                _buildActiveLotteries(),
                _buildCallToActionSection(),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: SizedBox(
        height: 40,
        child: Image.asset(
          'assets/images/logo_white.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Row(
            children: [
              Icon(
                Icons.store,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Koumbaya MarketPlace',
                style: AppTextStyles.appBarTitle.copyWith(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: Colors.white),
          onSelected: (String value) {
            switch (value) {
              case 'about':
                context.go('/guest/about');
                break;
              case 'contact':
                context.go('/guest/contact');
                break;
              case 'help':
                context.go('/guest/help');
                break;
              case 'login':
                context.go('/login');
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'about',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 12),
                  Text('À propos'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'contact',
              child: Row(
                children: [
                  Icon(Icons.contact_support_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Contact'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help_outline, size: 20),
                  SizedBox(width: 12),
                  Text('Aide'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'login',
              child: Row(
                children: [
                  Icon(Icons.login, size: 20),
                  SizedBox(width: 12),
                  Text('Connexion'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            'Gagnez des articles incroyables !',
            style: AppTextStyles.h2.copyWith(
              color: Colors.white,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Participez aux tirages spéciaux et tentez votre chance de remporter des smartphones, ordinateurs et bien plus encore.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/register'),
                  icon: const Icon(Icons.person_add),
                  label: const Text('S\'inscrire'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _scrollToProducts(),
                  icon: const Icon(Icons.explore, color: Colors.white),
                  label: Text(
                    'Explorer',
                    style: AppTextStyles.button.copyWith(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'Koumbaya MarketPlace en chiffres',
            style: AppTextStyles.h4,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '1000+',
                  'Participants',
                  Icons.people,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  '50+',
                  'Articles gagnés',
                  Icons.card_giftcard,
                  AppConstants.primaryColor,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  '95%',
                  'Koumbuyers satisfaits',
                  Icons.sentiment_very_satisfied,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 12),
        Text(
          number,
          style: AppTextStyles.h3.copyWith(
            color: color,
            fontSize: 24,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHowItWorksSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      color: AppColors.background,
      child: Column(
        children: [
          Text(
            'Comment ça marche ?',
            style: AppTextStyles.h4,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildHowItWorksStep(
            1,
            'Explorez les articles',
            'Découvrez notre sélection d\'articles high-tech et bien plus encore.',
            Icons.explore,
          ),
          const SizedBox(height: 24),
          _buildHowItWorksStep(
            2,
            'Achetez vos tickets',
            'Participez aux tirages spéciaux en achetant des tickets via Mobile Money.',
            Icons.confirmation_number,
          ),
          const SizedBox(height: 24),
          _buildHowItWorksStep(
            3,
            'Gagnez et recevez',
            'Si vous gagnez, nous vous contactons et livrons votre prix !',
            Icons.emoji_events,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksStep(int step, String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: AppTextStyles.h5.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppTextStyles.h6.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProducts() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Articles en vedette',
                style: AppTextStyles.h4,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/register'),
                child: Text(
                  'Voir tout',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<ProductsProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.featuredProducts.isEmpty) {
                return const LoadingWidget();
              }

              if (provider.featuredProducts.isEmpty) {
                return Center(
                  child: Text(
                    'Aucun article vedette disponible',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.featuredProducts.take(5).length,
                  itemBuilder: (context, index) {
                    final product = provider.featuredProducts[index];
                    return Container(
                      width: 200,
                      margin: EdgeInsets.only(
                        right: index < provider.featuredProducts.length - 1 ? 16 : 0,
                      ),
                      child: _buildGuestProductCard(product),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuestProductCard(Product product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showLoginPrompt(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de l'article
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: Colors.grey[200],
              ),
              child: product.displayImage.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        product.displayImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 50),
                      ),
                    )
                  : const Icon(Icons.card_giftcard, size: 50),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.displayName,
                      style: AppTextStyles.h6.copyWith(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${product.price?.toInt() ?? 0} FCFA',
                      style: AppTextStyles.priceMain.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ticket: ${product.ticketPrice?.toInt() ?? 0} FCFA',
                      style: AppTextStyles.priceSecondary.copyWith(fontSize: 12),
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Connexion requise',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
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

  Widget _buildActiveLotteries() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tirages spéciaux actifs',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 16),
          Consumer<LotteryProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.activeLotteries.isEmpty) {
                return const LoadingWidget();
              }

              if (provider.activeLotteries.isEmpty) {
                return Center(
                  child: Text(
                    'Aucun tirage spécial actif en ce moment',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return Column(
                children: provider.activeLotteries.take(3).map((lottery) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: _buildLotteryPreview(lottery),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLotteryPreview(Lottery lottery) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showLoginPrompt(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tirage spécial ${lottery.id}',
                      style: AppTextStyles.h6,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Prix: ${lottery.product?.price.toInt() ?? 0} FCFA',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(lottery.completionPercentage).toStringAsFixed(0)}%',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: lottery.completionPercentage / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
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

  Widget _buildCallToActionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        children: [
          Text(
            'Prêt à tenter votre chance ?',
            style: AppTextStyles.h3.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Rejoignez des milliers de participants et gagnez des articles incroyables !',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/register'),
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Commencer maintenant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.textPrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
            child: Image.asset(
              'assets/images/logo_white.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Koumbaya MarketPlace',
                    style: AppTextStyles.h5.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => context.go('/guest/about'),
                child: Text(
                  'À propos',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/guest/contact'),
                child: Text(
                  'Contact',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/guest/help'),
                child: Text(
                  'Aide',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© ${DateTime.now().year} Koumbaya MarketPlace. Tous droits réservés.',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white60,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _scrollToProducts() {
    // Scroll to products section - implementation would depend on scroll controller
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Inscrivez-vous pour voir tous nos articles !',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        action: SnackBarAction(
          label: 'S\'inscrire',
          textColor: Colors.white,
          onPressed: () => context.go('/register'),
        ),
      ),
    );
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Connexion requise',
          style: AppTextStyles.h5,
        ),
        content: Text(
          'Vous devez vous connecter pour participer aux tirages spéciaux et acheter des tickets.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }
}