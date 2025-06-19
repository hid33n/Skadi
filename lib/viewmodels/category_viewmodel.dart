import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/sync_service.dart';
import '../utils/error_handler.dart';

class CategoryViewModel extends ChangeNotifier {
  final SyncService _syncService = SyncService();
  
  List<Category> _categories = [];
  Category? _selectedCategory;
  Map<String, dynamic> _categoryStats = {};
  bool _isLoading = false;
  AppError? _error;

  // Getters
  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;
  Map<String, dynamic> get categoryStats => _categoryStats;
  bool get isLoading => _isLoading;
  AppError? get error => _error;

  /// Cargar categorías de una organización
  Future<void> loadCategories(String organizationId) async {
    _setLoading(true);
    _clearError();

    try {
      print('🔄 Cargando categorías para organización: $organizationId');
      
      // Usar SyncService que maneja cache local y sincronización
      _categories = await _syncService.getCategories(organizationId);
      
      print('📊 Categorías cargadas: ${_categories.length}');
      for (var category in _categories) {
        print('  - ${category.name} (ID: ${category.id})');
      }
      
      await _loadCategoryStats(organizationId);
    } catch (e) {
      print('❌ Error cargando categorías: $e');
      _setError(AppError.fromException(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar categoría específica
  Future<void> loadCategory(String categoryId, String organizationId) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedCategory = _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      _setError(AppError.fromException(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Agregar categoría
  Future<bool> addCategory(Category category) async {
    _setLoading(true);
    _clearError();

    // Mecanismo de reintento
    int retryCount = 0;
    const maxRetries = 3;
    
    try {
      while (retryCount < maxRetries) {
        try {
          print('🔄 CategoryViewModel: Intento ${retryCount + 1} de crear categoría: ${category.name}');
          print('🔄 CategoryViewModel: Organization ID: ${category.organizationId}');
          
          // Verificar que la organización ID no esté vacía
          if (category.organizationId.isEmpty || category.organizationId == 'organization') {
            throw AppError.validation('ID de organización inválido: ${category.organizationId}');
          }
          
          // Generar ID único para la categoría
          final categoryWithId = category.copyWith(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
          );
          
          print('🔄 CategoryViewModel: Categoría con ID generado: ${categoryWithId.id}');
          
          // Usar SyncService que maneja cache local y sincronización
          final categoryId = await _syncService.createCategory(categoryWithId);
          
          print('✅ CategoryViewModel: Categoría creada con ID: $categoryId');
          
          if (categoryId.isNotEmpty) {
            // Recargar categorías
            await loadCategories(category.organizationId);
            return true;
          } else {
            throw AppError.validation('No se pudo crear la categoría: ID vacío retornado');
          }
        } catch (e) {
          retryCount++;
          print('❌ CategoryViewModel: Error en intento $retryCount: $e');
          
          if (retryCount >= maxRetries) {
            print('❌ CategoryViewModel: Máximo de reintentos alcanzado');
            _setError(AppError.fromException(e));
            return false;
          }
          
          // Esperar antes del siguiente intento (backoff exponencial)
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
          print('🔄 CategoryViewModel: Reintentando en ${500 * retryCount}ms...');
        }
      }
      
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar categoría
  Future<bool> updateCategory(Category category) async {
    _setLoading(true);
    _clearError();

    try {
      // Usar SyncService que maneja cache local y sincronización
      await _syncService.updateCategory(category);
      // Recargar categorías
      await loadCategories(category.organizationId);
      return true;
    } catch (e) {
      _setError(AppError.fromException(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Eliminar categoría
  Future<bool> deleteCategory(String id, String organizationId) async {
    _setLoading(true);
    _clearError();

    try {
      // Usar SyncService que maneja cache local y sincronización
      await _syncService.deleteCategory(id);
      // Recargar categorías
      await loadCategories(organizationId);
      return true;
    } catch (e) {
      _setError(AppError.fromException(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Buscar categorías
  Future<List<Category>> searchCategories(String query, String organizationId) async {
    try {
      return searchCategoriesLocal(query);
    } catch (e) {
      _setError(AppError.fromException(e));
      return [];
    }
  }

  /// Cargar estadísticas de categorías
  Future<void> _loadCategoryStats(String organizationId) async {
    try {
      // Calcular estadísticas locales
      _categoryStats = {
        'totalCategories': _categories.length,
        'categoryDistribution': getProductCountByCategory(),
        'emptyCategories': getEmptyCategories().length,
        'categoriesWithProducts': getCategoriesWithProducts().length,
      };
    } catch (e) {
      _setError(AppError.fromException(e));
    }
  }

  /// Obtener categoría por ID (local)
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener categoría por nombre (local)
  Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere((category) => 
        category.name.toLowerCase() == name.toLowerCase()
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtener distribución de productos por categoría (local)
  Map<String, int> getProductCountByCategory() {
    final Map<String, int> categoryCount = {};
    for (var category in _categories) {
      categoryCount[category.id] = 0; // Inicializar contador
    }
    return categoryCount;
  }

  /// Buscar categorías (local)
  List<Category> searchCategoriesLocal(String query) {
    if (query.isEmpty) return _categories;
    return _categories.where((category) {
      return category.name.toLowerCase().contains(query.toLowerCase()) ||
          category.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Obtener categorías vacías (sin productos)
  List<Category> getEmptyCategories() {
    final stats = _categoryStats['categoryDistribution'] as Map<String, dynamic>?;
    if (stats == null) return [];
    
    return _categories.where((category) {
      final count = stats[category.name] as int? ?? 0;
      return count == 0;
    }).toList();
  }

  /// Obtener categorías con productos
  List<Category> getCategoriesWithProducts() {
    final stats = _categoryStats['categoryDistribution'] as Map<String, dynamic>?;
    if (stats == null) return [];
    
    return _categories.where((category) {
      final count = stats[category.name] as int? ?? 0;
      return count > 0;
    }).toList();
  }

  /// Limpiar datos
  void clear() {
    _categories.clear();
    _selectedCategory = null;
    _categoryStats.clear();
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