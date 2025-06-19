import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/sync_service.dart';
import '../services/auth_service.dart';
import '../utils/error_handler.dart';

class ProductViewModel extends ChangeNotifier {
  final SyncService _syncService = SyncService();
  final AuthService _authService = AuthService();
  
  List<Product> _products = [];
  Product? _selectedProduct;
  Map<String, dynamic> _productStats = {};
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Cargar productos del usuario actual para una organización específica
  Future<void> loadProducts(String organizationId) async {
    _setLoading(true);
    _clearError();

    try {
      print('🔄 ProductViewModel: Cargando productos para organización: $organizationId');
      
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        print('❌ ProductViewModel: Usuario no autenticado');
        _setError('Usuario no autenticado');
        return;
      }

      print('✅ ProductViewModel: Usuario autenticado - ID: ${currentUser.uid}');

      // Usar SyncService que maneja cache local y sincronización
      _products = await _syncService.getProducts(organizationId);
      
      print('📊 ProductViewModel: Productos cargados: ${_products.length}');
      for (var product in _products) {
        print('  - ${product.name} (ID: ${product.id}, Org: ${product.organizationId})');
      }
      
      await _loadProductStats();
      print('✅ ProductViewModel: Estadísticas cargadas');
    } catch (e) {
      print('❌ ProductViewModel: Error cargando productos: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar producto específico
  Future<void> loadProduct(String productId) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedProduct = _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Agregar producto
  Future<bool> addProduct(Product product) async {
    _setLoading(true);
    _clearError();

    try {
      print('🔄 ProductViewModel: Iniciando creación de producto: ${product.name}');
      
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        print('❌ ProductViewModel: Usuario no autenticado');
        _setError('Usuario no autenticado');
        return false;
      }

      print('✅ ProductViewModel: Usuario autenticado - ID: ${currentUser.uid}');
      print('🔄 ProductViewModel: Organization ID: ${product.organizationId}');

      // Usar SyncService que maneja cache local y sincronización
      final productId = await _syncService.createProduct(product);
      
      print('✅ ProductViewModel: Producto creado con ID: $productId');
      
      if (productId.isNotEmpty) {
        // Recargar productos
        await loadProducts(product.organizationId);
        print('✅ ProductViewModel: Productos recargados exitosamente');
        return true;
      } else {
        print('❌ ProductViewModel: ID de producto vacío retornado');
        return false;
      }
    } catch (e) {
      print('❌ ProductViewModel: Error creando producto: $e');
      _setError(e.toString());
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
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _setError('Usuario no autenticado');
        return false;
      }

      // Usar SyncService que maneja cache local y sincronización
      await _syncService.updateProduct(product);
      // Recargar productos
      await loadProducts(product.organizationId);
      return true;
    } catch (e) {
      _setError(e.toString());
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
      print('🔄 ProductViewModel: Iniciando eliminación de producto: $id');
      
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        print('❌ ProductViewModel: Usuario no autenticado');
        _setError('Usuario no autenticado');
        return false;
      }

      print('✅ ProductViewModel: Usuario autenticado - ID: ${currentUser.uid}');
      print('🔄 ProductViewModel: Organization ID: $organizationId');

      // Usar SyncService que maneja cache local y sincronización
      await _syncService.deleteProduct(id);
      print('✅ ProductViewModel: Producto eliminado exitosamente');
      
      // Recargar productos
      await loadProducts(organizationId);
      print('✅ ProductViewModel: Productos recargados exitosamente');
      return true;
    } catch (e) {
      print('❌ ProductViewModel: Error eliminando producto: $e');
      _setError(e.toString());
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
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _setError('Usuario no autenticado');
        return false;
      }

      final product = _products.firstWhere((p) => p.id == id);
      final updatedProduct = product.copyWith(stock: newStock);
      
      // Usar SyncService que maneja cache local y sincronización
      await _syncService.updateProduct(updatedProduct);
      // Recargar productos
      await loadProducts(organizationId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Buscar productos
  Future<List<Product>> searchProducts(String query) async {
    try {
      return searchProductsLocal(query);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  /// Obtener productos por categoría
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      return filterByCategoryLocal(categoryId);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  /// Obtener productos con stock bajo
  Future<List<Product>> getLowStockProducts() async {
    try {
      return getLowStockProductsLocal();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  /// Cargar estadísticas de productos
  Future<void> _loadProductStats() async {
    try {
      _productStats = {
        'totalProducts': _products.length,
        'lowStockProducts': getLowStockProductsLocal().length,
        'totalValue': getTotalStockValue(),
        'categories': getProductsByCategoryLocal().length,
      };
    } catch (e) {
      _setError(e.toString());
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
    return _products.fold(0.0, (sum, product) => sum + (product.price * product.stock));
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

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
} 