import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../viewmodels/sync_viewmodel.dart';
import '../services/sync_service.dart';

class AppConfig {
  /// Inicializar servicios de sincronización
  static Future<void> initializeSync(BuildContext context) async {
    try {
      final syncViewModel = context.read<SyncViewModel>();
      await syncViewModel.initialize();
      print('✅ Sincronización inicializada correctamente');
    } catch (e) {
      print('❌ Error inicializando sincronización: $e');
    }
  }

  /// Configuración de la aplicación
  static const Map<String, dynamic> appSettings = {
    'appName': 'Stockcito - Planeta Motos',
    'version': '1.0.0',
    'company': 'Planeta Motos',
    'supportEmail': 'soporte@planetamotos.com',
    'syncInterval': 30, // segundos
    'maxRetries': 3,
    'offlineMode': true,
    'autoSync': true,
  };

  /// Configuración de sincronización
  static const Map<String, dynamic> syncSettings = {
    'enableAutoSync': true,
    'syncIntervalSeconds': 30,
    'retryIntervalSeconds': 60,
    'maxRetries': 3,
    'enableOfflineMode': true,
    'enableConflictResolution': true,
    'enableBackup': true,
    'backupIntervalHours': 24,
  };

  /// Configuración de la base de datos
  static const Map<String, dynamic> databaseSettings = {
    'localDatabaseName': 'stockcito.db',
    'maxLocalStorage': 100 * 1024 * 1024, // 100MB
    'enableCompression': false,
    'enableEncryption': false,
  };

  /// Configuración de APIs externas
  static const Map<String, dynamic> apiSettings = {
    'enableExternalAPIs': true,
    'enablePriceComparison': true,
    'enableOEMLookup': true,
    'enableCompatibilityCheck': true,
    'cacheExpirationHours': 24,
  };

  /// Configuración de notificaciones
  static const Map<String, dynamic> notificationSettings = {
    'enableLowStockAlerts': true,
    'enableSyncNotifications': true,
    'enableErrorNotifications': true,
    'lowStockThreshold': 3,
  };

  /// Configuración de reportes
  static const Map<String, dynamic> reportSettings = {
    'enableAutoReports': false,
    'reportIntervalDays': 7,
    'enableEmailReports': false,
    'enablePDFExport': true,
    'enableExcelExport': true,
  };

  /// Configuración de seguridad
  static const Map<String, dynamic> securitySettings = {
    'enableDataEncryption': false,
    'enableBackupEncryption': false,
    'sessionTimeoutMinutes': 30,
    'maxLoginAttempts': 5,
  };

  /// Configuración de rendimiento
  static const Map<String, dynamic> performanceSettings = {
    'enableLazyLoading': true,
    'enableCaching': true,
    'cacheSizeMB': 50,
    'maxConcurrentOperations': 5,
    'enableBackgroundSync': true,
  };

  /// Obtener configuración específica
  static T getSetting<T>(String category, String key, T defaultValue) {
    final categoryMap = {
      'app': appSettings,
      'sync': syncSettings,
      'database': databaseSettings,
      'api': apiSettings,
      'notification': notificationSettings,
      'report': reportSettings,
      'security': securitySettings,
      'performance': performanceSettings,
    };

    final settings = categoryMap[category];
    if (settings != null && settings.containsKey(key)) {
      return settings[key] as T;
    }
    return defaultValue;
  }

  /// Verificar si una funcionalidad está habilitada
  static bool isFeatureEnabled(String feature) {
    switch (feature) {
      case 'offline_mode':
        return getSetting('sync', 'enableOfflineMode', true);
      case 'auto_sync':
        return getSetting('sync', 'enableAutoSync', true);
      case 'external_apis':
        return getSetting('api', 'enableExternalAPIs', true);
      case 'low_stock_alerts':
        return getSetting('notification', 'enableLowStockAlerts', true);
      case 'auto_reports':
        return getSetting('report', 'enableAutoReports', false);
      case 'data_encryption':
        return getSetting('security', 'enableDataEncryption', false);
      case 'lazy_loading':
        return getSetting('performance', 'enableLazyLoading', true);
      default:
        return false;
    }
  }

  /// Obtener información de la aplicación
  static Map<String, dynamic> getAppInfo() {
    return {
      'name': appSettings['appName'],
      'version': appSettings['version'],
      'company': appSettings['company'],
      'features': {
        'offline_mode': isFeatureEnabled('offline_mode'),
        'auto_sync': isFeatureEnabled('auto_sync'),
        'external_apis': isFeatureEnabled('external_apis'),
        'low_stock_alerts': isFeatureEnabled('low_stock_alerts'),
        'auto_reports': isFeatureEnabled('auto_reports'),
        'data_encryption': isFeatureEnabled('data_encryption'),
        'lazy_loading': isFeatureEnabled('lazy_loading'),
      },
      'settings': {
        'sync_interval': getSetting('sync', 'syncIntervalSeconds', 30),
        'max_retries': getSetting('sync', 'maxRetries', 3),
        'low_stock_threshold': getSetting('notification', 'lowStockThreshold', 3),
        'cache_size_mb': getSetting('performance', 'cacheSizeMB', 50),
      },
    };
  }
} 