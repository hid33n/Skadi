import '../utils/error_handler.dart';

enum SyncStatus {
  idle,
  syncing,
  error,
  completed,
}

class SyncService {
  SyncStatus _currentStatus = SyncStatus.idle;
  bool _isInitialized = false;

  // Getters
  SyncStatus get currentStatus => _currentStatus;
  bool get isInitialized => _isInitialized;

  /// Inicializar el servicio de sincronización
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Simular inicialización ya que usamos Firestore directamente
      await Future.delayed(const Duration(milliseconds: 100));
      
      _isInitialized = true;
      _currentStatus = SyncStatus.idle;
    } catch (e) {
      _currentStatus = SyncStatus.error;
      throw AppError.fromException(e);
    }
  }

  /// Sincronizar datos (simulado ya que usamos Firestore directamente)
  Future<void> syncData() async {
    if (!_isInitialized) await initialize();

    _currentStatus = SyncStatus.syncing;

    try {
      // Simular sincronización
      await Future.delayed(const Duration(seconds: 2));
      
      _currentStatus = SyncStatus.completed;
      
      // Volver a estado idle después de 3 segundos
      await Future.delayed(const Duration(seconds: 3));
      _currentStatus = SyncStatus.idle;
      
    } catch (e) {
      _currentStatus = SyncStatus.error;
      throw AppError.fromException(e);
    }
  }

  /// Obtener estadísticas de sincronización
  Map<String, dynamic> getSyncStats() {
    return {
      'status': _currentStatus.toString().split('.').last,
      'isInitialized': _isInitialized,
      'lastSync': DateTime.now(),
    };
  }

  /// Disposal
  void dispose() {
    _currentStatus = SyncStatus.idle;
    _isInitialized = false;
  }
} 