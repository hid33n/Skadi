import 'package:flutter/material.dart';
import '../services/sync_service.dart';

class SyncStatusWidget extends StatelessWidget {
  final SyncService syncService;

  const SyncStatusWidget({
    Key? key,
    required this.syncService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: syncService.statusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.idle;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusIcon(status),
              const SizedBox(width: 8),
              Text(
                _getStatusText(status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (status == SyncStatus.syncing) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(SyncStatus status) {
    IconData iconData;
    Color iconColor = Colors.white;

    switch (status) {
      case SyncStatus.idle:
        iconData = Icons.cloud_done;
        break;
      case SyncStatus.syncing:
        iconData = Icons.sync;
        break;
      case SyncStatus.error:
        iconData = Icons.error;
        break;
      case SyncStatus.completed:
        iconData = Icons.check_circle;
        break;
    }

    return Icon(
      iconData,
      size: 16,
      color: iconColor,
    );
  }

  Color _getStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Colors.grey.shade600;
      case SyncStatus.syncing:
        return Colors.blue.shade600;
      case SyncStatus.error:
        return Colors.red.shade600;
      case SyncStatus.completed:
        return Colors.green.shade600;
    }
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Sincronizado';
      case SyncStatus.syncing:
        return 'Sincronizando...';
      case SyncStatus.error:
        return 'Error de sincronización';
      case SyncStatus.completed:
        return 'Sincronización completada';
    }
  }
}

class SyncProgressWidget extends StatelessWidget {
  final SyncService syncService;

  const SyncProgressWidget({
    Key? key,
    required this.syncService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: syncService.progressStream,
      builder: (context, snapshot) {
        final progress = snapshot.data;
        
        if (progress == null || progress.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.sync,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  progress,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SyncOfflineIndicator extends StatelessWidget {
  final SyncService syncService;

  const SyncOfflineIndicator({
    Key? key,
    required this.syncService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: syncService.connectivityStream,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        
        if (isOnline) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.orange.shade100,
          child: Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.orange.shade800,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Sin conexión a internet. Los cambios se guardarán localmente.',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 