import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/category_card.dart';
import '../../widgets/loading_widget.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    await productsProvider.loadCategories(parentOnly: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: AppConstants.primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _loadCategories,
        child: Consumer<ProductsProvider>(
          builder: (context, productsProvider, child) {
            if (productsProvider.isCategoriesLoading && productsProvider.categories.isEmpty) {
              return const LoadingWidget(message: 'Chargement des catégories...');
            }

            if (productsProvider.errorMessage != null) {
              return ErrorMessageWidget(
                message: productsProvider.errorMessage!,
                onRetry: _loadCategories,
              );
            }

            if (productsProvider.categories.isEmpty) {
              return const EmptyStateWidget(
                title: 'Aucune catégorie',
                subtitle: 'Les catégories de produits apparaîtront ici',
                icon: Icons.category_outlined,
                buttonText: 'Actualiser',
              );
            }

            return Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Toutes les catégories',
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
                        childAspectRatio: 1.0,
                      ),
                      itemCount: productsProvider.categories.length,
                      itemBuilder: (context, index) {
                        final category = productsProvider.categories[index];
                        return CategoryCard(
                          category: category,
                          onTap: () {
                            productsProvider.selectCategory(category);
                            Navigator.of(context).pushNamed(
                              '/category-products',
                              arguments: category.id,
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
      ),
    );
  }
}