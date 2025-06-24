# Assets

Esta carpeta contiene todos los recursos estáticos de la aplicación PM-Skadi.

## Estructura

```
assets/
├── images/          # Imágenes de la aplicación (logos, banners, etc.)
├── icons/           # Iconos personalizados
└── README.md        # Este archivo
```

## Uso

### Imágenes
- Coloca aquí todas las imágenes que uses en la aplicación
- Formatos recomendados: PNG, JPG, SVG
- Para el logo de la aplicación, usa el nombre `logo.png` o `logo.svg`

### Iconos
- Iconos personalizados que no están en Material Icons
- Formatos recomendados: SVG, PNG

## Configuración

Los assets están configurados en `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
```

## Convenciones de nomenclatura

- Usa nombres descriptivos en minúsculas con guiones bajos
- Ejemplo: `company_logo.png`, `dashboard_banner.jpg`
- Para el logo principal: `logo.png` o `logo.svg` 