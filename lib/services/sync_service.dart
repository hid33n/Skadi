import 'dart:async';
import 'dart:html' as html;
import '../services/user_data_service.dart';
import '../services/local_storage_service.dart';
import '../models/product.dart';
import '../models/category.dart' as app_category;
import '../models/sale.dart';
import '../models/movement.dart';
import '../models/organization.dart';
import '../models/user_profile.dart';
import '../utils/error_handler.dart';

enum SyncStatus {
  idle,
  syncing,
  error,
  completed,
}

class SyncService {
  final UserDataService _userDataService = UserDataService();
  final LocalStorageService _localStorage = LocalStorageService();
  
  Timer? _syncTimer;
  StreamController<SyncStatus>? _statusController;
  StreamController<String>? _progressController;
  
  SyncStatus _currentStatus = SyncStatus.idle;
  bool _isInitialized = false;

  // Getters
  SyncStatus get currentStatus => _currentStatus;
  Stream<SyncStatus> get statusStream => _statusController?.stream ?? Stream.value(_currentStatus);
  Stream<String> get progressStream => _progressController?.stream ?? Stream.empty();

  /// Inicializar el servicio de sincronización
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _localStorage.initialize();
      
      _statusController = StreamController<SyncStatus>.broadcast();
      _progressController = StreamController<String>.broadcast();
      
      // Escuchar cambios en la conectividad
      _localStorage.connectivityStream.listen((isOnline) {
        if (isOnline) {
          _scheduleSync();
        }
      });
      
      _isInitialized = true;
      _updateStatus(SyncStatus.idle);
    } catch (e) {
      _updateStatus(SyncStatus.error);
      throw AppError.fromException(e);
    }
  }

  /// Programar sincronización automática
  void _scheduleSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_localStorage.isOnline) {
        syncData();
      }
    });
  }

  /// Actualizar estado de sincronización
  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController?.add(status);
  }

  /// Actualizar progreso
  void _updateProgress(String message) {
    _progressController?.add(message);
  }

  /// Sincronizar todos los datos
  Future<void> syncData() async {
    if (!_isInitialized) await initialize();
    if (!_localStorage.isOnline) {
      _updateStatus(SyncStatus.error);
      return;
    }

    _updateStatus(SyncStatus.syncing);
    _updateProgress('Iniciando sincronización...');

    try {
      // Obtener perfil de usuario
      final userProfile = await _localStorage.getUserProfile();
      if (userProfile == null) {
        _updateStatus(SyncStatus.error);
        return;
      }

      // Sincronizar datos remotos a locales
      await _syncFromRemote(userProfile);
      
      // Sincronizar cola local a remoto
      await _syncToRemote(userProfile);
      
      _updateProgress('Sincronización completada');
      _updateStatus(SyncStatus.completed);
      
      // Volver a estado idle después de 3 segundos
      Timer(const Duration(seconds: 3), () {
        _updateStatus(SyncStatus.idle);
      });
      
    } catch (e) {
      _updateProgress('Error en sincronización: ${e.toString()}');
      _updateStatus(SyncStatus.error);
    }
  }

  /// Sincronizar datos desde el servidor remoto
  Future<void> _syncFromRemote(UserProfile userProfile) async {
    _updateProgress('Sincronizando datos del servidor...');

    // Sincronizar organización
    final remoteOrg = await _userDataService.getOrganization(userProfile.id);
    if (remoteOrg != null) {
      await _localStorage.saveOrganization(remoteOrg);
    }

    // Sincronizar productos
    final remoteProducts = await _userDataService.getProducts(userProfile.id, userProfile.organizationId);
    for (final product in remoteProducts) {
      await _localStorage.saveProduct(product);
    }

    // Sincronizar categorías
    final remoteCategories = await _userDataService.getCategories(userProfile.id, userProfile.organizationId);
    for (final category in remoteCategories) {
      await _localStorage.saveCategory(category);
    }

    // Sincronizar ventas
    final remoteSales = await _userDataService.getSales(userProfile.id, userProfile.organizationId);
    for (final sale in remoteSales) {
      await _localStorage.saveSale(sale);
    }

    // Sincronizar movimientos
    final remoteMovements = await _userDataService.getMovements(userProfile.id, userProfile.organizationId);
    for (final movement in remoteMovements) {
      await _localStorage.saveMovement(movement);
    }

    _updateProgress('Datos del servidor sincronizados');
  }

  /// Sincronizar cola local al servidor remoto
  Future<void> _syncToRemote(UserProfile userProfile) async {
    _updateProgress('Sincronizando cambios locales...');

    final pendingItems = await _localStorage.getPendingSyncItems();
    
    for (final item in pendingItems) {
      try {
        await _processSyncItem(item, userProfile);
        await _localStorage.markSyncItemComplete(item['id']);
        _updateProgress('Elemento sincronizado: ${item['type']}');
      } catch (e) {
        await _localStorage.markSyncItemFailed(item['id'], e.toString());
        _updateProgress('Error sincronizando: ${item['type']}');
      }
    }

    _updateProgress('Cambios locales sincronizados');
  }

  /// Procesar un elemento de la cola de sincronización
  Future<void> _processSyncItem(Map<String, dynamic> item, UserProfile userProfile) async {
    final type = item['type'] as String;
    final action = item['action'] as String;
    final data = item['data'] as Map<String, dynamic>;

    switch (type) {
      case 'product':
        await _processProductSync(action, data, userProfile);
        break;
      case 'category':
        await _processCategorySync(action, data, userProfile);
        break;
      case 'sale':
        await _processSaleSync(action, data, userProfile);
        break;
      case 'movement':
        await _processMovementSync(action, data, userProfile);
        break;
      case 'organization':
        await _processOrganizationSync(action, data, userProfile);
        break;
    }
  }

  /// Procesar sincronización de productos
  Future<void> _processProductSync(String action, Map<String, dynamic> data, UserProfile userProfile) async {
    final product = Product.fromMap(data, data['id']);
    
    switch (action) {
      case 'create':
        await _userDataService.addProduct(userProfile.id, product);
        break;
      case 'update':
        await _userDataService.updateProduct(userProfile.id, product.id, product);
        break;
      case 'delete':
        await _userDataService.deleteProduct(userProfile.id, product.id);
        break;
    }
  }

  /// Procesar sincronización de categorías
  Future<void> _processCategorySync(String action, Map<String, dynamic> data, UserProfile userProfile) async {
    final category = app_category.Category.fromMap(data, data['id']);
    
    switch (action) {
      case 'create':
        await _userDataService.addCategory(userProfile.id, category);
        break;
      case 'update':
        await _userDataService.updateCategory(userProfile.id, category.id, category);
        break;
      case 'delete':
        await _userDataService.deleteCategory(userProfile.id, category.id);
        break;
    }
  }

  /// Procesar sincronización de ventas
  Future<void> _processSaleSync(String action, Map<String, dynamic> data, UserProfile userProfile) async {
    final sale = Sale.fromMap(data, data['id']);
    
    switch (action) {
      case 'create':
        await _userDataService.addSale(userProfile.id, sale);
        break;
      case 'update':
        await _userDataService.updateSale(userProfile.id, sale.id, sale);
        break;
      case 'delete':
        await _userDataService.deleteSale(userProfile.id, sale.id);
        break;
    }
  }

  /// Procesar sincronización de movimientos
  Future<void> _processMovementSync(String action, Map<String, dynamic> data, UserProfile userProfile) async {
    final movement = Movement.fromMap(data, data['id']);
    
    switch (action) {
      case 'create':
        await _userDataService.addMovement(userProfile.id, movement);
        break;
      case 'update':
        await _userDataService.updateMovement(userProfile.id, movement.id, movement);
        break;
      case 'delete':
        await _userDataService.deleteMovement(userProfile.id, movement.id);
        break;
    }
  }

  /// Procesar sincronización de organización
  Future<void> _processOrganizationSync(String action, Map<String, dynamic> data, UserProfile userProfile) async {
    final organization = Organization.fromMap(data, data['id']);
    
    switch (action) {
      case 'create':
        await _userDataService.createOrganization(userProfile.id, organization);
        break;
      case 'update':
        await _userDataService.updateOrganization(userProfile.id, organization);
        break;
    }
  }

  // ===== MÉTODOS PÚBLICOS PARA OPERACIONES CRUD =====

  /// Crear producto (con sincronización)
  Future<String> createProduct(Product product) async {
    if (!_isInitialized) await initialize();

    // Guardar localmente primero
    await _localStorage.saveProduct(product);
    
    // Agregar a cola de sincronización
    await _localStorage.addToSyncQueue('product', 'create', product.toMap());
    
    // Intentar sincronizar inmediatamente si hay conexión
    if (_localStorage.isOnline) {
      syncData();
    }
    
    return product.id;
  }

  /// Actualizar producto (con sincronización)
  Future<void> updateProduct(Product product) async {
    if (!_isInitialized) await initialize();

    // Actualizar localmente
    await _localStorage.saveProduct(product);
    
    // Agregar a cola de sincronización
    await _localStorage.addToSyncQueue('product', 'update', product.toMap());
    
    // Intentar sincronizar inmediatamente si hay conexión
    if (_localStorage.isOnline) {
      syncData();
    }
  }

  /// Eliminar producto (con sincronización)
  Future<void> deleteProduct(String productId) async {
    if (!_isInitialized) await initialize();

    // Eliminar localmente
    await _localStorage.deleteProduct(productId);
    
    // Agregar a cola de sincronización
    await _localStorage.addToSyncQueue('product', 'delete', {'id': productId});
    
    // Intentar sincronizar inmediatamente si hay conexión
    if (_localStorage.isOnline) {
      syncData();
    }
  }

  /// Obtener productos (desde cache local)
  Future<List<Product>> getProducts(String organizationId) async {
    if (!_isInitialized) await initialize();
    return await _localStorage.getProducts(organizationId);
  }

  /// Crear categoría (con sincronización)
  Future<String> createCategory(app_category.Category category) async {
    if (!_isInitialized) await initialize();

    // Guardar localmente primero
    await _localStorage.saveCategory(category);
    
    // Agregar a cola de sincronización
    await _localStorage.addToSyncQueue('category', 'create', category.toMap());
    
    // Intentar sincronizar inmediatamente si hay conexión
    if (_localStorage.isOnline) {
      syncData();
    }
    
    return category.id;
  }

  /// Actualizar categoría (con sincronización)
  Future<void> updateCategory(app_category.Category category) async {
    if (!_isInitialized) await initialize();

    // Actualizar localmente
    await _localStorage.saveCategory(category);
    
    // Agregar a cola de sincronización
    await _localStorage.addToSyncQueue('category', 'update', category.toMap());
    
    // Intentar sincronizar inmediatamente si hay conexión
    if (_localStorage.isOnline) {
      syncData();
    }
  }

  /// Eliminar categoría (con sincronización)
  Future<void> deleteCategory(String categoryId) async {
    if (!_isInitialized) await initialize();

    // Eliminar localmente
    await _localStorage.deleteCategory(categoryId);
    
    // Agregar a cola de sincronización
    await _localStorage.addToSyncQueue('category', 'delete', {'id': categoryId});
    
    // Intentar sincronizar inmediatamente si hay conexión
    if (_localStorage.isOnline) {
      syncData();
    }
  }

  /// Obtener categorías (desde cache local)
  Future<List<app_category.Category>> getCategories(String organizationId) async {
    if (!_isInitialized) await initialize();
    return await _localStorage.getCategories(organizationId);
  }

  /// Crear venta (con sincronización)
  Future<String> createSale(Sale sale) async {
    if (!_isInitialized) await initialize();

    // Guardar localmente primero
    await _localStorage.saveSale(sale);
    
    // Agregar a cola de sincronización
    await _localStorage.addToSyncQueue('sale', 'create', sale.toMap());
    
    // Intentar sincronizar inmediatamente si hay conexión
    if (_localStorage.isOnline) {
      syncData();
    }
    
    return sale.id;
  }

  /// Actualizar venta (con sincronización)
  Future<void> updateSale(Sale sale) async {
    if (!_isInitialized) await initialize();

    // Actualizar localmente
    await _localStorage.saveSale(sale);
    
    // Agregar a cola de sincronización
    await _localStorage.addToSyncQueue('sale', 'update', sale.toMap());
    
    // Intentar sincronizar inmediatamente si hay conexión
    if (_localStorage.isOnline) {
      syncData();
    }
  }

  /// Eliminar venta (con sincronización)
  Future<void> deleteSale(String saleId) async {
    if (!_isInitialized) await initialize();

    // Eliminar localmente
    await _localStorage.deleteSale(saleId);
    
    // Agregar a cola de sincronización
    await _localStorage.addToSyncQueue('sale', 'delete', {'id': saleId});
    
    // Intentar sincronizar inmediatamente si hay conexión
    if (_localStorage.isOnline) {
      syncData();
    }
  }

  /// Obtener ventas (desde cache local)
  Future<List<Sale>> getSales(String organizationId) async {
    if (!_isInitialized) await initialize();
    return await _localStorage.getSales(organizationId);
  }

  /// Crear movimiento (con sincronización)
  Future<String> createMovement(Movement movement) async {
    if (!_isInitialized) await initialize();

    // Guardar localmente primero
    await _localStorage.saveMovement(movement);
    
    // Agregar a cola de sincronización
    await _localStorage.addToSyncQueue('movement', 'create', movement.toMap());
    
    // Intentar sincronizar inmediatamente si hay conexión
    if (_localStorage.isOnline) {
      syncData();
    }
    
    return movement.id;
  }

  /// Actualizar movimiento (con sincronización)
  Future<void> updateMovement(Movement movement) async {
    if (!_isInitialized) await initialize();

    // Actualizar localmente
    await _localStorage.saveMovement(movement);
    
    // Agregar a cola de sincronización
    await _localStorage.addToSyncQueue('movement', 'update', movement.toMap());
    
    // Intentar sincronizar inmediatamente si hay conexión
    if (_localStorage.isOnline) {
      syncData();
    }
  }

  /// Eliminar movimiento (con sincronización)
  Future<void> deleteMovement(String movementId) async {
    if (!_isInitialized) await initialize();

    // Eliminar localmente
    await _localStorage.deleteMovement(movementId);
    
    // Agregar a cola de sincronización
    await _localStorage.addToSyncQueue('movement', 'delete', {'id': movementId});
    
    // Intentar sincronizar inmediatamente si hay conexión
    if (_localStorage.isOnline) {
      syncData();
    }
  }

  /// Obtener movimientos (desde cache local)
  Future<List<Movement>> getMovements(String organizationId) async {
    if (!_isInitialized) await initialize();
    return await _localStorage.getMovements(organizationId);
  }

  /// Obtener organización (desde cache local)
  Future<Organization?> getOrganization() async {
    if (!_isInitialized) await initialize();
    return await _localStorage.getOrganization();
  }

  /// Obtener perfil de usuario (desde cache local)
  Future<UserProfile?> getUserProfile() async {
    if (!_isInitialized) await initialize();
    return await _localStorage.getUserProfile();
  }

  /// Guardar perfil de usuario
  Future<void> saveUserProfile(UserProfile profile) async {
    if (!_isInitialized) await initialize();
    await _localStorage.saveUserProfile(profile);
  }

  /// Guardar organización
  Future<void> saveOrganization(Organization organization) async {
    if (!_isInitialized) await initialize();
    await _localStorage.saveOrganization(organization);
    
    // Agregar a cola de sincronización
    await _localStorage.addToSyncQueue('organization', 'update', organization.toMap());
    
    // Intentar sincronizar inmediatamente si hay conexión
    if (_localStorage.isOnline) {
      syncData();
    }
  }

  /// Obtener estadísticas de almacenamiento
  Future<Map<String, int>> getStorageStats() async {
    if (!_isInitialized) await initialize();
    return await _localStorage.getStorageStats();
  }

  /// Limpiar todos los datos locales
  Future<void> clearAllData() async {
    if (!_isInitialized) await initialize();
    await _localStorage.clearAllData();
  }

  /// Verificar si hay conexión a internet
  bool get isOnline => _localStorage.isOnline;

  /// Obtener stream de conectividad
  Stream<bool> get connectivityStream => _localStorage.connectivityStream;

  /// Disposal
  void dispose() {
    _syncTimer?.cancel();
    _statusController?.close();
    _progressController?.close();
  }
} 