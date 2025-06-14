import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

class ProductViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<Product> _products = [];
  bool _isLoading = false;
  String _error = '';

  ProductViewModel(this._firestoreService);

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = '';
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
    _error = '';
    notifyListeners();

    try {
      await _firestoreService.addProduct(product);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _firestoreService.updateProduct(product.id, product);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _firestoreService.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<Product> getLowStockProducts() {
    return _products.where((p) => p.stock <= p.minStock).toList();
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