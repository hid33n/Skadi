# Migración de Base de Datos - PM-Skadi

## Cambio de Estructura de Datos

### Resumen
Esta versión personalizada de PM-Skadi utiliza una nueva colección llamada `pm` en lugar de `users` para mantener separados los datos de la aplicación original.

### Cambios Realizados

#### 1. **Nueva Estructura de Colecciones**
```
Antes (Skadi Original):
/users/{userId}/products
/users/{userId}/categories
/users/{userId}/sales
/users/{userId}/movements

Ahora (PM-Skadi):
/pm/{userId}/products
/pm/{userId}/categories
/pm/{userId}/sales
/pm/{userId}/movements
```

#### 2. **Servicios Actualizados**
- ✅ `FirestoreService` - Referencias principales de datos
- ✅ `AuthService` - Autenticación y perfiles de usuario
- ✅ `UserDataService` - Gestión de datos de usuario
- ✅ `UserService` - Operaciones CRUD de usuarios
- ✅ `OrganizationService` - Estadísticas de organización
- ✅ `MigrationService` - Migración de datos existentes
- ✅ Tests actualizados

#### 3. **Beneficios del Cambio**
- **Separación de Datos**: Los datos de PM-Skadi no interfieren con la aplicación original
- **Independencia**: Cada aplicación puede evolucionar por separado
- **Seguridad**: Aislamiento de datos entre versiones
- **Escalabilidad**: Mejor organización para futuras personalizaciones

### Estructura de Datos Actual

```
/pm/{userId}/
├── username: string
├── email: string
├── createdAt: timestamp
├── role: string
├── organizationId: string (opcional)
├── products/
│   └── {productId}/
│       ├── name: string
│       ├── description: string
│       ├── price: number
│       ├── stock: number
│       └── ...
├── categories/
│   └── {categoryId}/
│       ├── name: string
│       ├── description: string
│       └── ...
├── sales/
│   └── {saleId}/
│       ├── amount: number
│       ├── date: timestamp
│       ├── items: array
│       └── ...
├── movements/
│   └── {movementId}/
│       ├── type: string
│       ├── quantity: number
│       ├── date: timestamp
│       └── ...
└── profile/
    └── organization/
        ├── name: string
        ├── description: string
        └── ...
```

### Migración de Datos Existentes

Si necesitas migrar datos de la aplicación original a esta nueva estructura:

1. **Usar MigrationService**: El servicio ya está configurado para migrar desde la estructura antigua
2. **Backup**: Siempre hacer backup antes de migrar
3. **Verificación**: Verificar que todos los datos se migraron correctamente

### Configuración de Firebase

Asegúrate de que las reglas de seguridad de Firestore permitan acceso a la nueva colección `pm`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Reglas para la nueva colección pm
    match /pm/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Subcolecciones
      match /{collection}/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### Notas Importantes

- **Compatibilidad**: Esta versión no es compatible con la aplicación original
- **Migración**: Los usuarios existentes necesitarán crear nuevas cuentas
- **Datos**: No se comparten datos entre las dos versiones
- **Desarrollo**: Cada versión puede evolucionar independientemente

### Próximos Pasos

1. **Configurar Firebase**: Actualizar reglas de seguridad
2. **Probar Aplicación**: Verificar que todo funciona correctamente
3. **Migrar Datos** (opcional): Si es necesario migrar datos existentes
4. **Personalización**: Continuar con las personalizaciones específicas del cliente 