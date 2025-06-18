import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';
import '../models/product.dart';
import '../models/category.dart' as app_category;
import '../models/sale.dart';
import '../models/movement.dart';
import '../models/organization.dart';
import '../models/user_profile.dart';
import '../utils/error_handler.dart';

class SyncViewModel extends ChangeNotifier {
  final SyncService _syncService = SyncService();
  
  SyncStatus _currentStatus = SyncStatus.idle;
  String _currentProgress = '';
  bool _isOnline = true;
  Map<String, int> _storageStats = {};
  bool _isInitialized = false;

  // Getters
  SyncService get syncService => _syncService;
  SyncStatus get currentStatus => _currentStatus;
  String get currentProgress => _currentProgress;
  bool get isOnline => _isOnline;
  Map<String, int> get storageStats => _storageStats;
  bool get isInitialized => _isInitialized;

  /// Inicializar el ViewModel
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _syncService.initialize();
      
      // Escuchar cambios de estado
      _syncService.statusStream.listen((status) {
        _currentStatus = status;
        notifyListeners();
      });

      // Escuchar progreso
      _syncService.progressStream.listen((progress) {
        _currentProgress = progress;
        notifyListeners();
      });

      // Escuchar conectividad
      _syncService.connectivityStream.listen((isOnline) {
        _isOnline = isOnline;
        notifyListeners();
      });

      // Cargar estadísticas iniciales
      await _loadStorageStats();
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Cargar estadísticas de almacenamiento
  Future<void> _loadStorageStats() async {
    try {
      _storageStats = await _syncService.getStorageStats();
      notifyListeners();
    } catch (e) {
      // Ignorar errores de estadísticas
    }
  }

  /// Sincronizar manualmente
  Future<void> syncData() async {
    if (!_isInitialized) await initialize();
    
    try {
      await _syncService.syncData();
      await _loadStorageStats();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  // ===== MÉTODOS PARA PRODUCTOS =====

  /// Crear producto
  Future<String> createProduct(Product product) async {
    if (!_isInitialized) await initialize();
    
    try {
      final productId = await _syncService.createProduct(product);
      await _loadStorageStats();
      return productId;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Actualizar producto
  Future<void> updateProduct(Product product) async {
    if (!_isInitialized) await initialize();
    
    try {
      await _syncService.updateProduct(product);
      await _loadStorageStats();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Eliminar producto
  Future<void> deleteProduct(String productId) async {
    if (!_isInitialized) await initialize();
    
    try {
      await _syncService.deleteProduct(productId);
      await _loadStorageStats();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Obtener productos
  Future<List<Product>> getProducts(String organizationId) async {
    if (!_isInitialized) await initialize();
    
    try {
      return await _syncService.getProducts(organizationId);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  // ===== MÉTODOS PARA CATEGORÍAS =====

  /// Crear categoría
  Future<String> createCategory(app_category.Category category) async {
    if (!_isInitialized) await initialize();
    
    try {
      final categoryId = await _syncService.createCategory(category);
      await _loadStorageStats();
      return categoryId;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Obtener categorías
  Future<List<app_category.Category>> getCategories(String organizationId) async {
    if (!_isInitialized) await initialize();
    
    try {
      return await _syncService.getCategories(organizationId);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  // ===== MÉTODOS PARA VENTAS =====

  /// Crear venta
  Future<String> createSale(Sale sale) async {
    if (!_isInitialized) await initialize();
    
    try {
      final saleId = await _syncService.createSale(sale);
      await _loadStorageStats();
      return saleId;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Obtener ventas
  Future<List<Sale>> getSales(String organizationId) async {
    if (!_isInitialized) await initialize();
    
    try {
      return await _syncService.getSales(organizationId);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  // ===== MÉTODOS PARA MOVIMIENTOS =====

  /// Crear movimiento
  Future<String> createMovement(Movement movement) async {
    if (!_isInitialized) await initialize();
    
    try {
      final movementId = await _syncService.createMovement(movement);
      await _loadStorageStats();
      return movementId;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Obtener movimientos
  Future<List<Movement>> getMovements(String organizationId) async {
    if (!_isInitialized) await initialize();
    
    try {
      return await _syncService.getMovements(organizationId);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  // ===== MÉTODOS PARA ORGANIZACIÓN =====

  /// Obtener organización
  Future<Organization?> getOrganization() async {
    if (!_isInitialized) await initialize();
    
    try {
      return await _syncService.getOrganization();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Guardar organización
  Future<void> saveOrganization(Organization organization) async {
    if (!_isInitialized) await initialize();
    
    try {
      await _syncService.saveOrganization(organization);
      await _loadStorageStats();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  // ===== MÉTODOS PARA PERFIL DE USUARIO =====

  /// Obtener perfil de usuario
  Future<UserProfile?> getUserProfile() async {
    if (!_isInitialized) await initialize();
    
    try {
      return await _syncService.getUserProfile();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Guardar perfil de usuario
  Future<void> saveUserProfile(UserProfile profile) async {
    if (!_isInitialized) await initialize();
    
    try {
      await _syncService.saveUserProfile(profile);
      await _loadStorageStats();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  // ===== MÉTODOS DE UTILIDAD =====

  /// Actualizar estadísticas de almacenamiento
  Future<void> refreshStorageStats() async {
    await _loadStorageStats();
  }

  /// Limpiar todos los datos locales
  Future<void> clearAllData() async {
    if (!_isInitialized) await initialize();
    
    try {
      await _syncService.clearAllData();
      await _loadStorageStats();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Verificar si hay datos locales
  bool get hasLocalData {
    return _storageStats.values.any((count) => count > 0);
  }

  /// Obtener total de elementos almacenados
  int get totalStoredItems {
    return _storageStats.values.fold(0, (sum, count) => sum + count);
  }

  /// Obtener porcentaje de uso del almacenamiento
  double get storageUsagePercentage {
    final total = totalStoredItems;
    if (total == 0) return 0.0;
    
    // Estimación: cada elemento ocupa aproximadamente 1KB
    final estimatedSizeKB = total * 1;
    const maxSizeKB = 50 * 1024; // 50MB límite estimado
    
    return (estimatedSizeKB / maxSizeKB).clamp(0.0, 1.0);
  }

  /// Obtener texto de estado de almacenamiento
  String get storageStatusText {
    final total = totalStoredItems;
    final percentage = (storageUsagePercentage * 100).toStringAsFixed(1);
    
    if (total == 0) return 'Sin datos locales';
    return '$total elementos ($percentage% usado)';
  }

  /// Disposal
  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }
} 