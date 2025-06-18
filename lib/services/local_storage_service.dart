import 'dart:html' as html;
import 'dart:convert';
import 'dart:async';
import '../models/product.dart';
import '../models/category.dart' as app_category;
import '../models/sale.dart';
import '../models/movement.dart';
import '../models/organization.dart';
import '../models/user_profile.dart';

class LocalStorageService {
  // Usar localStorage como fallback simple para evitar problemas de IndexedDB
  static const String _prefix = 'stock_app_';
  
  // Nombres de las tablas
  static const String _productsTable = 'products';
  static const String _categoriesTable = 'categories';
  static const String _salesTable = 'sales';
  static const String _movementsTable = 'movements';
  static const String _organizationTable = 'organization';
  static const String _userProfileTable = 'userProfile';
  static const String _syncQueueTable = 'syncQueue';
  static const String _settingsTable = 'settings';

  final Completer<void> _ready = Completer<void>();

  // Singleton pattern
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal() {
    _ready.complete(); // Inicialización inmediata
  }

  /// Inicializar la base de datos local
  Future<void> initialize() async {
    await _ready.future;
  }

  /// Obtener datos de localStorage
  List<Map<String, dynamic>> _getData(String table) {
    final key = '$_prefix$table';
    final data = html.window.localStorage[key];
    if (data == null || data.isEmpty) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Guardar datos en localStorage
  void _saveData(String table, List<Map<String, dynamic>> data) {
    final key = '$_prefix$table';
    html.window.localStorage[key] = jsonEncode(data);
  }

  /// Filtrar datos por organización
  List<Map<String, dynamic>> _filterByOrganization(List<Map<String, dynamic>> data, String organizationId) {
    return data.where((item) => item['organizationId'] == organizationId).toList();
  }

  // ===== MÉTODOS PARA PRODUCTOS =====

  /// Guardar producto localmente
  Future<void> saveProduct(Product product) async {
    await _ready.future;
    final data = _getData(_productsTable);
    
    // Buscar si ya existe
    final index = data.indexWhere((item) => item['id'] == product.id);
    final productData = {
      ...product.toMap(),
      'id': product.id,
      'lastSync': DateTime.now().toIso8601String(),
    };
    
    if (index >= 0) {
      data[index] = productData;
    } else {
      data.add(productData);
    }
    
    _saveData(_productsTable, data);
  }

  /// Obtener productos localmente
  Future<List<Product>> getProducts(String organizationId) async {
    await _ready.future;
    final data = _getData(_productsTable);
    final filteredData = _filterByOrganization(data, organizationId);
    
    return filteredData.map((item) => Product.fromMap(item, item['id'])).toList();
  }

  /// Eliminar producto localmente
  Future<void> deleteProduct(String productId) async {
    await _ready.future;
    final data = _getData(_productsTable);
    data.removeWhere((item) => item['id'] == productId);
    _saveData(_productsTable, data);
  }

  // ===== MÉTODOS PARA CATEGORÍAS =====

  /// Guardar categoría localmente
  Future<void> saveCategory(app_category.Category category) async {
    await _ready.future;
    final data = _getData(_categoriesTable);
    
    final index = data.indexWhere((item) => item['id'] == category.id);
    final categoryData = {
      ...category.toMap(),
      'id': category.id,
      'lastSync': DateTime.now().toIso8601String(),
    };
    
    if (index >= 0) {
      data[index] = categoryData;
    } else {
      data.add(categoryData);
    }
    
    _saveData(_categoriesTable, data);
  }

  /// Obtener categorías localmente
  Future<List<app_category.Category>> getCategories(String organizationId) async {
    await _ready.future;
    final data = _getData(_categoriesTable);
    final filteredData = _filterByOrganization(data, organizationId);
    
    return filteredData.map((item) => app_category.Category.fromMap(item, item['id'])).toList();
  }

  /// Eliminar categoría localmente
  Future<void> deleteCategory(String categoryId) async {
    await _ready.future;
    final data = _getData(_categoriesTable);
    data.removeWhere((item) => item['id'] == categoryId);
    _saveData(_categoriesTable, data);
  }

  // ===== MÉTODOS PARA VENTAS =====

  /// Guardar venta localmente
  Future<void> saveSale(Sale sale) async {
    await _ready.future;
    final data = _getData(_salesTable);
    
    final index = data.indexWhere((item) => item['id'] == sale.id);
    final saleData = {
      ...sale.toMap(),
      'id': sale.id,
      'lastSync': DateTime.now().toIso8601String(),
    };
    
    if (index >= 0) {
      data[index] = saleData;
    } else {
      data.add(saleData);
    }
    
    _saveData(_salesTable, data);
  }

  /// Obtener ventas localmente
  Future<List<Sale>> getSales(String organizationId) async {
    await _ready.future;
    final data = _getData(_salesTable);
    final filteredData = _filterByOrganization(data, organizationId);
    
    return filteredData.map((item) => Sale.fromMap(item, item['id'])).toList();
  }

  /// Eliminar venta localmente
  Future<void> deleteSale(String saleId) async {
    await _ready.future;
    final data = _getData(_salesTable);
    data.removeWhere((item) => item['id'] == saleId);
    _saveData(_salesTable, data);
  }

  // ===== MÉTODOS PARA MOVIMIENTOS =====

  /// Guardar movimiento localmente
  Future<void> saveMovement(Movement movement) async {
    await _ready.future;
    final data = _getData(_movementsTable);
    
    final index = data.indexWhere((item) => item['id'] == movement.id);
    final movementData = {
      ...movement.toMap(),
      'id': movement.id,
      'lastSync': DateTime.now().toIso8601String(),
    };
    
    if (index >= 0) {
      data[index] = movementData;
    } else {
      data.add(movementData);
    }
    
    _saveData(_movementsTable, data);
  }

  /// Obtener movimientos localmente
  Future<List<Movement>> getMovements(String organizationId) async {
    await _ready.future;
    final data = _getData(_movementsTable);
    final filteredData = _filterByOrganization(data, organizationId);
    
    return filteredData.map((item) => Movement.fromMap(item, item['id'])).toList();
  }

  /// Eliminar movimiento localmente
  Future<void> deleteMovement(String movementId) async {
    await _ready.future;
    final data = _getData(_movementsTable);
    data.removeWhere((item) => item['id'] == movementId);
    _saveData(_movementsTable, data);
  }

  // ===== MÉTODOS PARA ORGANIZACIÓN =====

  /// Guardar organización localmente
  Future<void> saveOrganization(Organization organization) async {
    await _ready.future;
    final data = _getData(_organizationTable);
    
    final index = data.indexWhere((item) => item['id'] == organization.id);
    final orgData = {
      ...organization.toMap(),
      'lastSync': DateTime.now().toIso8601String(),
    };
    
    if (index >= 0) {
      data[index] = orgData;
    } else {
      data.add(orgData);
    }
    
    _saveData(_organizationTable, data);
  }

  /// Obtener organización localmente
  Future<Organization?> getOrganization() async {
    await _ready.future;
    final data = _getData(_organizationTable);
    
    if (data.isEmpty) return null;
    return Organization.fromMap(data.first, data.first['id']);
  }

  // ===== MÉTODOS PARA PERFIL DE USUARIO =====

  /// Guardar perfil de usuario localmente
  Future<void> saveUserProfile(UserProfile profile) async {
    await _ready.future;
    final data = _getData(_userProfileTable);
    
    final index = data.indexWhere((item) => item['id'] == profile.id);
    final profileData = {
      ...profile.toMap(),
      'lastSync': DateTime.now().toIso8601String(),
    };
    
    if (index >= 0) {
      data[index] = profileData;
    } else {
      data.add(profileData);
    }
    
    _saveData(_userProfileTable, data);
  }

  /// Obtener perfil de usuario localmente
  Future<UserProfile?> getUserProfile() async {
    await _ready.future;
    final data = _getData(_userProfileTable);
    
    if (data.isEmpty) return null;
    return UserProfile.fromMap(data.first, data.first['id']);
  }

  // ===== MÉTODOS PARA COLA DE SINCRONIZACIÓN =====

  /// Agregar operación a la cola de sincronización
  Future<void> addToSyncQueue(String type, String action, Map<String, dynamic> data) async {
    await _ready.future;
    final data = _getData(_syncQueueTable);
    
    final syncItem = {
      'id': DateTime.now().millisecondsSinceEpoch, // ID único
      'type': type,
      'action': action,
      'data': data,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
      'retryCount': 0,
    };
    
    data.add(syncItem);
    _saveData(_syncQueueTable, data);
  }

  /// Obtener elementos pendientes de sincronización
  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    await _ready.future;
    final data = _getData(_syncQueueTable);
    return data.where((item) => item['status'] == 'pending').toList();
  }

  /// Marcar elemento como sincronizado
  Future<void> markSyncItemComplete(int id) async {
    await _ready.future;
    final data = _getData(_syncQueueTable);
    data.removeWhere((item) => item['id'] == id);
    _saveData(_syncQueueTable, data);
  }

  /// Marcar elemento como fallido
  Future<void> markSyncItemFailed(int id, String error) async {
    await _ready.future;
    final data = _getData(_syncQueueTable);
    final index = data.indexWhere((item) => item['id'] == id);
    
    if (index >= 0) {
      data[index]['status'] = 'failed';
      data[index]['error'] = error;
      data[index]['retryCount'] = (data[index]['retryCount'] ?? 0) + 1;
      data[index]['lastRetry'] = DateTime.now().toIso8601String();
      
      _saveData(_syncQueueTable, data);
    }
  }

  // ===== MÉTODOS PARA CONFIGURACIÓN =====

  /// Guardar configuración
  Future<void> saveSetting(String key, dynamic value) async {
    await _ready.future;
    final data = _getData(_settingsTable);
    
    final index = data.indexWhere((item) => item['key'] == key);
    final settingData = {
      'key': key,
      'value': value,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    
    if (index >= 0) {
      data[index] = settingData;
    } else {
      data.add(settingData);
    }
    
    _saveData(_settingsTable, data);
  }

  /// Obtener configuración
  Future<dynamic> getSetting(String key) async {
    await _ready.future;
    final data = _getData(_settingsTable);
    final item = data.firstWhere((item) => item['key'] == key, orElse: () => {});
    return item['value'];
  }

  // ===== MÉTODOS DE UTILIDAD =====

  /// Limpiar todos los datos locales
  Future<void> clearAllData() async {
    await _ready.future;
    
    final tables = [_productsTable, _categoriesTable, _salesTable, _movementsTable, 
                   _organizationTable, _userProfileTable, _syncQueueTable, _settingsTable];
    
    for (final table in tables) {
      final key = '$_prefix$table';
      html.window.localStorage.remove(key);
    }
  }

  /// Obtener estadísticas de almacenamiento
  Future<Map<String, int>> getStorageStats() async {
    await _ready.future;
    final stats = <String, int>{};
    
    final tables = [_productsTable, _categoriesTable, _salesTable, _movementsTable, 
                   _organizationTable, _userProfileTable, _syncQueueTable, _settingsTable];
    
    for (final table in tables) {
      final data = _getData(table);
      stats[table] = data.length;
    }
    
    return stats;
  }

  /// Verificar si hay conexión a internet
  bool get isOnline => html.window.navigator.onLine ?? true;

  /// Escuchar cambios en la conectividad
  Stream<bool> get connectivityStream {
    // Crear un StreamController para combinar los eventos
    final controller = StreamController<bool>.broadcast();
    
    // Escuchar eventos online
    html.window.onOnline.listen((_) {
      controller.add(true);
    });
    
    // Escuchar eventos offline
    html.window.onOffline.listen((_) {
      controller.add(false);
    });
    
    return controller.stream;
  }
}
