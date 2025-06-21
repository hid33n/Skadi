import 'package:flutter/material.dart';
import '../services/sync_service.dart';

class SyncStatusWidget extends StatelessWidget {
  final SyncService syncService;

  const SyncStatusWidget({
    super.key,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(syncService.currentStatus),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(syncService.currentStatus),
          const SizedBox(width: 8),
          Text(
            _getStatusText(syncService.currentStatus),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (syncService.currentStatus == SyncStatus.syncing) ...[
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
    super.key,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    // Ya no mostramos progreso ya que la sincronización es instantánea
    return const SizedBox.shrink();
  }
}

class SyncOfflineIndicator extends StatelessWidget {
  final SyncService syncService;

  const SyncOfflineIndicator({
    super.key,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    // Ya no necesitamos indicador offline ya que usamos Firestore directamente
    return const SizedBox.shrink();
  }
} 