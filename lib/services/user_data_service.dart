import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/category.dart' as app_category;
import '../models/sale.dart';
import '../models/movement.dart';
import '../models/user_profile.dart';
import '../utils/error_handler.dart';

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Referencias a las subcolecciones del usuario - Cambiado de 'users' a 'pm'
  CollectionReference _getUserProductsRef(String userId) => 
      _firestore.collection('pm').doc(userId).collection('products');
  
  CollectionReference _getUserCategoriesRef(String userId) => 
      _firestore.collection('pm').doc(userId).collection('categories');
  
  CollectionReference _getUserSalesRef(String userId) => 
      _firestore.collection('pm').doc(userId).collection('sales');
  
  CollectionReference _getUserMovementsRef(String userId) => 
      _firestore.collection('pm').doc(userId).collection('movements');

  // Métodos para Productos
  Future<List<Product>> getProducts(String userId) async {
    try {
      final snapshot = await _getUserProductsRef(userId).get();
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<String> addProduct(String userId, Product product) async {
    try {
      final docRef = await _getUserProductsRef(userId).add(product.toMap());
      return docRef.id;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> updateProduct(String userId, String productId, Product product) async {
    try {
      await _getUserProductsRef(userId).doc(productId).update(product.toMap());
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> deleteProduct(String userId, String productId) async {
    try {
      await _getUserProductsRef(userId).doc(productId).delete();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  // Métodos para Categorías
  Future<List<app_category.Category>> getCategories(String userId) async {
    try {
      print('🔄 UserDataService: Cargando categorías desde Firebase');
      print('  - User ID: $userId');
      
      final snapshot = await _getUserCategoriesRef(userId).get();
      print('📊 UserDataService: Documentos encontrados en Firebase: ${snapshot.docs.length}');
      
      final allCategories = snapshot.docs
          .map((doc) => app_category.Category.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      print('📊 UserDataService: Todas las categorías: ${allCategories.length}');
      for (var category in allCategories) {
        print('  - ${category.name} (ID: ${category.id})');
      }
      
      return allCategories;
    } catch (e, stackTrace) {
      print('❌ UserDataService: Error cargando categorías: $e');
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<String> addCategory(String userId, app_category.Category category) async {
    try {
      final docRef = await _getUserCategoriesRef(userId).add(category.toMap());
      return docRef.id;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> updateCategory(String userId, String categoryId, app_category.Category category) async {
    try {
      await _getUserCategoriesRef(userId).doc(categoryId).update(category.toMap());
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> deleteCategory(String userId, String categoryId) async {
    try {
      await _getUserCategoriesRef(userId).doc(categoryId).delete();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  // Métodos para Ventas
  Future<List<Sale>> getSales(String userId) async {
    try {
      final snapshot = await _getUserSalesRef(userId).get();
      return snapshot.docs
          .map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<String> addSale(String userId, Sale sale) async {
    try {
      final docRef = await _getUserSalesRef(userId).add(sale.toMap());
      return docRef.id;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> updateSale(String userId, String saleId, Sale sale) async {
    try {
      await _getUserSalesRef(userId).doc(saleId).update(sale.toMap());
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> deleteSale(String userId, String saleId) async {
    try {
      await _getUserSalesRef(userId).doc(saleId).delete();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  // Métodos para Movimientos
  Future<List<Movement>> getMovements(String userId) async {
    try {
      final snapshot = await _getUserMovementsRef(userId).get();
      return snapshot.docs
          .map((doc) => Movement.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<String> addMovement(String userId, Movement movement) async {
    try {
      final docRef = await _getUserMovementsRef(userId).add(movement.toMap());
      return docRef.id;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> updateMovement(String userId, String movementId, Movement movement) async {
    try {
      await _getUserMovementsRef(userId).doc(movementId).update(movement.toMap());
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> deleteMovement(String userId, String movementId) async {
    try {
      await _getUserMovementsRef(userId).doc(movementId).delete();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  // Métodos para Usuarios
  Future<UserProfile?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('pm').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> updateUser(String userId, UserProfile user) async {
    try {
      await _firestore.collection('pm').doc(userId).update(user.toMap());
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('pm').doc(userId).delete();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  // Métodos para inicialización de datos
  Future<void> initializeUserData(String userId) async {
    try {
      // Crear la estructura inicial de datos para el usuario
      final userDataRef = _firestore.collection('pm').doc(userId).collection('data');
      
      await Future.wait([
        userDataRef.doc('products').set({'createdAt': FieldValue.serverTimestamp()}),
        userDataRef.doc('categories').set({'createdAt': FieldValue.serverTimestamp()}),
        userDataRef.doc('sales').set({'createdAt': FieldValue.serverTimestamp()}),
        userDataRef.doc('movements').set({'createdAt': FieldValue.serverTimestamp()}),
      ]);
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> activateUser(String userId) async {
    try {
      // Placeholder para futura implementación
      await _firestore.collection('pm').doc(userId).update({
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> deactivateUser(String userId) async {
    try {
      // Placeholder para futura implementación
      await _firestore.collection('pm').doc(userId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }
} 