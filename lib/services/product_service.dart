import '../models/product.dart';
import '../utils/error_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtener todos los productos
  Future<List<Product>> getProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .get();
      
      return querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener producto por ID
  Future<Product?> getProduct(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        return Product.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Agregar producto
  Future<String> addProduct(Product product) async {
    try {
      final docRef = await _firestore.collection('products').add(product.toMap());
      return docRef.id;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Actualizar producto
  Future<void> updateProduct(String id, Product product) async {
    try {
      await _firestore.collection('products').doc(id).update(product.toMap());
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Eliminar producto
  Future<void> deleteProduct(String id) async {
    try {
      final product = await getProduct(id);
      if (product != null) {
        await _firestore.collection('products').doc(id).delete();
      }
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Actualizar stock de un producto
  Future<void> updateStock(String id, int newStock) async {
    try {
      final product = await getProduct(id);
      if (product != null) {
        final updatedProduct = product.copyWith(stock: newStock);
        await updateProduct(id, updatedProduct);
      }
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Buscar productos por nombre o descripción
  Future<List<Product>> searchProducts(String query) async {
    try {
      final products = await getProducts();
      return products.where((product) =>
        product.name.toLowerCase().contains(query.toLowerCase()) ||
        (product.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener productos por categoría
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener productos con stock bajo
  Future<List<Product>> getLowStockProducts() async {
    try {
      final products = await getProducts();
      return products.where((product) => product.stock <= product.minStock).toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener estadísticas de productos
  Future<Map<String, dynamic>> getProductStats() async {
    try {
      final products = await getProducts();
      final totalProducts = products.length;
      final totalValue = products.fold<double>(0, (sum, product) => sum + (product.price * product.stock));
      final lowStockProducts = products.where((product) => product.stock <= product.minStock).length;
      final outOfStockProducts = products.where((product) => product.stock == 0).length;
      
      return {
        'totalProducts': totalProducts,
        'totalValue': totalValue,
        'lowStockProducts': lowStockProducts,
        'outOfStockProducts': outOfStockProducts,
        'averagePrice': totalProducts > 0 ? totalValue / totalProducts : 0,
      };
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }
} 