import '../models/product.dart';
import '../utils/error_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtener productos de una organización específica
  Future<List<Product>> getProducts(String organizationId) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('organizationId', isEqualTo: organizationId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener producto por ID (verificando organización)
  Future<Product?> getProduct(String id, String organizationId) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        final product = Product.fromMap(doc.data()!, doc.id);
        // Verificar que el producto pertenece a la organización
        if (product.organizationId == organizationId) {
          return product;
        }
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
  Future<void> updateProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).update(product.toMap());
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Eliminar producto
  Future<void> deleteProduct(String id, String organizationId) async {
    try {
      // Verificar que el producto pertenece a la organización antes de eliminar
      final product = await getProduct(id, organizationId);
      if (product != null) {
        await _firestore.collection('products').doc(id).delete();
      } else {
        throw AppError.permission('No tienes permisos para eliminar este producto');
      }
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Actualizar stock
  Future<void> updateStock(String id, int newStock, String organizationId) async {
    try {
      final product = await getProduct(id, organizationId);
      if (product != null) {
        final updated = product.copyWith(
          stock: newStock,
          updatedAt: DateTime.now(),
        );
        await updateProduct(updated);
      } else {
        throw AppError.permission('No tienes permisos para actualizar este producto');
      }
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Buscar productos por nombre
  Future<List<Product>> searchProducts(String query, String organizationId) async {
    try {
      final products = await getProducts(organizationId);
      return products.where((product) =>
        product.name.toLowerCase().contains(query.toLowerCase()) ||
        product.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener productos por categoría
  Future<List<Product>> getProductsByCategory(String categoryId, String organizationId) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('organizationId', isEqualTo: organizationId)
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
  Future<List<Product>> getLowStockProducts(String organizationId) async {
    try {
      final products = await getProducts(organizationId);
      return products.where((product) => product.stock <= product.minStock).toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener estadísticas de productos
  Future<Map<String, dynamic>> getProductStats(String organizationId) async {
    try {
      final products = await getProducts(organizationId);
      
      double totalValue = 0;
      int totalItems = 0;
      int lowStockCount = 0;
      int outOfStockCount = 0;

      for (final product in products) {
        totalValue += product.price * product.stock;
        totalItems += product.stock;
        
        if (product.stock <= product.minStock) {
          lowStockCount++;
        }
        
        if (product.stock == 0) {
          outOfStockCount++;
        }
      }

      return {
        'totalProducts': products.length,
        'totalValue': totalValue,
        'totalItems': totalItems,
        'lowStockCount': lowStockCount,
        'outOfStockCount': outOfStockCount,
        'averagePrice': products.isNotEmpty ? totalValue / products.length : 0,
      };
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }
} 