import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import '../utils/error_handler.dart';

class ProductViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<Product> _products = [];
  bool _isLoading = false;
  AppError? _error;

  ProductViewModel(this._firestoreService);

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  String? get errorMessage => _error?.message;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _firestoreService.getProducts();
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.addProduct(product);
      await loadProducts();
      return true;
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.updateProduct(product.id, product);
      await loadProducts();
      return true;
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.deleteProduct(id);
      await loadProducts();
      return true;
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStock(String productId, int newStock) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final product = _products.firstWhere((p) => p.id == productId);
      final updatedProduct = product.copyWith(stock: newStock);
      await _firestoreService.updateProduct(productId, updatedProduct);
      await loadProducts();
      return true;
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> getLowStockProducts() {
    return _products.where((product) => product.stock <= product.minStock).toList();
  }

  List<Product> getOutOfStockProducts() {
    return _products.where((product) => product.stock == 0).toList();
  }

  Map<String, int> getProductsByCategory() {
    final Map<String, int> categoryCount = {};
    for (var product in _products) {
      categoryCount[product.categoryId] = (categoryCount[product.categoryId] ?? 0) + 1;
    }
    return categoryCount;
  }

  double getTotalStockValue() {
    return _products.fold(0, (sum, product) => sum + (product.price * product.stock));
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    return _products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<Product> filterByCategory(String categoryId) {
    if (categoryId.isEmpty) return _products;
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  List<Product> filterByStockLevel(StockLevel level) {
    switch (level) {
      case StockLevel.all:
        return _products;
      case StockLevel.low:
        return _products.where((p) => p.stock <= p.minStock && p.stock > 0).toList();
      case StockLevel.outOfStock:
        return _products.where((p) => p.stock == 0).toList();
      case StockLevel.inStock:
        return _products.where((p) => p.stock > p.minStock).toList();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool get hasError => _error != null;
  bool get hasProducts => _products.isNotEmpty;
  int get totalProducts => _products.length;
}

enum StockLevel {
  all,
  low,
  outOfStock,
  inStock,
} 