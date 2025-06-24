import 'package:flutter/foundation.dart';
import 'dart:async';
import '../services/sync_service.dart';
import '../services/hybrid_data_service.dart';
import '../utils/error_handler.dart';

class SyncViewModel extends ChangeNotifier {
  final SyncService _syncService;
  final HybridDataService _hybridService;

  SyncViewModel(this._syncService, this._hybridService);

  // Estados
  bool _isOnline = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  int _pendingChangesCount = 0;
  List<Map<String, dynamic>> _pendingChanges = [];
  Timer? _statusTimer;

  // Getters
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingChangesCount => _pendingChangesCount;
  List<Map<String, dynamic>> get pendingChanges => _pendingChanges;

  /// Inicializar el ViewModel
  Future<void> initialize() async {
    try {
      // Obtener estado inicial
      await _updateSyncStatus();
      
      // Configurar timer para actualizar estado
      _startStatusTimer();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Actualizar estado de sincronización
  Future<void> _updateSyncStatus() async {
    try {
      // Obtener estado del servicio híbrido
      final hybridStatus = _hybridService.getSyncStatus();
      
      // Obtener estado del servicio de sincronización
      final syncStatus = _syncService.getSyncStatus();
      
      _isOnline = hybridStatus['isOnline'] as bool;
      _isSyncing = syncStatus['isSyncing'] as bool;
      _lastSyncTime = hybridStatus['lastSync'] != null 
          ? DateTime.parse(hybridStatus['lastSync'] as String)
          : null;
      _pendingChangesCount = hybridStatus['pendingOperations'] as int;
      
      // Obtener estadísticas de la base de datos local
      final stats = await _hybridService.getStats();
      
      notifyListeners();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Iniciar timer de actualización de estado
  void _startStatusTimer() {
    // Actualizar estado cada 5 segundos
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _updateSyncStatus();
    });
  }

  /// Sincronización manual
  Future<void> forceSync() async {
    try {
      await _hybridService.forceSync();
      await _updateSyncStatus();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Limpiar cambios pendientes
  Future<void> clearPendingChanges() async {
    try {
      // Limpiar datos locales (cuidado: esto eliminará todos los datos)
      await _hybridService.clearLocalData();
      await _updateSyncStatus();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Obtener estado de sincronización como texto
  String getSyncStatusText() {
    if (!_isOnline) {
      return 'Sin conexión - Modo offline';
    }
    
    if (_isSyncing) {
      return 'Sincronizando...';
    }
    
    if (_pendingChangesCount > 0) {
      return 'Pendientes: $_pendingChangesCount cambios';
    }
    
    if (_lastSyncTime != null) {
      final now = DateTime.now();
      final difference = now.difference(_lastSyncTime!);
      
      if (difference.inMinutes < 1) {
        return 'Sincronizado hace ${difference.inSeconds} segundos';
      } else if (difference.inHours < 1) {
        return 'Sincronizado hace ${difference.inMinutes} minutos';
      } else {
        return 'Sincronizado hace ${difference.inHours} horas';
      }
    }
    
    return 'Sincronizado';
  }

  /// Obtener icono de estado
  String getSyncStatusIcon() {
    if (!_isOnline) {
      return '📡'; // Sin conexión
    }
    
    if (_isSyncing) {
      return '🔄'; // Sincronizando
    }
    
    if (_pendingChangesCount > 0) {
      return '⏳'; // Pendientes
    }
    
    return '✅'; // Sincronizado
  }

  /// Obtener color de estado
  int getSyncStatusColor() {
    if (!_isOnline) {
      return 0xFFFF6B6B; // Rojo
    }
    
    if (_isSyncing) {
      return 0xFFFFA726; // Naranja
    }
    
    if (_pendingChangesCount > 0) {
      return 0xFFFFB74D; // Amarillo
    }
    
    return 0xFF66BB6A; // Verde
  }

  /// Obtener resumen de cambios pendientes
  String getPendingChangesSummary() {
    if (_pendingChangesCount == 0) {
      return 'No hay cambios pendientes';
    }

    return '$_pendingChangesCount operaciones pendientes de sincronización';
  }

  /// Verificar si hay conflictos de sincronización
  bool get hasConflicts {
    // Por ahora, no implementamos detección de conflictos
    // Se puede implementar más adelante
    return false;
  }

  /// Resolver conflictos de sincronización
  Future<void> resolveConflicts() async {
    try {
      // Por ahora, solo forzar sincronización
      await forceSync();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Obtener estadísticas de sincronización
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final stats = await _hybridService.getStats();
      
      return {
        'isOnline': _isOnline,
        'isSyncing': _isSyncing,
        'lastSyncTime': _lastSyncTime?.toIso8601String(),
        'pendingChangesCount': _pendingChangesCount,
        'hasConflicts': hasConflicts,
        'syncStatusText': getSyncStatusText(),
        'syncStatusIcon': getSyncStatusIcon(),
        'syncStatusColor': getSyncStatusColor(),
        'pendingChangesSummary': getPendingChangesSummary(),
        'localStats': stats['local'],
        'syncStats': stats['sync'],
      };
    } catch (e) {
      return {
        'isOnline': _isOnline,
        'isSyncing': _isSyncing,
        'lastSyncTime': _lastSyncTime?.toIso8601String(),
        'pendingChangesCount': _pendingChangesCount,
        'hasConflicts': hasConflicts,
        'syncStatusText': getSyncStatusText(),
        'syncStatusIcon': getSyncStatusIcon(),
        'syncStatusColor': getSyncStatusColor(),
        'pendingChangesSummary': getPendingChangesSummary(),
        'error': e.toString(),
      };
    }
  }

  /// Verificar si la sincronización está funcionando correctamente
  bool get isSyncHealthy {
    if (!_isOnline) return true; // Offline es normal
    
    if (_lastSyncTime == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);
    
    // Considerar no saludable si no se sincronizó en más de 5 minutos
    return difference.inMinutes < 5;
  }

  /// Obtener recomendaciones de sincronización
  String getSyncRecommendations() {
    if (!_isOnline) {
      return 'Conecta a internet para sincronizar tus datos';
    }
    
    if (_pendingChangesCount > 10) {
      return 'Muchos cambios pendientes. Considera sincronizar manualmente';
    }
    
    if (!isSyncHealthy) {
      return 'La sincronización parece tener problemas. Revisa tu conexión';
    }
    
    return 'La sincronización funciona correctamente';
  }

  /// Obtener información detallada del estado
  Future<Map<String, dynamic>> getDetailedStatus() async {
    try {
      final stats = await _hybridService.getStats();
      
      return {
        'connectivity': {
          'isOnline': _isOnline,
          'lastSync': _lastSyncTime?.toIso8601String(),
        },
        'sync': {
          'isSyncing': _isSyncing,
          'pendingOperations': _pendingChangesCount,
          'isHealthy': isSyncHealthy,
        },
        'database': {
          'local': stats['local'],
          'sync': stats['sync'],
        },
        'recommendations': getSyncRecommendations(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'connectivity': {
          'isOnline': _isOnline,
          'lastSync': _lastSyncTime?.toIso8601String(),
        },
        'sync': {
          'isSyncing': _isSyncing,
          'pendingOperations': _pendingChangesCount,
          'isHealthy': isSyncHealthy,
        },
      };
    }
  }

  /// Limpiar recursos
  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
} 