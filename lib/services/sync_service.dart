import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'hybrid_data_service.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/sale.dart';
import '../models/movement.dart';
import '../utils/error_handler.dart';

class SyncService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final HybridDataService _hybridService;
  final Connectivity _connectivity;
  
  // Streams para sincronización en tiempo real
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  StreamSubscription<QuerySnapshot>? _productsSubscription;
  StreamSubscription<QuerySnapshot>? _categoriesSubscription;
  StreamSubscription<QuerySnapshot>? _salesSubscription;
  StreamSubscription<QuerySnapshot>? _movementsSubscription;
  
  // Control de sincronización
  bool _isOnline = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  
  // Cola de cambios pendientes
  final List<Map<String, dynamic>> _pendingChanges = [];
  
  // Timers para sincronización
  Timer? _syncTimer;
  Timer? _retryTimer;
  
  // Configuración
  static const int _syncIntervalSeconds = 30; // Sincronizar cada 30 segundos
  static const int _retryIntervalSeconds = 60; // Reintentar cada minuto
  static const int _maxRetries = 3;

  SyncService(this._firestore, this._auth, this._hybridService)
      : _connectivity = Connectivity() {
    _initializeSync();
  }

  // Getters
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingChangesCount => _pendingChanges.length;

  /// Inicializar sincronización
  Future<void> _initializeSync() async {
    try {
      // Verificar conectividad inicial
      final connectivityResult = await _connectivity.checkConnectivity();
      _isOnline = connectivityResult != ConnectivityResult.none;
      
      // Suscribirse a cambios de conectividad
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
      );
      
      // Iniciar sincronización si está online
      if (_isOnline) {
        await _startRealtimeSync();
        await _syncPendingChanges();
      }
      
      // Configurar timer de sincronización
      _syncTimer = Timer.periodic(
        Duration(seconds: _syncIntervalSeconds),
        (_) => _performPeriodicSync(),
      );
      
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Manejar cambios de conectividad
  void _onConnectivityChanged(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;
    
    if (!wasOnline && _isOnline) {
      // Conectado - iniciar sincronización
      _startRealtimeSync();
      _syncPendingChanges();
    } else if (wasOnline && !_isOnline) {
      // Desconectado - detener sincronización
      _stopRealtimeSync();
    }
  }

  /// Iniciar sincronización en tiempo real
  Future<void> _startRealtimeSync() async {
    if (!_isOnline) return;
    
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Suscribirse a cambios de productos
      _productsSubscription = _firestore
          .collection('pm')
          .doc(userId)
          .collection('products')
          .snapshots()
          .listen(_onProductsChanged);

      // Suscribirse a cambios de categorías
      _categoriesSubscription = _firestore
          .collection('pm')
          .doc(userId)
          .collection('categories')
          .snapshots()
          .listen(_onCategoriesChanged);

      // Suscribirse a cambios de ventas
      _salesSubscription = _firestore
          .collection('pm')
          .doc(userId)
          .collection('sales')
          .snapshots()
          .listen(_onSalesChanged);

      // Suscribirse a cambios de movimientos
      _movementsSubscription = _firestore
          .collection('pm')
          .doc(userId)
          .collection('movements')
          .snapshots()
          .listen(_onMovementsChanged);

    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Detener sincronización en tiempo real
  void _stopRealtimeSync() {
    _productsSubscription?.cancel();
    _categoriesSubscription?.cancel();
    _salesSubscription?.cancel();
    _movementsSubscription?.cancel();
    
    _productsSubscription = null;
    _categoriesSubscription = null;
    _salesSubscription = null;
    _movementsSubscription = null;
  }

  /// Manejar cambios de productos en Firebase
  void _onProductsChanged(QuerySnapshot snapshot) async {
    if (_isSyncing) return; // Evitar loops de sincronización
    
    try {
      _isSyncing = true;
      
      for (final change in snapshot.docChanges) {
        final productData = change.doc.data() as Map<String, dynamic>;
        final product = Product.fromMap(productData, change.doc.id);
        
        switch (change.type) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            await _hybridService.updateProduct(product);
            break;
          case DocumentChangeType.removed:
            await _hybridService.deleteProduct(change.doc.id);
            break;
        }
      }
      
      _lastSyncTime = DateTime.now();
    } catch (e) {
      print('Error sincronizando productos: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Manejar cambios de categorías en Firebase
  void _onCategoriesChanged(QuerySnapshot snapshot) async {
    if (_isSyncing) return;
    
    try {
      _isSyncing = true;
      
      for (final change in snapshot.docChanges) {
        final categoryData = change.doc.data() as Map<String, dynamic>;
        final category = Category.fromMap(categoryData, change.doc.id);
        
        switch (change.type) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            await _hybridService.updateCategory(category);
            break;
          case DocumentChangeType.removed:
            await _hybridService.deleteCategory(change.doc.id);
            break;
        }
      }
      
      _lastSyncTime = DateTime.now();
    } catch (e) {
      print('Error sincronizando categorías: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Manejar cambios de ventas en Firebase
  void _onSalesChanged(QuerySnapshot snapshot) async {
    if (_isSyncing) return;
    
    try {
      _isSyncing = true;
      
      for (final change in snapshot.docChanges) {
        final saleData = change.doc.data() as Map<String, dynamic>;
        final sale = Sale.fromMap(saleData, change.doc.id);
        
        switch (change.type) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            await _hybridService.createSale(sale);
            break;
          case DocumentChangeType.removed:
            await _hybridService.deleteSale(change.doc.id);
            break;
        }
      }
      
      _lastSyncTime = DateTime.now();
    } catch (e) {
      print('Error sincronizando ventas: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Manejar cambios de movimientos en Firebase
  void _onMovementsChanged(QuerySnapshot snapshot) async {
    if (_isSyncing) return;
    
    try {
      _isSyncing = true;
      
      for (final change in snapshot.docChanges) {
        final movementData = change.doc.data() as Map<String, dynamic>;
        final movement = Movement.fromMap(movementData, change.doc.id);
        
        switch (change.type) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            await _hybridService.createMovement(movement);
            break;
          case DocumentChangeType.removed:
            await _hybridService.deleteMovement(change.doc.id);
            break;
        }
      }
      
      _lastSyncTime = DateTime.now();
    } catch (e) {
      print('Error sincronizando movimientos: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sincronización periódica
  Future<void> _performPeriodicSync() async {
    if (!_isOnline || _isSyncing) return;
    
    try {
      await _syncPendingChanges();
    } catch (e) {
      print('Error en sincronización periódica: $e');
    }
  }

  /// Sincronizar cambios pendientes
  Future<void> _syncPendingChanges() async {
    if (!_isOnline || _pendingChanges.isEmpty) return;
    
    try {
      _isSyncing = true;
      
      final changesToSync = List<Map<String, dynamic>>.from(_pendingChanges);
      _pendingChanges.clear();
      
      for (final change in changesToSync) {
        await _syncChangeToFirebase(change);
      }
      
      _lastSyncTime = DateTime.now();
    } catch (e) {
      // Reintentar cambios fallidos
      _pendingChanges.addAll(_pendingChanges);
      _scheduleRetry();
    } finally {
      _isSyncing = false;
    }
  }

  /// Sincronizar un cambio específico a Firebase
  Future<void> _syncChangeToFirebase(Map<String, dynamic> change) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      final collection = change['collection'] as String;
      final action = change['action'] as String;
      final data = change['data'] as Map<String, dynamic>;
      final id = change['id'] as String;

      final docRef = _firestore
          .collection('pm')
          .doc(userId)
          .collection(collection)
          .doc(id);

      switch (action) {
        case 'create':
          await docRef.set(data);
          break;
        case 'update':
          await docRef.update(data);
          break;
        case 'delete':
          await docRef.delete();
          break;
      }
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Programar reintento
  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(
      Duration(seconds: _retryIntervalSeconds),
      () => _syncPendingChanges(),
    );
  }

  // ===== MÉTODOS PÚBLICOS =====

  /// Agregar producto (local + Firebase)
  Future<void> addProduct(Product product) async {
    try {
      // Agregar usando el servicio híbrido
      await _hybridService.createProduct(product);
      
      // Sincronizar con Firebase si está offline
      if (!_isOnline) {
        _pendingChanges.add({
          'collection': 'products',
          'action': 'create',
          'data': product.toMap(),
          'id': product.id,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Actualizar producto (local + Firebase)
  Future<void> updateProduct(Product product) async {
    try {
      // Actualizar usando el servicio híbrido
      await _hybridService.updateProduct(product);
      
      // Sincronizar con Firebase si está offline
      if (!_isOnline) {
        _pendingChanges.add({
          'collection': 'products',
          'action': 'update',
          'data': product.toMap(),
          'id': product.id,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Eliminar producto (local + Firebase)
  Future<void> deleteProduct(String id) async {
    try {
      // Eliminar usando el servicio híbrido
      await _hybridService.deleteProduct(id);
      
      // Sincronizar con Firebase si está offline
      if (!_isOnline) {
        _pendingChanges.add({
          'collection': 'products',
          'action': 'delete',
          'data': {},
          'id': id,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Agregar categoría (local + Firebase)
  Future<void> addCategory(Category category) async {
    try {
      await _hybridService.createCategory(category);
      
      if (!_isOnline) {
        _pendingChanges.add({
          'collection': 'categories',
          'action': 'create',
          'data': category.toMap(),
          'id': category.id,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Actualizar categoría (local + Firebase)
  Future<void> updateCategory(Category category) async {
    try {
      await _hybridService.updateCategory(category);
      
      if (!_isOnline) {
        _pendingChanges.add({
          'collection': 'categories',
          'action': 'update',
          'data': category.toMap(),
          'id': category.id,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Eliminar categoría (local + Firebase)
  Future<void> deleteCategory(String id) async {
    try {
      await _hybridService.deleteCategory(id);
      
      if (!_isOnline) {
        _pendingChanges.add({
          'collection': 'categories',
          'action': 'delete',
          'data': {},
          'id': id,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Agregar venta (local + Firebase)
  Future<void> addSale(Sale sale) async {
    try {
      await _hybridService.createSale(sale);
      
      if (!_isOnline) {
        _pendingChanges.add({
          'collection': 'sales',
          'action': 'create',
          'data': sale.toMap(),
          'id': sale.id,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Eliminar venta (local + Firebase)
  Future<void> deleteSale(String id) async {
    try {
      await _hybridService.deleteSale(id);
      
      if (!_isOnline) {
        _pendingChanges.add({
          'collection': 'sales',
          'action': 'delete',
          'data': {},
          'id': id,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Agregar movimiento (local + Firebase)
  Future<void> addMovement(Movement movement) async {
    try {
      await _hybridService.createMovement(movement);
      
      if (!_isOnline) {
        _pendingChanges.add({
          'collection': 'movements',
          'action': 'create',
          'data': movement.toMap(),
          'id': movement.id,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Eliminar movimiento (local + Firebase)
  Future<void> deleteMovement(String id) async {
    try {
      await _hybridService.deleteMovement(id);
      
      if (!_isOnline) {
        _pendingChanges.add({
          'collection': 'movements',
          'action': 'delete',
          'data': {},
          'id': id,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Sincronización manual
  Future<void> forceSync() async {
    try {
      await _syncPendingChanges();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Obtener estado de sincronización
  Map<String, dynamic> getSyncStatus() {
    return {
      'isOnline': _isOnline,
      'isSyncing': _isSyncing,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
      'pendingChangesCount': _pendingChanges.length,
      'pendingChanges': _pendingChanges.map((change) => {
        'collection': change['collection'],
        'action': change['action'],
        'id': change['id'],
        'timestamp': change['timestamp'],
      }).toList(),
    };
  }

  /// Limpiar cambios pendientes
  void clearPendingChanges() {
    _pendingChanges.clear();
  }

  /// Cerrar servicio
  Future<void> dispose() async {
    _connectivitySubscription?.cancel();
    _productsSubscription?.cancel();
    _categoriesSubscription?.cancel();
    _salesSubscription?.cancel();
    _movementsSubscription?.cancel();
    _syncTimer?.cancel();
    _retryTimer?.cancel();
  }
} 