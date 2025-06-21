import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/error_handler.dart';

class MigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Migrar datos existentes a la nueva estructura organizada por usuario
  Future<void> migrateToUserBasedStructure() async {
    try {
      // Migrar productos
      await _migrateProducts();
      
      // Migrar categorías
      await _migrateCategories();
      
      // Migrar ventas
      await _migrateSales();
      
      // Migrar movimientos
      await _migrateMovements();
      
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> _migrateProducts() async {
    try {
      final productsSnapshot = await _firestore.collection('products').get();
      
      for (final doc in productsSnapshot.docs) {
        final productData = doc.data();
        final userId = productData['userId'] as String? ?? 'default';
        
        // Crear la nueva estructura
        await _firestore
            .collection('pm')
            .doc(userId)
            .collection('products')
            .doc(doc.id)
            .set(productData);
            
        // Eliminar el documento original
        await doc.reference.delete();
      }
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> _migrateCategories() async {
    try {
      final categoriesSnapshot = await _firestore.collection('categories').get();
      
      for (final doc in categoriesSnapshot.docs) {
        final categoryData = doc.data();
        final userId = categoryData['userId'] as String? ?? 'default';
        
        // Crear la nueva estructura
        await _firestore
            .collection('pm')
            .doc(userId)
            .collection('categories')
            .doc(doc.id)
            .set(categoryData);
            
        // Eliminar el documento original
        await doc.reference.delete();
      }
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> _migrateSales() async {
    try {
      final salesSnapshot = await _firestore.collection('sales').get();
      
      for (final doc in salesSnapshot.docs) {
        final saleData = doc.data();
        final userId = saleData['userId'] as String? ?? 'default';
        
        // Crear la nueva estructura
        await _firestore
            .collection('pm')
            .doc(userId)
            .collection('sales')
            .doc(doc.id)
            .set(saleData);
            
        // Eliminar el documento original
        await doc.reference.delete();
      }
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> _migrateMovements() async {
    try {
      final movementsSnapshot = await _firestore.collection('movements').get();
      
      for (final doc in movementsSnapshot.docs) {
        final movementData = doc.data();
        final userId = movementData['userId'] as String? ?? 'default';
        
        // Crear la nueva estructura
        await _firestore
            .collection('pm')
            .doc(userId)
            .collection('movements')
            .doc(doc.id)
            .set(movementData);
            
        // Eliminar el documento original
        await doc.reference.delete();
      }
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Verificar si la migración es necesaria
  Future<bool> needsMigration() async {
    try {
      // Verificar si existen colecciones en la estructura antigua
      final oldCollections = ['products', 'categories', 'sales', 'movements'];
      
      for (final collectionName in oldCollections) {
        final snapshot = await _firestore.collection(collectionName).limit(1).get();
        if (snapshot.docs.isNotEmpty) {
          return true; // Hay datos en la estructura antigua
        }
      }
      
      return false; // No hay datos en la estructura antigua
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Crear estructura inicial para un usuario nuevo
  Future<void> initializeUserStructure(String userId) async {
    try {
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
} 