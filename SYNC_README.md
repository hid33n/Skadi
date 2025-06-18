# Sistema de Sincronización y Cache Local

## Descripción General

Se ha implementado un sistema completo de sincronización y cache local para la aplicación de gestión de stock. Este sistema permite que la aplicación funcione offline y sincronice automáticamente los datos cuando hay conexión a internet.

## Arquitectura

### Componentes Principales

1. **LocalStorageService** (`lib/services/local_storage_service.dart`)
   - Maneja el almacenamiento local usando IndexedDB
   - Proporciona métodos CRUD para todos los modelos
   - Gestiona la cola de sincronización

2. **SyncService** (`lib/services/sync_service.dart`)
   - Coordina la sincronización entre local y remoto
   - Maneja la cola de cambios pendientes
   - Detecta cambios de conectividad
   - Proporciona streams para el estado de sincronización

3. **ViewModels Actualizados**
   - Todos los ViewModels ahora usan SyncService en lugar de servicios directos
   - Manejo automático de cache local y sincronización

4. **Widgets de UI** (`lib/widgets/sync_status_widget.dart`)
   - `SyncStatusWidget`: Muestra el estado de sincronización
   - `SyncProgressWidget`: Muestra el progreso de sincronización
   - `SyncOfflineIndicator`: Indica cuando no hay conexión

## Características

### ✅ Funcionalidades Implementadas

- **Cache Local Completo**: Todos los datos se almacenan localmente en IndexedDB
- **Sincronización Automática**: Los cambios se sincronizan automáticamente cuando hay conexión
- **Cola de Sincronización**: Los cambios offline se encolan y se procesan cuando hay conexión
- **Detección de Conectividad**: La app detecta automáticamente cambios en la conectividad
- **UI de Estado**: Widgets que muestran el estado de sincronización en tiempo real
- **Reintentos Automáticos**: Sistema de reintentos para operaciones fallidas
- **Estadísticas de Almacenamiento**: Métodos para obtener estadísticas del cache local

### 🔄 Flujo de Datos

1. **Operaciones CRUD**:
   - Los ViewModels llaman a SyncService
   - SyncService guarda inmediatamente en cache local
   - Se agrega la operación a la cola de sincronización
   - Si hay conexión, se sincroniza inmediatamente

2. **Sincronización**:
   - Se ejecuta automáticamente cada 5 minutos
   - Se ejecuta cuando se restaura la conectividad
   - Procesa la cola de cambios pendientes
   - Descarga cambios del servidor

3. **Manejo de Errores**:
   - Los errores de sincronización no afectan las operaciones locales
   - Se reintentan automáticamente las operaciones fallidas
   - Se muestran errores en la UI sin interrumpir la funcionalidad

## Uso en la Aplicación

### Inicialización

El sistema se inicializa automáticamente en `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Inicializar servicios de sincronización
  try {
    final syncService = SyncService();
    await syncService.initialize();
  } catch (e) {
    debugPrint('Error al inicializar sincronización: $e');
  }
  
  runApp(const MyApp());
}
```

### En ViewModels

Los ViewModels ahora usan SyncService automáticamente:

```dart
class ProductViewModel extends ChangeNotifier {
  final SyncService _syncService = SyncService();
  
  Future<void> loadProducts(String organizationId) async {
    // Usa cache local automáticamente
    _products = await _syncService.getProducts(organizationId);
  }
  
  Future<bool> addProduct(Product product) async {
    // Guarda localmente y sincroniza automáticamente
    final productId = await _syncService.createProduct(product);
    return productId.isNotEmpty;
  }
}
```

### En Pantallas

Las pantallas pueden mostrar el estado de sincronización:

```dart
class DashboardScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Widget de estado de sincronización
          SyncStatusWidget(syncService: _syncService),
        ],
      ),
      body: Column(
        children: [
          // Indicador de estado offline
          SyncOfflineIndicator(syncService: _syncService),
          
          // Progreso de sincronización
          SyncProgressWidget(syncService: _syncService),
          
          // Contenido principal
          DashboardGrid(),
        ],
      ),
    );
  }
}
```

## Estados de Sincronización

- **idle**: Sincronizado, sin cambios pendientes
- **syncing**: Sincronizando datos
- **error**: Error en la sincronización
- **completed**: Sincronización completada exitosamente

## Configuración

### Intervalo de Sincronización

El intervalo de sincronización automática se puede configurar en `SyncService`:

```dart
// En sync_service.dart, línea ~60
_syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
  if (_localStorage.isOnline) {
    syncData();
  }
});
```

### Tamaño de Cache

El cache local se almacena en IndexedDB y puede crecer según el uso. Se pueden obtener estadísticas:

```dart
final stats = await syncService.getStorageStats();
print('Productos en cache: ${stats['products']}');
print('Ventas en cache: ${stats['sales']}');
```

## Ventajas del Sistema

1. **Funcionamiento Offline**: La app funciona completamente sin conexión
2. **Experiencia Fluida**: Los usuarios no notan interrupciones por problemas de red
3. **Datos Siempre Disponibles**: Los datos se cargan instantáneamente desde cache local
4. **Sincronización Transparente**: Los usuarios no necesitan preocuparse por sincronizar manualmente
5. **Robustez**: El sistema maneja errores de red sin afectar la funcionalidad
6. **Escalabilidad**: El sistema puede manejar grandes cantidades de datos

## Próximos Pasos

### Mejoras Futuras

1. **Sincronización Selectiva**: Sincronizar solo datos modificados recientemente
2. **Compresión de Datos**: Comprimir datos para reducir el uso de almacenamiento
3. **Sincronización en Tiempo Real**: Usar WebSockets para sincronización instantánea
4. **Resolución de Conflictos**: Manejar conflictos cuando los mismos datos se modifican en múltiples dispositivos
5. **Backup Automático**: Crear copias de seguridad automáticas del cache local

### Optimizaciones

1. **Lazy Loading**: Cargar datos solo cuando se necesiten
2. **Paginación**: Implementar paginación para grandes conjuntos de datos
3. **Cache Inteligente**: Eliminar datos antiguos automáticamente
4. **Métricas**: Agregar métricas de rendimiento de sincronización

## Troubleshooting

### Problemas Comunes

1. **Error de inicialización de IndexedDB**:
   - Verificar que el navegador soporte IndexedDB
   - Limpiar datos del navegador si es necesario

2. **Sincronización no funciona**:
   - Verificar conectividad a internet
   - Revisar logs de errores en la consola
   - Verificar configuración de Firebase

3. **Datos no se actualizan**:
   - Forzar sincronización manual: `syncService.syncData()`
   - Verificar que los ViewModels estén usando SyncService

### Debugging

Para debuggear problemas de sincronización:

```dart
// Obtener estadísticas de almacenamiento
final stats = await syncService.getStorageStats();
print('Estadísticas de cache: $stats');

// Verificar conectividad
print('Online: ${syncService.isOnline}');

// Obtener elementos pendientes de sincronización
final pending = await syncService.getPendingSyncItems();
print('Elementos pendientes: ${pending.length}');
```

## Conclusión

El sistema de sincronización implementado proporciona una base sólida para una aplicación web robusta que funciona tanto online como offline. Los usuarios pueden trabajar sin interrupciones, y los datos se mantienen sincronizados automáticamente cuando hay conexión disponible. 