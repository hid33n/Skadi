import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../utils/error_handler.dart';

class ProductViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthService _authService;
  
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  ProductViewModel(this._firestoreService, this._authService);

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 ProductViewModel: Cargando productos');
      
      _products = await _firestoreService.getProducts();
      
      print('📊 ProductViewModel: Productos cargados: ${_products.length}');
      for (var product in _products) {
        print('  - ${product.name} (ID: ${product.id})');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct(Product product) async {
    try {
      print('🔄 ProductViewModel: Agregando producto: ${product.name}');
      
      await _firestoreService.addProduct(product);
      await loadProducts();
      print('✅ ProductViewModel: Producto agregado exitosamente');
      return true;
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      print('🔄 ProductViewModel: Actualizando producto: ${product.name}');
      
      await _firestoreService.updateProduct(product.id, product);
      await loadProducts();
      print('✅ ProductViewModel: Producto actualizado exitosamente');
      return true;
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      print('🔄 ProductViewModel: Eliminando producto con ID: $id');
      
      await _firestoreService.deleteProduct(id);
      await loadProducts();
      print('✅ ProductViewModel: Producto eliminado exitosamente');
      return true;
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStock(String id, int newStock) async {
    try {
      print('🔄 ProductViewModel: Actualizando stock del producto $id a $newStock');
      
      final product = _products.firstWhere((p) => p.id == id);
      final updatedProduct = product.copyWith(
        stock: newStock,
        updatedAt: DateTime.now(),
      );
      
      final success = await updateProduct(updatedProduct);
      
      if (success) {
        print('✅ ProductViewModel: Stock actualizado exitosamente');
        return true;
      } else {
        print('❌ ProductViewModel: Error al actualizar stock');
        return false;
      }
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      notifyListeners();
      return false;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    return _products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
             product.description.toLowerCase().contains(query.toLowerCase()) ||
             (product.sku?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
             (product.barcode?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  List<Product> getLowStockProducts() {
    return _products.where((product) => product.stock <= product.minStock).toList();
  }

  List<Product> getProductsByCategory(String categoryId) {
    return _products.where((product) => product.categoryId == categoryId).toList();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 