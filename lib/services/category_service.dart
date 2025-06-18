import '../models/category.dart';
import '../utils/error_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtener categorías de una organización específica
  Future<List<Category>> getCategories(String organizationId) async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .where('organizationId', isEqualTo: organizationId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Category.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener categoría por ID (verificando organización)
  Future<Category?> getCategoryById(String id, String organizationId) async {
    try {
      final doc = await _firestore.collection('categories').doc(id).get();
      if (doc.exists) {
        final category = Category.fromMap(doc.data()!, doc.id);
        // Verificar que la categoría pertenece a la organización
        if (category.organizationId == organizationId) {
          return category;
        }
      }
      return null;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Agregar categoría
  Future<String> addCategory(Category category) async {
    try {
      final docRef = await _firestore.collection('categories').add(category.toMap());
      return docRef.id;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Actualizar categoría
  Future<void> updateCategory(String id, Category category) async {
    try {
      await _firestore.collection('categories').doc(id).update(category.toMap());
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Eliminar categoría
  Future<void> deleteCategory(String id, String organizationId) async {
    try {
      // Verificar que la categoría pertenece a la organización antes de eliminar
      final category = await getCategoryById(id, organizationId);
      if (category != null) {
        // Verificar que no hay productos usando esta categoría
        final productsSnapshot = await _firestore
            .collection('products')
            .where('organizationId', isEqualTo: organizationId)
            .where('categoryId', isEqualTo: id)
            .get();
        
        if (productsSnapshot.docs.isNotEmpty) {
          throw AppError.validation('No se puede eliminar la categoría porque tiene productos asociados');
        }
        
        await _firestore.collection('categories').doc(id).delete();
      } else {
        throw AppError.permission('No tienes permisos para eliminar esta categoría');
      }
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Buscar categorías por nombre
  Future<List<Category>> searchCategories(String query, String organizationId) async {
    try {
      final categories = await getCategories(organizationId);
      return categories.where((category) =>
        category.name.toLowerCase().contains(query.toLowerCase()) ||
        category.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener estadísticas de categorías
  Future<Map<String, dynamic>> getCategoryStats(String organizationId) async {
    try {
      final categories = await getCategories(organizationId);
      final productsSnapshot = await _firestore
          .collection('products')
          .where('organizationId', isEqualTo: organizationId)
          .get();
      
      final products = productsSnapshot.docs;
      final stats = <String, int>{};
      
      for (final category in categories) {
        final productCount = products.where((doc) => 
          doc.data()['categoryId'] == category.id
        ).length;
        stats[category.name] = productCount;
      }
      
      return {
        'totalCategories': categories.length,
        'categoryDistribution': stats,
        'categoriesWithProducts': stats.values.where((count) => count > 0).length,
        'emptyCategories': stats.values.where((count) => count == 0).length,
      };
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }
} 