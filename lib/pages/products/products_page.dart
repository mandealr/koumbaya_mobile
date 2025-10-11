import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/products_provider.dart';
import '../../constants/app_constants.dart';
import '../../constants/koumbaya_lexicon.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';

class ProductsPage extends StatefulWidget {
  final int? categoryId;

  const ProductsPage({super.key, this.categoryId});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final productsProvider = Provider.of<ProductsProvider>(
      context,
      listen: false,
    );
    await productsProvider.loadProducts(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryId != null
              ? '${KoumbayaLexicon.articles} de la catégorie'
              : KoumbayaLexicon.allArticles,
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 1,
        foregroundColor: AppConstants.primaryColor,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: KoumbayaLexicon.searchArticles,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.buttonBorderRadius,
                  ),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.buttonBorderRadius,
                  ),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.buttonBorderRadius,
                  ),
                  borderSide: const BorderSide(
                    color: AppConstants.primaryColor,
                  ),
                ),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                        : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Categories Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => context.push('/categories'),
                borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppConstants.primaryColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.category,
                        color: AppConstants.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Parcourir par catégories',
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppConstants.primaryColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Products Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadProducts,
              child: Consumer<ProductsProvider>(
                builder: (context, productsProvider, child) {
                  if (productsProvider.isLoading &&
                      productsProvider.products.isEmpty) {
                    return LoadingWidget(
                      message: 'Chargement des ${KoumbayaLexicon.articles.toLowerCase()}...',
                    );
                  }

                  if (productsProvider.errorMessage != null) {
                    return ErrorMessageWidget(
                      message: productsProvider.errorMessage!,
                      onRetry: _loadProducts,
                    );
                  }

                  // Filter products based on search and category
                  List<dynamic> filteredProducts = productsProvider.products;

                  if (widget.categoryId != null) {
                    filteredProducts = productsProvider.getProductsByCategory(
                      widget.categoryId!,
                    );
                  }

                  if (_searchQuery.isNotEmpty) {
                    filteredProducts = productsProvider.searchProducts(
                      _searchQuery,
                    );
                  }

                  if (filteredProducts.isEmpty) {
                    return EmptyStateWidget(
                      title:
                          _searchQuery.isNotEmpty
                              ? 'Aucun résultat trouvé'
                              : KoumbayaLexicon.noArticlesFound,
                      subtitle:
                          _searchQuery.isNotEmpty
                              ? 'Essayez avec d\'autres mots-clés'
                              : 'Les ${KoumbayaLexicon.articles.toLowerCase()} apparaîtront ici',
                      icon:
                          _searchQuery.isNotEmpty
                              ? Icons.search_off
                              : Icons.shopping_bag_outlined,
                      buttonText: 'Actualiser',
                      onButtonPressed: _loadProducts,
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Results count
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            KoumbayaLexicon.articleCount(filteredProducts.length),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ),

                        // Products Grid
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.8,
                                ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return ProductCard(
                                product: product,
                                showProgress: true,
                                onTap: () {
                                  productsProvider.selectProduct(product);
                                  context.pushNamed('product',
                                    pathParameters: {'productId': product.id.toString()});
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
            ),
          ),
        ],
      ),
    );
  }
}
