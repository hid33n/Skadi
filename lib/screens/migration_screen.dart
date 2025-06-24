import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/migration_viewmodel.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_overlay.dart';
import '../theme/app_theme.dart';

class MigrationScreen extends StatefulWidget {
  const MigrationScreen({Key? key}) : super(key: key);

  @override
  State<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<MigrationScreen> {
  @override
  void initState() {
    super.initState();
    // Verificar datos de Firebase al cargar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MigrationViewModel>().checkFirebaseData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migración de Datos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Consumer<MigrationViewModel>(
        builder: (context, viewModel, child) {
          return LoadingOverlay(
            isLoading: viewModel.isMigrating || viewModel.isCheckingData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildFirebaseStatus(context, viewModel),
                  const SizedBox(height: 24),
                  _buildLocalStatus(context, viewModel),
                  const SizedBox(height: 24),
                  _buildMigrationOptions(context, viewModel),
                  const SizedBox(height: 24),
                  _buildMigrationProgress(context, viewModel),
                  const SizedBox(height: 24),
                  _buildMigrationResults(context, viewModel),
                  const SizedBox(height: 24),
                  _buildExportImportOptions(context, viewModel),
                  const SizedBox(height: 24),
                  _buildDataManagementOptions(context, viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.swap_horiz,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Migración a Base Local',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Migra tus datos de Firebase a Hive local',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta migración te permitirá usar la app sin conexión a internet y sin costos mensuales. Los datos se almacenan localmente usando Hive.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirebaseStatus(BuildContext context, MigrationViewModel viewModel) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado de Firebase',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (viewModel.isCheckingData)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (viewModel.firebaseStats.isNotEmpty)
            Column(
              children: [
                _buildStatItem(context, 'Categorías', viewModel.firebaseStats['categories'] ?? 0),
                _buildStatItem(context, 'Productos', viewModel.firebaseStats['products'] ?? 0),
                _buildStatItem(context, 'Ventas', viewModel.firebaseStats['sales'] ?? 0),
                _buildStatItem(context, 'Movimientos', viewModel.firebaseStats['movements'] ?? 0),
                const SizedBox(height: 16),
                if (viewModel.hasDataToMigrate)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hay datos disponibles para migrar',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No hay datos en Firebase para migrar',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No se pudo verificar el estado de Firebase',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocalStatus(BuildContext context, MigrationViewModel viewModel) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado de Base Local (Hive)',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Estado local disponible después de migración',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: count > 0 ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMigrationOptions(BuildContext context, MigrationViewModel viewModel) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opciones de Migración',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (viewModel.hasDataToMigrate) ...[
            CustomButton(
              onPressed: viewModel.isMigrating ? null : () => _migrateAllData(viewModel),
              text: 'Migrar Todos los Datos',
              icon: Icons.cloud_download,
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            CustomButton(
              onPressed: viewModel.isMigrating ? null : () => _showSelectiveMigrationDialog(viewModel),
              text: 'Migración Selectiva',
              icon: Icons.filter_list,
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No hay datos disponibles para migrar',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMigrationProgress(BuildContext context, MigrationViewModel viewModel) {
    if (!viewModel.isMigrating && viewModel.currentStep.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso de Migración',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (viewModel.isMigrating) ...[
            LinearProgressIndicator(
              value: viewModel.progressPercentage / 100,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              '${viewModel.progressPercentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            viewModel.currentStep,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildMigrationResults(BuildContext context, MigrationViewModel viewModel) {
    if (viewModel.migrationResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resultados de Migración',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...viewModel.migrationResults.entries.map((entry) => _buildResultItem(context, entry.key, entry.value)),
          const SizedBox(height: 16),
          if (viewModel.isMigrationSuccessful)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Migración completada exitosamente',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultItem(BuildContext context, String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatLabel(label),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportImportOptions(BuildContext context, MigrationViewModel viewModel) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exportar/Importar Datos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  onPressed: viewModel.isExporting ? null : () => _exportData(viewModel),
                  text: 'Exportar',
                  icon: Icons.file_download,
                  backgroundColor: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  onPressed: viewModel.isImporting ? null : () => _importData(viewModel),
                  text: 'Importar',
                  icon: Icons.file_upload,
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementOptions(BuildContext context, MigrationViewModel viewModel) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestión de Datos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: () => _showClearDataDialog(viewModel),
            text: 'Limpiar Datos Locales',
            icon: Icons.delete_forever,
            backgroundColor: Colors.red,
          ),
          const SizedBox(height: 12),
          CustomButton(
            onPressed: () => _verifyMigration(viewModel),
            text: 'Verificar Migración',
            icon: Icons.verified,
            backgroundColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  String _formatLabel(String label) {
    switch (label) {
      case 'categories':
        return 'Categorías';
      case 'products':
        return 'Productos';
      case 'sales':
        return 'Ventas';
      case 'movements':
        return 'Movimientos';
      default:
        return label;
    }
  }

  Future<void> _migrateAllData(MigrationViewModel viewModel) async {
    try {
      await viewModel.migrateAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.getMigrationSummary()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en la migración: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSelectiveMigrationDialog(MigrationViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Migración Selectiva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categorías'),
              subtitle: Text('${viewModel.firebaseStats['categories'] ?? 0} elementos'),
              onTap: () {
                Navigator.pop(context);
                _migrateSpecificData(viewModel, 'categories');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Productos'),
              subtitle: Text('${viewModel.firebaseStats['products'] ?? 0} elementos'),
              onTap: () {
                Navigator.pop(context);
                _migrateSpecificData(viewModel, 'products');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Ventas'),
              subtitle: Text('${viewModel.firebaseStats['sales'] ?? 0} elementos'),
              onTap: () {
                Navigator.pop(context);
                _migrateSpecificData(viewModel, 'sales');
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Movimientos'),
              subtitle: Text('${viewModel.firebaseStats['movements'] ?? 0} elementos'),
              onTap: () {
                Navigator.pop(context);
                _migrateSpecificData(viewModel, 'movements');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _migrateSpecificData(MigrationViewModel viewModel, String collection) async {
    try {
      await viewModel.migrateSpecificData(collection);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Migración de $_formatLabel(collection) completada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en la migración: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportData(MigrationViewModel viewModel) async {
    try {
      final data = await viewModel.exportLocalData();
      // Aquí podrías implementar la descarga del archivo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos exportados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en la exportación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importData(MigrationViewModel viewModel) async {
    // Aquí podrías implementar la selección de archivo
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Función de importación en desarrollo'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showClearDataDialog(MigrationViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Datos Locales'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todos los datos almacenados localmente? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearLocalData(viewModel);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearLocalData(MigrationViewModel viewModel) async {
    try {
      await viewModel.clearLocalData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos locales eliminados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verifyMigration(MigrationViewModel viewModel) async {
    try {
      final results = await viewModel.verifyMigration();
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Verificación de Migración'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: results.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      entry.value ? Icons.check_circle : Icons.error,
                      color: entry.value ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(_formatLabel(entry.key)),
                  ],
                ),
              )).toList(),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en la verificación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 