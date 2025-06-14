import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

class ProductViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  ProductViewModel(this._firestoreService) {
    loadProducts();
  }

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _firestoreService.getProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.addProduct(product);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.updateProduct(product.id, product);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> getLowStockProducts() {
    return _products.where((product) => product.stock <= product.minStock).toList();
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
} 