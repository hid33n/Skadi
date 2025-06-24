import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/sync_viewmodel.dart';
import '../viewmodels/migration_viewmodel.dart';
import '../services/hybrid_data_service.dart';
import '../services/hive_database_service.dart';
import '../config/app_config.dart';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../viewmodels/product_viewmodel.dart';
import '../models/product.dart';

class AppInitializer extends StatefulWidget {
  final Widget child;

  const AppInitializer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  String _initializationStatus = 'Inicializando...';

  // Variables para el listener global
  String _barcodeBuffer = '';
  DateTime? _lastKeyTime;
  static const Duration _barcodeTimeout = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _initializeServices();
    // Listener global solo en web/PC
    if (kIsWeb) {
      html.window.addEventListener('keydown', _onKeyDown);
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      html.window.removeEventListener('keydown', _onKeyDown);
    }
    super.dispose();
  }

  void _onKeyDown(html.Event event) {
    if (event is! html.KeyboardEvent) return;
    // Ignorar si hay un TextField enfocado
    if (html.document.activeElement?.tagName == 'INPUT' || html.document.activeElement?.tagName == 'TEXTAREA') {
      return;
    }
    final now = DateTime.now();
    if (_lastKeyTime == null || now.difference(_lastKeyTime!) > _barcodeTimeout) {
      _barcodeBuffer = '';
    }
    _lastKeyTime = now;
    if (event.key == 'Enter') {
      final code = _barcodeBuffer.trim();
      _barcodeBuffer = '';
      if (code.isNotEmpty) {
        _onBarcodeScanned(code);
      }
    } else if (event.key != null && event.key!.length == 1) {
      _barcodeBuffer += event.key!;
    }
  }

  void _onBarcodeScanned(String code) async {
    final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
    final existingProducts = productViewModel.products;
    Product? product;
    try {
      product = existingProducts.firstWhere(
        (p) => p.barcode == code,
        orElse: () => null as Product,
      );
    } catch (_) {
      product = null;
    }
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Código escaneado: $code'),
          content: product != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Producto: ${product.name}'),
                    Text('Precio: ${product.price}'),
                    Text('Stock: ${product.stock}'),
                  ],
                )
              : const Text('Producto no registrado. ¿Qué deseas hacer?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí puedes navegar a la pantalla de agregar producto con el código
                Navigator.of(context).pushNamed('/add-product', arguments: code);
              },
              child: const Text('Agregar producto'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí puedes navegar a la pantalla de editar producto
                if (product != null) {
                  Navigator.of(context).pushNamed('/add-product', arguments: product);
                } else {
                  Navigator.of(context).pushNamed('/add-product', arguments: code);
                }
              },
              child: const Text('Editar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí puedes navegar a la pantalla de registrar venta
                if (product != null) {
                  Navigator.of(context).pushNamed('/add-sale', arguments: product);
                } else {
                  Navigator.of(context).pushNamed('/add-sale', arguments: code);
                }
              },
              child: const Text('Registrar venta'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initializeServices() async {
    try {
      print('AppInitializer: Inicializando base de datos local...');
      setState(() {
        _initializationStatus = 'Inicializando base de datos local...';
      });

      // Inicializar Hive
      final hiveService = context.read<HiveDatabaseService>();
      await hiveService.initialize();
      print('AppInitializer: Hive inicializado correctamente');

      setState(() {
        _initializationStatus = 'Configurando sincronización...';
      });
      print('AppInitializer: Configurando sincronización...');

      // Inicializar sincronización
      await AppConfig.initializeSync(context);
      print('AppInitializer: Sincronización configurada correctamente');

      setState(() {
        _initializationStatus = 'Inicializando servicios híbridos...';
      });
      print('AppInitializer: Inicializando servicios híbridos...');

      // Inicializar servicio híbrido
      final hybridService = context.read<HybridDataService>();
      await hybridService.initialize();
      print('AppInitializer: Servicio híbrido inicializado correctamente');

      setState(() {
        _initializationStatus = 'Verificando datos...';
      });

      // Verificar si hay datos para migrar
      final migrationViewModel = context.read<MigrationViewModel>();
      await migrationViewModel.checkFirebaseData();
      print('AppInitializer: Verificación de datos completada');

      setState(() {
        _initializationStatus = 'Completado';
        _isInitialized = true;
      });

      print('✅ AppInitializer: Servicios inicializados correctamente');
    } catch (e, stack) {
      setState(() {
        _initializationStatus = 'Error: $e';
      });
      print('❌ AppInitializer: Error inicializando servicios: $e');
      print(stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                ),
                const SizedBox(height: 40),
                
                // Título
                Text(
                  'Stockcito',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Planeta Motos',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 60),
                
                // Indicador de progreso
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 20),
                
                // Estado de inicialización
                Text(
                  _initializationStatus,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Información de la app
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.yellow.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Configuración Híbrida con Hive',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Base de datos local Hive\n• Funcionamiento offline\n• Sincronización automática\n• Múltiples dispositivos',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}

/// Widget para mostrar el estado de sincronización en cualquier pantalla
class SyncStatusIndicator extends StatelessWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const SyncStatusIndicator({
    Key? key,
    this.showDetails = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncViewModel>(
      builder: (context, syncViewModel, child) {
        return GestureDetector(
          onTap: onTap ?? () {
            _showSyncDetails(context, syncViewModel);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(syncViewModel.getSyncStatusColor()).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(syncViewModel.getSyncStatusColor()).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  syncViewModel.getSyncStatusIcon(),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 6),
                Text(
                  syncViewModel.getSyncStatusText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(syncViewModel.getSyncStatusColor()),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (showDetails && syncViewModel.pendingChangesCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(syncViewModel.getSyncStatusColor()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      syncViewModel.pendingChangesCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSyncDetails(BuildContext context, SyncViewModel syncViewModel) {
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
            Text('Estado: ${syncViewModel.getSyncStatusText()}'),
            const SizedBox(height: 8),
            if (syncViewModel.pendingChangesCount > 0) ...[
              Text('Cambios pendientes: ${syncViewModel.pendingChangesCount}'),
              const SizedBox(height: 4),
              Text('Detalles: ${syncViewModel.getPendingChangesSummary()}'),
              const SizedBox(height: 8),
            ],
            if (syncViewModel.lastSyncTime != null) ...[
              Text('Última sincronización: ${_formatDateTime(syncViewModel.lastSyncTime!)}'),
              const SizedBox(height: 8),
            ],
            Text('Recomendación: ${syncViewModel.getSyncRecommendations()}'),
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