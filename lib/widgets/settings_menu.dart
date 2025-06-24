import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/sync_viewmodel.dart';
import '../viewmodels/migration_viewmodel.dart';
import '../widgets/sync_status_widget.dart';
import '../config/app_config.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings, color: Colors.white),
      onSelected: (value) => _handleMenuSelection(context, value),
      itemBuilder: (context) => [
        // Estado de sincronización
        PopupMenuItem<String>(
          value: 'sync_status',
          child: Row(
            children: [
              const Icon(Icons.sync),
              const SizedBox(width: 8),
              const Text('Estado de Sincronización'),
            ],
          ),
        ),
        
        // Migración de datos
        PopupMenuItem<String>(
          value: 'migration',
          child: Row(
            children: [
              const Icon(Icons.swap_horiz),
              const SizedBox(width: 8),
              const Text('Migración de Datos'),
            ],
          ),
        ),
        
        // Sincronización manual
        PopupMenuItem<String>(
          value: 'force_sync',
          child: Row(
            children: [
              const Icon(Icons.sync_alt),
              const SizedBox(width: 8),
              const Text('Sincronizar Ahora'),
            ],
          ),
        ),
        
        const PopupMenuDivider(),
        
        // Información de la app
        PopupMenuItem<String>(
          value: 'app_info',
          child: Row(
            children: [
              const Icon(Icons.info),
              const SizedBox(width: 8),
              const Text('Información de la App'),
            ],
          ),
        ),
        
        // Configuración
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings),
              const SizedBox(width: 8),
              const Text('Configuración'),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'sync_status':
        _showSyncStatus(context);
        break;
      case 'migration':
        Navigator.pushNamed(context, '/migration');
        break;
      case 'force_sync':
        _forceSync(context);
        break;
      case 'app_info':
        _showAppInfo(context);
        break;
      case 'settings':
        _showSettings(context);
        break;
    }
  }

  void _showSyncStatus(BuildContext context) {
    final syncViewModel = context.read<SyncViewModel>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(syncViewModel.getSyncStatusIcon()),
            const SizedBox(width: 8),
            const Text('Estado de Sincronización'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusItem('Estado', syncViewModel.getSyncStatusText()),
            if (syncViewModel.pendingChangesCount > 0) ...[
              const SizedBox(height: 8),
              _buildStatusItem('Pendientes', '${syncViewModel.pendingChangesCount} cambios'),
              const SizedBox(height: 4),
              _buildStatusItem('Detalles', syncViewModel.getPendingChangesSummary()),
            ],
            if (syncViewModel.lastSyncTime != null) ...[
              const SizedBox(height: 8),
              _buildStatusItem('Última sincronización', _formatDateTime(syncViewModel.lastSyncTime!)),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Text(
                syncViewModel.getSyncRecommendations(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          if (syncViewModel.pendingChangesCount > 0)
            ElevatedButton(
              onPressed: () {
                syncViewModel.forceSync();
                Navigator.pop(context);
              },
              child: const Text('Sincronizar'),
            ),
        ],
      ),
    );
  }

  void _forceSync(BuildContext context) async {
    final syncViewModel = context.read<SyncViewModel>();
    
    try {
      await syncViewModel.forceSync();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sincronización completada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en sincronización: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAppInfo(BuildContext context) {
    final appInfo = AppConfig.getAppInfo();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de la App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem('Nombre', appInfo['name']),
            _buildInfoItem('Versión', appInfo['version']),
            _buildInfoItem('Empresa', appInfo['company']),
            const SizedBox(height: 16),
            const Text(
              'Funcionalidades:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...appInfo['features'].entries.map((entry) => 
              _buildFeatureItem(entry.key, entry.value)
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSettingItem(
              'Modo Offline',
              'Funcionar sin conexión',
              AppConfig.isFeatureEnabled('offline_mode'),
              (value) {
                // Implementar cambio de configuración
              },
            ),
            _buildSettingItem(
              'Sincronización Automática',
              'Sincronizar automáticamente',
              AppConfig.isFeatureEnabled('auto_sync'),
              (value) {
                // Implementar cambio de configuración
              },
            ),
            _buildSettingItem(
              'APIs Externas',
              'Usar datos externos',
              AppConfig.isFeatureEnabled('external_apis'),
              (value) {
                // Implementar cambio de configuración
              },
            ),
            _buildSettingItem(
              'Alertas de Stock Bajo',
              'Notificar stock bajo',
              AppConfig.isFeatureEnabled('low_stock_alerts'),
              (value) {
                // Implementar cambio de configuración
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_formatFeatureName(feature)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  String _formatFeatureName(String feature) {
    switch (feature) {
      case 'offline_mode':
        return 'Modo Offline';
      case 'auto_sync':
        return 'Sincronización Automática';
      case 'external_apis':
        return 'APIs Externas';
      case 'low_stock_alerts':
        return 'Alertas de Stock Bajo';
      case 'auto_reports':
        return 'Reportes Automáticos';
      case 'data_encryption':
        return 'Encriptación de Datos';
      case 'lazy_loading':
        return 'Carga Lazy';
      default:
        return feature;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Hace ${difference.inSeconds} segundos';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }
} 