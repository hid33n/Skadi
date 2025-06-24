import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'hybrid_data_service.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/sale.dart';
import '../models/movement.dart';
import '../utils/error_handler.dart';

class MigrationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final HybridDataService _hybridService;

  MigrationService(this._firestore, this._auth, this._hybridService);

  FirebaseAuth get auth => _auth;

  /// Migrar todos los datos de Firebase a Hive local
  Future<Map<String, int>> migrateAllData() async {
    try {
      final results = <String, int>{};
      
      // Migrar categorías
      results['categories'] = await _migrateCategories();
      
      // Migrar productos
      results['products'] = await _migrateProducts();
      
      // Migrar ventas
      results['sales'] = await _migrateSales();
      
      // Migrar movimientos
      results['movements'] = await _migrateMovements();
      
      return results;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Migrar categorías de Firebase a local
  Future<int> _migrateCategories() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      final snapshot = await _firestore
          .collection('pm')
          .doc(userId)
          .collection('categories')
          .get();

      int migratedCount = 0;
      
      for (final doc in snapshot.docs) {
        try {
          final categoryData = doc.data();
          final category = Category.fromMap(categoryData, doc.id);
          
          await _hybridService.createCategory(category);
          migratedCount++;
        } catch (e) {
          print('Error migrando categoría ${doc.id}: $e');
        }
      }
      
      return migratedCount;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Migrar productos de Firebase a local
  Future<int> _migrateProducts() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      final snapshot = await _firestore
          .collection('pm')
          .doc(userId)
          .collection('products')
          .get();

      int migratedCount = 0;
      
      for (final doc in snapshot.docs) {
        try {
          final productData = doc.data();
          final product = Product.fromMap(productData, doc.id);
          
          await _hybridService.createProduct(product);
          migratedCount++;
        } catch (e) {
          print('Error migrando producto ${doc.id}: $e');
        }
      }
      
      return migratedCount;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Migrar ventas de Firebase a local
  Future<int> _migrateSales() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      final snapshot = await _firestore
          .collection('pm')
          .doc(userId)
          .collection('sales')
          .orderBy('date', descending: true)
          .get();

      int migratedCount = 0;
      
      for (final doc in snapshot.docs) {
        try {
          final saleData = doc.data();
          final sale = Sale.fromMap(saleData, doc.id);
          
          await _hybridService.createSale(sale);
          migratedCount++;
        } catch (e) {
          print('Error migrando venta ${doc.id}: $e');
        }
      }
      
      return migratedCount;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Migrar movimientos de Firebase a local
  Future<int> _migrateMovements() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      final snapshot = await _firestore
          .collection('pm')
          .doc(userId)
          .collection('movements')
          .orderBy('date', descending: true)
          .get();

      int migratedCount = 0;
      
      for (final doc in snapshot.docs) {
        try {
          final movementData = doc.data();
          final movement = Movement.fromMap(movementData, doc.id);
          
          await _hybridService.createMovement(movement);
          migratedCount++;
        } catch (e) {
          print('Error migrando movimiento ${doc.id}: $e');
        }
      }
      
      return migratedCount;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Verificar si hay datos en Firebase
  Future<Map<String, bool>> checkFirebaseData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      final results = <String, bool>{};
      
      // Verificar categorías
      final categoriesSnapshot = await _firestore
          .collection('pm')
          .doc(userId)
          .collection('categories')
          .limit(1)
          .get();
      results['hasCategories'] = categoriesSnapshot.docs.isNotEmpty;
      
      // Verificar productos
      final productsSnapshot = await _firestore
          .collection('pm')
          .doc(userId)
          .collection('products')
          .limit(1)
          .get();
      results['hasProducts'] = productsSnapshot.docs.isNotEmpty;
      
      // Verificar ventas
      final salesSnapshot = await _firestore
          .collection('pm')
          .doc(userId)
          .collection('sales')
          .limit(1)
          .get();
      results['hasSales'] = salesSnapshot.docs.isNotEmpty;
      
      // Verificar movimientos
      final movementsSnapshot = await _firestore
          .collection('pm')
          .doc(userId)
          .collection('movements')
          .limit(1)
          .get();
      results['hasMovements'] = movementsSnapshot.docs.isNotEmpty;
      
      return results;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Obtener estadísticas de datos en Firebase
  Future<Map<String, int>> getFirebaseStats() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      final stats = <String, int>{};
      
      // Contar categorías
      final categoriesSnapshot = await _firestore
          .collection('pm')
          .doc(userId)
          .collection('categories')
          .get();
      stats['categories'] = categoriesSnapshot.docs.length;
      
      // Contar productos
      final productsSnapshot = await _firestore
          .collection('pm')
          .doc(userId)
          .collection('products')
          .get();
      stats['products'] = productsSnapshot.docs.length;
      
      // Contar ventas
      final salesSnapshot = await _firestore
          .collection('pm')
          .doc(userId)
          .collection('sales')
          .get();
      stats['sales'] = salesSnapshot.docs.length;
      
      // Contar movimientos
      final movementsSnapshot = await _firestore
          .collection('pm')
          .doc(userId)
          .collection('movements')
          .get();
      stats['movements'] = movementsSnapshot.docs.length;
      
      return stats;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Migrar datos específicos
  Future<int> migrateSpecificData(String collection, {int? limit}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      Query query = _firestore
          .collection('pm')
          .doc(userId)
          .collection(collection);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      int migratedCount = 0;

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          if (data == null) continue;
          
          final dataMap = data as Map<String, dynamic>;
          
          switch (collection) {
            case 'categories':
              final category = Category.fromMap(dataMap, doc.id);
              await _hybridService.createCategory(category);
              break;
            case 'products':
              final product = Product.fromMap(dataMap, doc.id);
              await _hybridService.createProduct(product);
              break;
            case 'sales':
              final sale = Sale.fromMap(dataMap, doc.id);
              await _hybridService.createSale(sale);
              break;
            case 'movements':
              final movement = Movement.fromMap(dataMap, doc.id);
              await _hybridService.createMovement(movement);
              break;
            default:
              throw Exception('Colección no soportada: $collection');
          }
          
          migratedCount++;
        } catch (e) {
          print('Error migrando documento ${doc.id} de $collection: $e');
        }
      }

      return migratedCount;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Exportar datos locales a formato JSON
  Future<Map<String, dynamic>> exportLocalData() async {
    try {
      // Obtener todos los datos locales
      final categories = await _hybridService.getAllCategories();
      final products = await _hybridService.getAllProducts();
      final sales = await _hybridService.getAllSales();
      final movements = await _hybridService.getAllMovements();
      
      return {
        'categories': categories.map((c) => c.toMap()).toList(),
        'products': products.map((p) => p.toMap()).toList(),
        'sales': sales.map((s) => s.toMap()).toList(),
        'movements': movements.map((m) => m.toMap()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Importar datos desde formato JSON
  Future<void> importData(Map<String, dynamic> data) async {
    try {
      // Importar categorías
      if (data['categories'] != null && data['categories'] is List) {
        final categoriesList = data['categories'] as List;
        for (final categoryData in categoriesList) {
          if (categoryData is Map<String, dynamic>) {
            final category = Category.fromMap(categoryData, categoryData['id'] as String);
            await _hybridService.createCategory(category);
          }
        }
      }
      
      // Importar productos
      if (data['products'] != null && data['products'] is List) {
        final productsList = data['products'] as List;
        for (final productData in productsList) {
          if (productData is Map<String, dynamic>) {
            final product = Product.fromMap(productData, productData['id'] as String);
            await _hybridService.createProduct(product);
          }
        }
      }
      
      // Importar ventas
      if (data['sales'] != null && data['sales'] is List) {
        final salesList = data['sales'] as List;
        for (final saleData in salesList) {
          if (saleData is Map<String, dynamic>) {
            final sale = Sale.fromMap(saleData, saleData['id'] as String);
            await _hybridService.createSale(sale);
          }
        }
      }
      
      // Importar movimientos
      if (data['movements'] != null && data['movements'] is List) {
        final movementsList = data['movements'] as List;
        for (final movementData in movementsList) {
          if (movementData is Map<String, dynamic>) {
            final movement = Movement.fromMap(movementData, movementData['id'] as String);
            await _hybridService.createMovement(movement);
          }
        }
      }
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Limpiar datos locales
  Future<void> clearLocalData() async {
    try {
      // Obtener todos los datos y eliminarlos
      final categories = await _hybridService.getAllCategories();
      final products = await _hybridService.getAllProducts();
      final sales = await _hybridService.getAllSales();
      final movements = await _hybridService.getAllMovements();
      
      // Eliminar categorías
      for (final category in categories) {
        await _hybridService.deleteCategory(category.id);
      }
      
      // Eliminar productos
      for (final product in products) {
        await _hybridService.deleteProduct(product.id);
      }
      
      // Eliminar ventas
      for (final sale in sales) {
        await _hybridService.deleteSale(sale.id);
      }
      
      // Eliminar movimientos
      for (final movement in movements) {
        await _hybridService.deleteMovement(movement.id);
      }
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Verificar integridad de datos migrados
  Future<Map<String, bool>> verifyMigration() async {
    try {
      final results = <String, bool>{};
      
      // Verificar que los datos locales existen
      final localCategories = await _hybridService.getAllCategories();
      final localProducts = await _hybridService.getAllProducts();
      final localSales = await _hybridService.getAllSales();
      final localMovements = await _hybridService.getAllMovements();
      
      results['categoriesMigrated'] = localCategories.isNotEmpty;
      results['productsMigrated'] = localProducts.isNotEmpty;
      results['salesMigrated'] = localSales.isNotEmpty;
      results['movementsMigrated'] = localMovements.isNotEmpty;
      
      return results;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Obtener estadísticas de datos locales
  Future<Map<String, int>> getLocalStats() async {
    try {
      final categories = await _hybridService.getAllCategories();
      final products = await _hybridService.getAllProducts();
      final sales = await _hybridService.getAllSales();
      final movements = await _hybridService.getAllMovements();
      
      return {
        'categories': categories.length,
        'products': products.length,
        'sales': sales.length,
        'movements': movements.length,
      };
    } catch (e) {
      throw AppError.fromException(e);
    }
  }
} 