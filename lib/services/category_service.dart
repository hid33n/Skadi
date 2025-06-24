import '../models/category.dart';
import '../utils/error_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final FirebaseFirestore _firestore;

  CategoryService([FirebaseFirestore? firestore]) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Obtener todas las categorías
  Future<List<Category>> getCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .get();
      
      return querySnapshot.docs
          .map((doc) => Category.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener categoría por ID
  Future<Category?> getCategoryById(String id) async {
    try {
      final doc = await _firestore.collection('categories').doc(id).get();
      if (doc.exists) {
        return Category.fromMap(doc.data()!, doc.id);
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
  Future<void> deleteCategory(String id) async {
    try {
      // Verificar que no hay productos usando esta categoría
      final productsSnapshot = await _firestore
          .collection('products')
          .where('categoryId', isEqualTo: id)
          .get();
      
      if (productsSnapshot.docs.isNotEmpty) {
        throw AppError.validation('No se puede eliminar la categoría porque tiene productos asociados');
      }
      
      await _firestore.collection('categories').doc(id).delete();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Buscar categorías por nombre
  Future<List<Category>> searchCategories(String query) async {
    try {
      final categories = await getCategories();
      return categories.where((category) =>
        category.name.toLowerCase().contains(query.toLowerCase()) ||
        (category.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener estadísticas de categorías
  Future<Map<String, dynamic>> getCategoryStats() async {
    try {
      final categories = await getCategories();
      final productsSnapshot = await _firestore
          .collection('products')
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