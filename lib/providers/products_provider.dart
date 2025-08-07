import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/category.dart' as models;
import '../services/api_service.dart';

class ProductsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<models.Category> _categories = [];
  Product? _selectedProduct;
  models.Category? _selectedCategory;
  
  bool _isLoading = false;
  bool _isFeaturedLoading = false;
  bool _isCategoriesLoading = false;
  String? _errorMessage;

  // Getters
  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<models.Category> get categories => _categories;
  Product? get selectedProduct => _selectedProduct;
  models.Category? get selectedCategory => _selectedCategory;
  
  bool get isLoading => _isLoading;
  bool get isFeaturedLoading => _isFeaturedLoading;
  bool get isCategoriesLoading => _isCategoriesLoading;
  String? get errorMessage => _errorMessage;

  // Products Methods
  Future<void> loadProducts({int page = 1, bool refresh = false}) async {
    if (refresh) _products.clear();
    
    try {
      _setLoading(true);
      _clearError();

      final products = await _apiService.getProducts(page: page);
      
      if (refresh) {
        _products = products;
      } else {
        _products.addAll(products);
      }
      
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadFeaturedProducts() async {
    try {
      _setFeaturedLoading(true);
      _clearError();

      _featuredProducts = await _apiService.getFeaturedProducts();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setFeaturedLoading(false);
    }
  }

  Future<void> loadProduct(int id) async {
    try {
      _setLoading(true);
      _clearError();

      _selectedProduct = await _apiService.getProduct(id);
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  // Categories Methods
  Future<void> loadCategories({bool parentOnly = false}) async {
    try {
      _setCategoriesLoading(true);
      _clearError();

      _categories = await _apiService.getCategories(parentOnly: parentOnly);
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setCategoriesLoading(false);
    }
  }

  void selectCategory(models.Category? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void selectProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  // Filter products by category
  List<Product> getProductsByCategory(int categoryId) {
    return _products.where((product) => product.categoryId == categoryId).toList();
  }

  // Search products
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    return _products.where((product) {
      return product.title.toLowerCase().contains(query.toLowerCase()) ||
             product.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setFeaturedLoading(bool loading) {
    _isFeaturedLoading = loading;
    notifyListeners();
  }

  void _setCategoriesLoading(bool loading) {
    _isCategoriesLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Une erreur inattendue s\'est produite';
  }
}