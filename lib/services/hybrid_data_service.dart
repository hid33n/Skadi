import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'firestore_service.dart';
import 'hive_database_service.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/sale.dart';
import '../models/movement.dart';

class HybridDataService {
  final FirestoreService _firestoreService;
  final HiveDatabaseService _localDatabase;
  final FirebaseAuth _auth;
  
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isOnline = true;
  Timer? _syncTimer;
  
  // Cola de operaciones pendientes
  final List<Map<String, dynamic>> _pendingOperations = [];

  HybridDataService({
    required FirestoreService firestoreService,
    required HiveDatabaseService localDatabase,
    required FirebaseAuth auth,
  }) : _firestoreService = firestoreService,
       _localDatabase = localDatabase,
       _auth = auth {
    _initializeConnectivity();
    _startPeriodicSync();
  }

  /// Inicializar el servicio
  Future<void> initialize() async {
    await _localDatabase.initialize();
    await _syncPendingOperations();
  }

  /// Inicializar monitoreo de conectividad
  void _initializeConnectivity() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      
      if (!wasOnline && _isOnline) {
        // Volvimos a estar online, sincronizar
        _syncPendingOperations();
      }
    });
  }

  /// Iniciar sincronización periódica
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_isOnline) {
        _syncPendingOperations();
      }
    });
  }

  /// Detener el servicio
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    _localDatabase.close();
  }

  // ===== PRODUCTOS =====

  /// Obtener todos los productos
  Future<List<Product>> getAllProducts() async {
    try {
      if (_isOnline) {
        // Intentar obtener de Firebase
        final products = await _firestoreService.getProducts();
        // Guardar en local
        for (final product in products) {
          await _localDatabase.insertProduct(product);
        }
        return products;
      } else {
        // Usar datos locales
        return await _localDatabase.getAllProducts();
      }
    } catch (e) {
      // Fallback a datos locales
      return await _localDatabase.getAllProducts();
    }
  }

  /// Obtener producto por ID
  Future<Product?> getProductById(String id) async {
    try {
      if (_isOnline) {
        // Buscar en la lista de productos
        final products = await _firestoreService.getProducts();
        final product = products.where((p) => p.id == id).firstOrNull;
        if (product != null) {
          await _localDatabase.insertProduct(product);
        }
        return product;
      } else {
        return await _localDatabase.getProductById(id);
      }
    } catch (e) {
      return await _localDatabase.getProductById(id);
    }
  }

  /// Obtener producto por código de barras
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      if (_isOnline) {
        // Buscar en la lista de productos
        final products = await _firestoreService.getProducts();
        final product = products.where((p) => p.barcode == barcode).firstOrNull;
        if (product != null) {
          await _localDatabase.insertProduct(product);
        }
        return product;
      } else {
        return await _localDatabase.getProductByBarcode(barcode);
      }
    } catch (e) {
      return await _localDatabase.getProductByBarcode(barcode);
    }
  }

  /// Crear producto
  Future<void> createProduct(Product product) async {
    // Guardar localmente primero
    await _localDatabase.insertProduct(product);
    
    if (_isOnline) {
      try {
        await _firestoreService.addProduct(product);
      } catch (e) {
        // Agregar a cola de operaciones pendientes
        _addPendingOperation('createProduct', product.toMap());
      }
    } else {
      _addPendingOperation('createProduct', product.toMap());
    }
  }

  /// Actualizar producto
  Future<void> updateProduct(Product product) async {
    // Actualizar localmente primero
    await _localDatabase.updateProduct(product);
    
    if (_isOnline) {
      try {
        await _firestoreService.updateProduct(product.id, product);
      } catch (e) {
        _addPendingOperation('updateProduct', product.toMap());
      }
    } else {
      _addPendingOperation('updateProduct', product.toMap());
    }
  }

  /// Eliminar producto
  Future<void> deleteProduct(String id) async {
    // Eliminar localmente primero
    await _localDatabase.deleteProduct(id);
    
    if (_isOnline) {
      try {
        await _firestoreService.deleteProduct(id);
      } catch (e) {
        _addPendingOperation('deleteProduct', {'id': id});
      }
    } else {
      _addPendingOperation('deleteProduct', {'id': id});
    }
  }

  /// Buscar productos
  Future<List<Product>> searchProducts(String query) async {
    try {
      if (_isOnline) {
        final products = await _firestoreService.getProducts();
        final filteredProducts = products.where((product) =>
          product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase()) ||
          (product.barcode?.toLowerCase().contains(query.toLowerCase()) ?? false)
        ).toList();
        
        // Guardar resultados en local
        for (final product in filteredProducts) {
          await _localDatabase.insertProduct(product);
        }
        return filteredProducts;
      } else {
        return await _localDatabase.searchProducts(query);
      }
    } catch (e) {
      return await _localDatabase.searchProducts(query);
    }
  }

  /// Obtener productos con stock bajo
  Future<List<Product>> getLowStockProducts() async {
    try {
      if (_isOnline) {
        final products = await _firestoreService.getLowStockProducts();
        // Actualizar en local
        for (final product in products) {
          await _localDatabase.updateProduct(product);
        }
        return products;
      } else {
        return await _localDatabase.getLowStockProducts();
      }
    } catch (e) {
      return await _localDatabase.getLowStockProducts();
    }
  }

  // ===== CATEGORÍAS =====

  /// Obtener todas las categorías
  Future<List<Category>> getAllCategories() async {
    try {
      if (_isOnline) {
        final categories = await _firestoreService.getCategories();
        // Guardar en local
        for (final category in categories) {
          await _localDatabase.insertCategory(category);
        }
        return categories;
      } else {
        return await _localDatabase.getAllCategories();
      }
    } catch (e) {
      return await _localDatabase.getAllCategories();
    }
  }

  /// Crear categoría
  Future<void> createCategory(Category category) async {
    await _localDatabase.insertCategory(category);
    
    if (_isOnline) {
      try {
        await _firestoreService.addCategory(category);
      } catch (e) {
        _addPendingOperation('createCategory', category.toMap());
      }
    } else {
      _addPendingOperation('createCategory', category.toMap());
    }
  }

  /// Actualizar categoría
  Future<void> updateCategory(Category category) async {
    await _localDatabase.updateCategory(category);
    
    if (_isOnline) {
      try {
        await _firestoreService.updateCategory(category.id, category);
      } catch (e) {
        _addPendingOperation('updateCategory', category.toMap());
      }
    } else {
      _addPendingOperation('updateCategory', category.toMap());
    }
  }

  /// Eliminar categoría
  Future<void> deleteCategory(String id) async {
    await _localDatabase.deleteCategory(id);
    
    if (_isOnline) {
      try {
        await _firestoreService.deleteCategory(id);
      } catch (e) {
        _addPendingOperation('deleteCategory', {'id': id});
      }
    } else {
      _addPendingOperation('deleteCategory', {'id': id});
    }
  }

  // ===== VENTAS =====

  /// Obtener todas las ventas
  Future<List<Sale>> getAllSales() async {
    try {
      if (_isOnline) {
        final sales = await _firestoreService.getSales();
        // Guardar en local
        for (final sale in sales) {
          await _localDatabase.insertSale(sale);
        }
        return sales;
      } else {
        return await _localDatabase.getAllSales();
      }
    } catch (e) {
      return await _localDatabase.getAllSales();
    }
  }

  /// Crear venta
  Future<void> createSale(Sale sale) async {
    await _localDatabase.insertSale(sale);
    
    if (_isOnline) {
      try {
        await _firestoreService.addSale(sale);
      } catch (e) {
        _addPendingOperation('createSale', sale.toMap());
      }
    } else {
      _addPendingOperation('createSale', sale.toMap());
    }
  }

  /// Eliminar venta
  Future<void> deleteSale(String id) async {
    await _localDatabase.deleteSale(id);
    
    if (_isOnline) {
      try {
        await _firestoreService.deleteSale(id);
      } catch (e) {
        _addPendingOperation('deleteSale', {'id': id});
      }
    } else {
      _addPendingOperation('deleteSale', {'id': id});
    }
  }

  // ===== MOVIMIENTOS =====

  /// Obtener todos los movimientos
  Future<List<Movement>> getAllMovements() async {
    try {
      if (_isOnline) {
        final movements = await _firestoreService.getMovements();
        // Guardar en local
        for (final movement in movements) {
          await _localDatabase.insertMovement(movement);
        }
        return movements;
      } else {
        return await _localDatabase.getAllMovements();
      }
    } catch (e) {
      return await _localDatabase.getAllMovements();
    }
  }

  /// Crear movimiento
  Future<void> createMovement(Movement movement) async {
    await _localDatabase.insertMovement(movement);
    
    if (_isOnline) {
      try {
        await _firestoreService.addMovement(movement);
      } catch (e) {
        _addPendingOperation('createMovement', movement.toMap());
      }
    } else {
      _addPendingOperation('createMovement', movement.toMap());
    }
  }

  /// Eliminar movimiento
  Future<void> deleteMovement(String id) async {
    await _localDatabase.deleteMovement(id);
    
    if (_isOnline) {
      try {
        await _firestoreService.deleteMovement(id);
      } catch (e) {
        _addPendingOperation('deleteMovement', {'id': id});
      }
    } else {
      _addPendingOperation('deleteMovement', {'id': id});
    }
  }

  // ===== DASHBOARD =====

  /// Obtener datos del dashboard
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      if (_isOnline) {
        final data = await _firestoreService.getDashboardData();
        return data;
      } else {
        return await _localDatabase.getDashboardData();
      }
    } catch (e) {
      return await _localDatabase.getDashboardData();
    }
  }

  // ===== SINCRONIZACIÓN =====

  /// Agregar operación pendiente
  void _addPendingOperation(String operation, Map<String, dynamic> data) {
    _pendingOperations.add({
      'operation': operation,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Sincronizar operaciones pendientes
  Future<void> _syncPendingOperations() async {
    if (!_isOnline || _pendingOperations.isEmpty) return;

    final operationsToProcess = List<Map<String, dynamic>>.from(_pendingOperations);
    _pendingOperations.clear();

    for (final operation in operationsToProcess) {
      try {
        final opType = operation['operation'] as String;
        final data = operation['data'] as Map<String, dynamic>;

        switch (opType) {
          case 'createProduct':
            final product = Product.fromMap(data, data['id']);
            await _firestoreService.addProduct(product);
            break;
          case 'updateProduct':
            final product = Product.fromMap(data, data['id']);
            await _firestoreService.updateProduct(product.id, product);
            break;
          case 'deleteProduct':
            await _firestoreService.deleteProduct(data['id']);
            break;
          case 'createCategory':
            final category = Category.fromMap(data, data['id']);
            await _firestoreService.addCategory(category);
            break;
          case 'updateCategory':
            final category = Category.fromMap(data, data['id']);
            await _firestoreService.updateCategory(category.id, category);
            break;
          case 'deleteCategory':
            await _firestoreService.deleteCategory(data['id']);
            break;
          case 'createSale':
            final sale = Sale.fromMap(data, data['id']);
            await _firestoreService.addSale(sale);
            break;
          case 'deleteSale':
            await _firestoreService.deleteSale(data['id']);
            break;
          case 'createMovement':
            final movement = Movement.fromMap(data, data['id']);
            await _firestoreService.addMovement(movement);
            break;
          case 'deleteMovement':
            await _firestoreService.deleteMovement(data['id']);
            break;
        }
      } catch (e) {
        // Si falla, volver a agregar a la cola
        _pendingOperations.add(operation);
      }
    }
  }

  /// Forzar sincronización
  Future<void> forceSync() async {
    await _syncPendingOperations();
  }

  /// Obtener estado de sincronización
  Map<String, dynamic> getSyncStatus() {
    return {
      'isOnline': _isOnline,
      'pendingOperations': _pendingOperations.length,
      'lastSync': _pendingOperations.isNotEmpty 
          ? _pendingOperations.last['timestamp'] 
          : null,
    };
  }

  /// Limpiar datos locales
  Future<void> clearLocalData() async {
    await _localDatabase.clearAllData();
    _pendingOperations.clear();
  }

  /// Obtener estadísticas
  Future<Map<String, dynamic>> getStats() async {
    final localStats = await _localDatabase.getDatabaseStats();
    final syncStatus = getSyncStatus();
    
    return {
      'local': localStats,
      'sync': syncStatus,
    };
  }
} 