import 'package:flutter/foundation.dart' as foundation;
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../utils/error_handler.dart';

class SyncViewModel extends foundation.ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthService _authService;
  
  bool _isSyncing = false;
  String? _syncStatus;
  String? _error;
  DateTime? _lastSyncTime;

  SyncViewModel(this._firestoreService, this._authService);

  bool get isSyncing => _isSyncing;
  String? get syncStatus => _syncStatus;
  String? get error => _error;
  DateTime? get lastSyncTime => _lastSyncTime;

  Future<void> syncData() async {
    try {
      _isSyncing = true;
      _error = null;
      _syncStatus = 'Iniciando sincronización...';
      notifyListeners();

      print('🔄 SyncViewModel: Iniciando sincronización de datos');
      
      // Simular sincronización (ya que ahora usamos Firestore directamente)
      await Future.delayed(const Duration(seconds: 2));
      
      _syncStatus = 'Sincronización completada';
      _lastSyncTime = DateTime.now();
      
      print('✅ SyncViewModel: Sincronización completada');
      _isSyncing = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      _syncStatus = 'Error en sincronización';
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> checkSyncStatus() async {
    try {
      _syncStatus = 'Verificando estado de sincronización...';
      notifyListeners();

      // Simular verificación de estado
      await Future.delayed(const Duration(milliseconds: 500));
      
      _syncStatus = 'Sincronizado';
      _lastSyncTime = DateTime.now();
      notifyListeners();
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      _syncStatus = 'Error al verificar estado';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSyncStatus() {
    _syncStatus = null;
    notifyListeners();
  }
} 