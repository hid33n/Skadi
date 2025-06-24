# Escáner de Códigos de Barras - Stockcito PM

## 📱 Funcionalidad de Escaneo Móvil

Esta funcionalidad permite a los usuarios de dispositivos móviles escanear códigos de barras para agregar productos rápidamente a su inventario. **Solo está disponible en dispositivos móviles**, no en la versión web.

## 🚀 Características

### ✅ Funcionalidades Implementadas

- **Escaneo en tiempo real**: Usa la cámara del dispositivo para escanear códigos de barras
- **Detección automática**: Identifica productos existentes o crea nuevos
- **Integración con APIs**: Obtiene información de productos desde bases de datos externas
- **Sincronización híbrida**: Los productos se guardan localmente y se sincronizan con Firebase
- **UI responsiva**: Interfaz optimizada para dispositivos móviles
- **Permisos automáticos**: Solicita permisos de cámara automáticamente

### 📍 Ubicaciones del Botón de Escaneo

1. **Dashboard**: Widget de acción rápida (solo móvil)
2. **Agregar Producto**: Botón prominente en la parte superior
3. **Nueva Venta**: Botón junto al campo de búsqueda

## 🔧 Configuración Técnica

### Dependencias Agregadas

```yaml
# Escaneo de códigos de barras (solo para móvil)
camera: ^0.10.5+9
mobile_scanner: ^3.5.6
permission_handler: ^11.1.0
```

### Archivos Creados/Modificados

#### Nuevos Archivos:
- `lib/services/barcode_scanner_service.dart` - Servicio principal de escaneo
- `lib/screens/barcode_scanner_screen.dart` - Pantalla de escaneo
- `lib/widgets/dashboard/barcode_quick_action.dart` - Widget de acción rápida

#### Archivos Modificados:
- `lib/screens/add_product_screen.dart` - Agregado botón de escaneo
- `lib/screens/add_sale_screen.dart` - Agregado botón de escaneo
- `lib/widgets/dashboard/quick_actions.dart` - Integrado widget de escaneo
- `lib/main.dart` - Agregadas rutas y providers

## 🎯 Flujo de Uso

### 1. Escaneo de Producto Nuevo
```
1. Usuario presiona "Escanear Código de Barras"
2. Se solicita permiso de cámara
3. Usuario escanea el código
4. Sistema busca información en APIs externas
5. Se muestra formulario con datos pre-llenados
6. Usuario completa información faltante
7. Producto se guarda en base de datos local
8. Se sincroniza automáticamente con Firebase
```

### 2. Escaneo de Producto Existente
```
1. Usuario presiona "Escanear Código de Barras"
2. Se solicita permiso de cámara
3. Usuario escanea el código
4. Sistema encuentra producto existente
5. Se muestra información del producto
6. Usuario puede seleccionarlo para venta/edición
```

## 🌐 APIs Externas Utilizadas

### OpenFoodFacts (Gratuito)
- **URL**: `https://world.openfoodfacts.org/api/v0/product/{barcode}.json`
- **Propósito**: Obtener información básica de productos
- **Datos**: Nombre, descripción, marca, imagen, categoría

### Fallback Local
Si no se encuentra información externa, se crea un producto básico con:
- Nombre: "Producto - {código}"
- Descripción: "Producto escaneado con código de barras: {código}"
- Precio: 0.0 (requiere edición manual)
- Stock: 0 (requiere edición manual)

## 🔄 Sincronización

### Flujo de Sincronización
1. **Producto creado localmente** → Se guarda en SQLite
2. **Sincronización automática** → Se envía a Firebase
3. **Disponibilidad multi-dispositivo** → Otros dispositivos reciben el producto
4. **Trabajo offline** → Funciona sin conexión a internet

### Estructura en Firebase
```json
{
  "pm": {
    "userId": {
      "products": {
        "productId": {
          "name": "Nombre del producto",
          "description": "Descripción",
          "price": 100.0,
          "stock": 10,
          "barcode": "1234567890123",
          "categoryId": "categoryId",
          "createdAt": "2024-01-01T00:00:00Z",
          "updatedAt": "2024-01-01T00:00:00Z"
        }
      }
    }
  }
}
```

## 🎨 UI/UX

### Diseño Responsivo
- **Móvil**: Botón prominente con icono de escáner
- **Tablet/Desktop**: No se muestra (no disponible)

### Estados de la UI
- **Cargando**: Indicador de progreso durante escaneo
- **Procesando**: Overlay con mensaje "Procesando código..."
- **Éxito**: SnackBar verde con confirmación
- **Error**: SnackBar rojo con mensaje de error

### Colores y Estilos
- **Botón principal**: Naranja (`Colors.orange`)
- **Icono**: `Icons.qr_code_scanner`
- **Bordes redondeados**: 12px radius
- **Elevación**: 4px para cards

## 🔒 Permisos

### Android
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS
```xml
<key>NSCameraUsageDescription</key>
<string>Esta app necesita acceso a la cámara para escanear códigos de barras</string>
```

## 🐛 Solución de Problemas

### Problemas Comunes

1. **"No se requieren permisos de cámara"**
   - Verificar que la app tenga permisos de cámara
   - Reiniciar la app después de otorgar permisos

2. **"Error al inicializar la cámara"**
   - Verificar que el dispositivo tenga cámara
   - Reiniciar el dispositivo

3. **"Producto no encontrado"**
   - El código de barras no existe en la base de datos externa
   - Se creará un producto básico para completar manualmente

4. **"Error de sincronización"**
   - Verificar conexión a internet
   - Los cambios se guardan localmente y se sincronizan cuando hay conexión

### Logs de Debug
```dart
// Habilitar logs detallados
print('Escaneando código: $barcode');
print('Información obtenida: $productInfo');
print('Producto creado: ${product.name}');
```

## 🚀 Próximas Mejoras

### Funcionalidades Planificadas
- [ ] Escaneo de códigos QR
- [ ] Historial de productos escaneados
- [ ] Búsqueda por imagen del producto
- [ ] Integración con más APIs de productos
- [ ] Escaneo de múltiples códigos simultáneamente

### Optimizaciones
- [ ] Cache de productos escaneados
- [ ] Compresión de imágenes
- [ ] Escaneo más rápido
- [ ] Mejor detección en condiciones de poca luz

## 📞 Soporte

Para reportar problemas o solicitar nuevas funcionalidades:
- Crear un issue en el repositorio
- Incluir información del dispositivo y versión de la app
- Adjuntar logs de error si es posible

---

**Desarrollado para Stockcito PM - Casa de Repuestos de Motos** 🏍️ 