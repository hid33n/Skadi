import 'package:flutter/foundation.dart';
import '../services/migration_service.dart';
import '../services/hybrid_data_service.dart';
import '../utils/error_handler.dart';

class MigrationViewModel extends ChangeNotifier {
  final MigrationService _migrationService;
  final HybridDataService _dataService;

  MigrationViewModel(this._migrationService, this._dataService);

  // Estados
  bool _isMigrating = false;
  bool _isCheckingData = false;
  bool _isExporting = false;
  bool _isImporting = false;
  
  String _currentStep = '';
  int _currentProgress = 0;
  int _totalSteps = 0;
  
  Map<String, int> _migrationResults = {};
  Map<String, bool> _firebaseDataStatus = {};
  Map<String, int> _firebaseStats = {};
  Map<String, bool> _verificationResults = {};

  // Getters
  bool get isMigrating => _isMigrating;
  bool get isCheckingData => _isCheckingData;
  bool get isExporting => _isExporting;
  bool get isImporting => _isImporting;
  
  String get currentStep => _currentStep;
  int get currentProgress => _currentProgress;
  int get totalSteps => _totalSteps;
  
  Map<String, int> get migrationResults => _migrationResults;
  Map<String, bool> get firebaseDataStatus => _firebaseDataStatus;
  Map<String, int> get firebaseStats => _firebaseStats;
  Map<String, bool> get verificationResults => _verificationResults;

  /// Verificar datos en Firebase
  Future<void> checkFirebaseData() async {
    try {
      _isCheckingData = true;
      _currentStep = 'Verificando datos en Firebase...';
      notifyListeners();

      // Verificar si hay usuario autenticado
      if (_migrationService.auth.currentUser == null) {
        _firebaseDataStatus = {};
        _firebaseStats = {};
        _isCheckingData = false;
        _currentStep = '';
        notifyListeners();
        return;
      }

      _firebaseDataStatus = await _migrationService.checkFirebaseData();
      _firebaseStats = await _migrationService.getFirebaseStats();

      _isCheckingData = false;
      _currentStep = '';
      notifyListeners();
    } catch (e) {
      _isCheckingData = false;
      _currentStep = '';
      notifyListeners();
      throw AppError.fromException(e);
    }
  }

  /// Migrar todos los datos
  Future<void> migrateAllData() async {
    try {
      _isMigrating = true;
      _totalSteps = 4;
      _currentProgress = 0;
      _migrationResults.clear();
      
      notifyListeners();

      // Migrar categorías
      _currentStep = 'Migrando categorías...';
      _currentProgress = 1;
      notifyListeners();
      
      _migrationResults['categories'] = await _migrationService.migrateSpecificData('categories');

      // Migrar productos
      _currentStep = 'Migrando productos...';
      _currentProgress = 2;
      notifyListeners();
      
      _migrationResults['products'] = await _migrationService.migrateSpecificData('products');

      // Migrar ventas
      _currentStep = 'Migrando ventas...';
      _currentProgress = 3;
      notifyListeners();
      
      _migrationResults['sales'] = await _migrationService.migrateSpecificData('sales');

      // Migrar movimientos
      _currentStep = 'Migrando movimientos...';
      _currentProgress = 4;
      notifyListeners();
      
      _migrationResults['movements'] = await _migrationService.migrateSpecificData('movements');

      // Verificar migración
      _currentStep = 'Verificando migración...';
      notifyListeners();
      
      _verificationResults = await _migrationService.verifyMigration();

      _isMigrating = false;
      _currentStep = 'Migración completada';
      notifyListeners();

      // Limpiar estado después de un delay
      Future.delayed(const Duration(seconds: 3), () {
        _currentStep = '';
        notifyListeners();
      });

    } catch (e) {
      _isMigrating = false;
      _currentStep = 'Error en la migración';
      notifyListeners();
      
      // Limpiar estado después de un delay
      Future.delayed(const Duration(seconds: 3), () {
        _currentStep = '';
        notifyListeners();
      });
      
      throw AppError.fromException(e);
    }
  }

  /// Migrar datos específicos
  Future<void> migrateSpecificData(String collection, {int? limit}) async {
    try {
      _isMigrating = true;
      _currentStep = 'Migrando $collection...';
      notifyListeners();

      final count = await _migrationService.migrateSpecificData(collection, limit: limit);
      _migrationResults[collection] = count;

      _isMigrating = false;
      _currentStep = 'Migración de $collection completada';
      notifyListeners();

      // Limpiar estado después de un delay
      Future.delayed(const Duration(seconds: 2), () {
        _currentStep = '';
        notifyListeners();
      });

    } catch (e) {
      _isMigrating = false;
      _currentStep = 'Error migrando $collection';
      notifyListeners();
      
      // Limpiar estado después de un delay
      Future.delayed(const Duration(seconds: 2), () {
        _currentStep = '';
        notifyListeners();
      });
      
      throw AppError.fromException(e);
    }
  }

  /// Exportar datos locales
  Future<Map<String, dynamic>> exportLocalData() async {
    try {
      _isExporting = true;
      _currentStep = 'Exportando datos locales...';
      notifyListeners();

      final data = await _migrationService.exportLocalData();

      _isExporting = false;
      _currentStep = 'Exportación completada';
      notifyListeners();

      // Limpiar estado después de un delay
      Future.delayed(const Duration(seconds: 2), () {
        _currentStep = '';
        notifyListeners();
      });

      return data;
    } catch (e) {
      _isExporting = false;
      _currentStep = 'Error en la exportación';
      notifyListeners();
      
      // Limpiar estado después de un delay
      Future.delayed(const Duration(seconds: 2), () {
        _currentStep = '';
        notifyListeners();
      });
      
      throw AppError.fromException(e);
    }
  }

  /// Importar datos
  Future<void> importData(Map<String, dynamic> data) async {
    try {
      _isImporting = true;
      _currentStep = 'Importando datos...';
      notifyListeners();

      await _migrationService.importData(data);

      _isImporting = false;
      _currentStep = 'Importación completada';
      notifyListeners();

      // Limpiar estado después de un delay
      Future.delayed(const Duration(seconds: 2), () {
        _currentStep = '';
        notifyListeners();
      });

    } catch (e) {
      _isImporting = false;
      _currentStep = 'Error en la importación';
      notifyListeners();
      
      // Limpiar estado después de un delay
      Future.delayed(const Duration(seconds: 2), () {
        _currentStep = '';
        notifyListeners();
      });
      
      throw AppError.fromException(e);
    }
  }

  /// Verificar migración
  Future<Map<String, bool>> verifyMigration() async {
    try {
      _currentStep = 'Verificando migración...';
      notifyListeners();

      _verificationResults = await _migrationService.verifyMigration();

      _currentStep = 'Verificación completada';
      notifyListeners();

      // Limpiar estado después de un delay
      Future.delayed(const Duration(seconds: 2), () {
        _currentStep = '';
        notifyListeners();
      });

      return _verificationResults;
    } catch (e) {
      _currentStep = 'Error en la verificación';
      notifyListeners();
      
      // Limpiar estado después de un delay
      Future.delayed(const Duration(seconds: 2), () {
        _currentStep = '';
        notifyListeners();
      });
      
      throw AppError.fromException(e);
    }
  }

  /// Limpiar datos locales
  Future<void> clearLocalData() async {
    try {
      _currentStep = 'Limpiando datos locales...';
      notifyListeners();

      await _migrationService.clearLocalData();

      _currentStep = 'Datos locales eliminados';
      notifyListeners();

      // Limpiar estado después de un delay
      Future.delayed(const Duration(seconds: 2), () {
        _currentStep = '';
        notifyListeners();
      });

    } catch (e) {
      _currentStep = 'Error al limpiar datos';
      notifyListeners();
      
      // Limpiar estado después de un delay
      Future.delayed(const Duration(seconds: 2), () {
        _currentStep = '';
        notifyListeners();
      });
      
      throw AppError.fromException(e);
    }
  }

  /// Obtener resumen de migración
  String getMigrationSummary() {
    if (_migrationResults.isEmpty) {
      return 'No hay datos migrados';
    }

    final totalItems = _migrationResults.values.fold<int>(0, (sum, count) => sum + count);
    final categories = _migrationResults['categories'] ?? 0;
    final products = _migrationResults['products'] ?? 0;
    final sales = _migrationResults['sales'] ?? 0;
    final movements = _migrationResults['movements'] ?? 0;

    return '''
Migración completada:
• Categorías: $categories
• Productos: $products
• Ventas: $sales
• Movimientos: $movements
• Total: $totalItems elementos
''';
  }

  /// Obtener resumen de datos en Firebase
  String getFirebaseSummary() {
    if (_firebaseStats.isEmpty) {
      return 'No hay datos en Firebase';
    }

    final categories = _firebaseStats['categories'] ?? 0;
    final products = _firebaseStats['products'] ?? 0;
    final sales = _firebaseStats['sales'] ?? 0;
    final movements = _firebaseStats['movements'] ?? 0;
    final total = categories + products + sales + movements;

    return '''
Datos en Firebase:
• Categorías: $categories
• Productos: $products
• Ventas: $sales
• Movimientos: $movements
• Total: $total elementos
''';
  }

  /// Limpiar todos los estados
  void clearStates() {
    _isMigrating = false;
    _isCheckingData = false;
    _isExporting = false;
    _isImporting = false;
    _currentStep = '';
    _currentProgress = 0;
    _totalSteps = 0;
    _migrationResults.clear();
    _firebaseDataStatus.clear();
    _firebaseStats.clear();
    _verificationResults.clear();
    notifyListeners();
  }

  /// Verificar si hay datos para migrar
  bool get hasDataToMigrate {
    return _firebaseStats.values.any((count) => count > 0);
  }

  /// Verificar si la migración fue exitosa
  bool get isMigrationSuccessful {
    return _verificationResults.values.every((success) => success);
  }

  /// Obtener progreso como porcentaje
  double get progressPercentage {
    if (_totalSteps == 0) return 0.0;
    return (_currentProgress / _totalSteps) * 100;
  }
} 