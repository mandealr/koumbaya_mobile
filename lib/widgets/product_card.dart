import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../constants/app_constants.dart';
import '../constants/koumbaya_lexicon.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool showProgress;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.elevationLow,
      shadowColor: AppConstants.primaryColor.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec overlay pour les badges
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppConstants.cardBorderRadius),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: product.displayImage,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppConstants.lightAccentColor,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppConstants.lightAccentColor,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: AppConstants.textSecondaryColor,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    
                    // Badges en overlay
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Row(
                        children: [
                          if (product.isFeatureProduct)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppConstants.warningColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'VEDETTE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Badge tirage spécial actif (violet pour tombola)
                    if (product.hasLottery)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppConstants.lotteryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.lotteryColor.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Content amélioré
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titre avec meilleure typographie
                    Flexible(
                      child: Text(
                        product.displayName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textPrimaryColor,
                          height: 1.1,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Vendeur
                    if (product.merchant != null)
                      Flexible(
                        child: Text(
                          product.merchant!.businessName ?? product.merchant!.fullName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 9,
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 4),

                    // Prix avec style amélioré (violet pour tombola, bleu pour achat direct)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.hasLottery
                          ? AppConstants.lightLotteryColor
                          : AppConstants.lightAccentColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        product.formattedPrice,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: product.hasLottery
                            ? AppConstants.lotteryColor
                            : AppConstants.primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          height: 1.0,
                        ),
                      ),
                    ),

                    // Informations tirage spécial si actif (simplifiées avec couleur violette)
                    if (product.hasLottery) ...[
                      const SizedBox(height: 3),
                      Flexible(
                        child: Text(
                          '${KoumbayaLexicon.ticket}: ${product.formattedTicketPrice}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.lotteryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}