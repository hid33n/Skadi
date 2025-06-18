import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/error_handler.dart';
import '../services/firestore_service.dart';
import '../utils/error_handler.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();
  
  List<Product> _products = [];
  Product? _selectedProduct;
  Map<String, dynamic> _productStats = {};
  bool _isLoading = false;
  AppError? _error;

  ProductViewModel(this._firestoreService) {
    loadProducts();
  }

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  AppError? get error => _error;

  /// Cargar productos de una organización
  Future<void> loadProducts(String organizationId) async {
    _setLoading(true);
    _clearError();

    try {
      _products = await _productService.getProducts(organizationId);
      await _loadProductStats(organizationId);
    } catch (e) {
      _setError(AppError.fromException(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar producto específico
  Future<void> loadProduct(String productId, String organizationId) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedProduct = await _productService.getProduct(productId, organizationId);
    } catch (e) {
      _setError(AppError.fromException(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Agregar producto
  Future<bool> addProduct(Product product) async {
    _setLoading(true);
    _clearError();

    try {
      final productId = await _productService.addProduct(product);
      if (productId.isNotEmpty) {
        // Recargar productos
        await loadProducts(product.organizationId);
        return true;
      }
      return false;
    } catch (e) {
      _setError(AppError.fromException(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar producto
  Future<bool> updateProduct(Product product) async {
    _setLoading(true);
    _clearError();

    try {
      await _productService.updateProduct(product);
      // Recargar productos
      await loadProducts(product.organizationId);
      return true;
    } catch (e) {
      _setError(AppError.fromException(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Eliminar producto
  Future<bool> deleteProduct(String id, String organizationId) async {
    _setLoading(true);
    _clearError();

    try {
      await _productService.deleteProduct(id, organizationId);
      // Recargar productos
      await loadProducts(organizationId);
      return true;
    } catch (e) {
      _setError(AppError.fromException(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar stock
  Future<bool> updateStock(String id, int newStock, String organizationId) async {
    _setLoading(true);
    _clearError();

    try {
      await _productService.updateStock(id, newStock, organizationId);
      // Recargar productos
      await loadProducts(organizationId);
      return true;
    } catch (e) {
      _setError(AppError.fromException(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Buscar productos
  Future<List<Product>> searchProducts(String query, String organizationId) async {
    try {
      return await _productService.searchProducts(query, organizationId);
    } catch (e) {
      _setError(AppError.fromException(e));
      return [];
    }
  }

  /// Obtener productos por categoría
  Future<List<Product>> getProductsByCategory(String categoryId, String organizationId) async {
    try {
      return await _productService.getProductsByCategory(categoryId, organizationId);
    } catch (e) {
      _setError(AppError.fromException(e));
      return [];
    }
  }

  /// Obtener productos con stock bajo
  Future<List<Product>> getLowStockProducts(String organizationId) async {
    try {
      return await _productService.getLowStockProducts(organizationId);
    } catch (e) {
      _setError(AppError.fromException(e));
      return [];
    }
  }

  /// Cargar estadísticas de productos
  Future<void> _loadProductStats(String organizationId) async {
    try {
      _productStats = await _productService.getProductStats(organizationId);
    } catch (e) {
      _setError(AppError.fromException(e));
    }
  }

  /// Obtener productos con stock bajo (local)
  List<Product> getLowStockProductsLocal() {
    return _products.where((product) => product.stock <= product.minStock).toList();
  }

  /// Obtener distribución por categoría (local)
  Map<String, int> getProductsByCategoryLocal() {
    final Map<String, int> categoryCount = {};
    for (var product in _products) {
      categoryCount[product.categoryId] = (categoryCount[product.categoryId] ?? 0) + 1;
    }
    return categoryCount;
  }

  /// Obtener valor total del stock (local)
  double getTotalStockValue() {
    return _products.fold(0, (sum, product) => sum + (product.price * product.stock));
  }

  /// Buscar productos (local)
  List<Product> searchProductsLocal(String query) {
    if (query.isEmpty) return _products;
    return _products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Filtrar por categoría (local)
  List<Product> filterByCategoryLocal(String categoryId) {
    if (categoryId.isEmpty) return _products;
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  /// Limpiar datos
  void clear() {
    _products.clear();
    _selectedProduct = null;
    _productStats.clear();
    _clearError();
    notifyListeners();
  }

  // Métodos privados para manejo de estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(AppError error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
} 