class ApiConfig {
  // APIs gratuitas para datos de motos y repuestos
  
  // NHTSA Vehicle API (gratuita, sin límites)
  static const String nhtsaBaseUrl = 'https://api.nhtsa.gov/vehicles';
  
  // APIs de repuestos (simuladas - en producción usarías APIs reales)
  static const String partsApiBase = 'https://api.parts.com/api';
  static const String openMotoApi = 'https://api.openmoto.com';
  
  // APIs de precios de referencia
  static const String priceApiBase = 'https://api.prices.com';
  
  // Configuración de timeouts
  static const int connectionTimeout = 10000; // 10 segundos
  static const int receiveTimeout = 15000; // 15 segundos
  
  // Headers comunes
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Stockcito/1.0',
  };
  
  // Endpoints específicos
  static const Map<String, String> endpoints = {
    'motorcycle_models': '/GetModelsForMake',
    'motorcycle_makes': '/GetAllMakes',
    'vehicle_details': '/GetVehicleTypesForMake',
    'parts_catalog': '/catalog',
    'price_reference': '/prices',
    'compatibility': '/compatibility',
  };
  
  // Categorías de repuestos predefinidas
  static const List<Map<String, dynamic>> predefinedCategories = [
    {
      'id': 'frenos',
      'name': 'Sistema de Frenos',
      'description': 'Pastillas, discos, líneas de freno',
      'color': '#FF4444',
    },
    {
      'id': 'motor',
      'name': 'Motor',
      'description': 'Bujías, filtros, aceites',
      'color': '#FF8800',
    },
    {
      'id': 'transmision',
      'name': 'Transmisión',
      'description': 'Cadena, piñones, embrague',
      'color': '#FFCC00',
    },
    {
      'id': 'suspension',
      'name': 'Suspensión',
      'description': 'Amortiguadores, resortes',
      'color': '#00CC00',
    },
    {
      'id': 'electricidad',
      'name': 'Sistema Eléctrico',
      'description': 'Baterías, luces, cables',
      'color': '#0088FF',
    },
    {
      'id': 'neumaticos',
      'name': 'Neumáticos',
      'description': 'Cubiertas, cámaras',
      'color': '#8800FF',
    },
    {
      'id': 'carroceria',
      'name': 'Carrocería',
      'description': 'Espejos, carenados, asientos',
      'color': '#FF0088',
    },
    {
      'id': 'herramientas',
      'name': 'Herramientas',
      'description': 'Herramientas de mantenimiento',
      'color': '#888888',
    },
  ];
  
  // Marcas de motos populares
  static const List<String> popularMakes = [
    'Honda',
    'Yamaha',
    'Kawasaki',
    'Suzuki',
    'KTM',
    'BMW',
    'Ducati',
    'Harley-Davidson',
    'Triumph',
    'Aprilia',
  ];
  
  // Modelos populares por marca
  static const Map<String, List<String>> popularModels = {
    'Honda': [
      'CBR600RR',
      'CBR1000RR',
      'CB650R',
      'CB1000R',
      'CRF450R',
      'CRF250R',
      'Grom',
      'Monkey',
    ],
    'Yamaha': [
      'R1',
      'R6',
      'MT-07',
      'MT-09',
      'YZF-R3',
      'Tracer 900',
      'XSR700',
      'TMAX',
    ],
    'Kawasaki': [
      'Ninja 650',
      'Ninja ZX-6R',
      'Ninja ZX-10R',
      'Z650',
      'Z900',
      'Versys 650',
      'Vulcan S',
      'KLX450R',
    ],
    'Suzuki': [
      'GSX-R600',
      'GSX-R750',
      'GSX-R1000',
      'SV650',
      'V-Strom 650',
      'Hayabusa',
      'RM-Z450',
      'DR-Z400',
    ],
  };
  
  // Configuración de caché
  static const int cacheExpirationHours = 24; // 24 horas
  static const int maxCacheSize = 100; // Máximo 100 items en caché
  
  // Configuración de búsqueda
  static const int maxSearchResults = 50;
  static const int searchDebounceMs = 300; // 300ms de debounce
  
  // Configuración de sincronización
  static const bool enableAutoSync = false; // Deshabilitado por defecto
  static const int syncIntervalHours = 24; // Sincronizar cada 24 horas
  
  // Configuración de backup
  static const bool enableAutoBackup = true;
  static const int backupIntervalDays = 7; // Backup semanal
  static const int maxBackupFiles = 5; // Mantener 5 backups
  
  // Configuración de notificaciones
  static const bool enableLowStockAlerts = true;
  static const int lowStockThreshold = 3; // Alertar cuando queden 3 o menos
  
  // Configuración de reportes
  static const List<String> availableReports = [
    'ventas_diarias',
    'ventas_semanales',
    'ventas_mensuales',
    'stock_bajo',
    'productos_mas_vendidos',
    'movimientos_stock',
    'ganancias',
  ];
  
  // Configuración de exportación
  static const List<String> exportFormats = [
    'json',
    'csv',
    'pdf',
    'excel',
  ];
  
  // Configuración de importación
  static const List<String> importFormats = [
    'json',
    'csv',
    'excel',
  ];
  
  // Límites de la aplicación
  static const int maxProducts = 10000;
  static const int maxCategories = 100;
  static const int maxSales = 50000;
  static const int maxMovements = 100000;
  
  // Configuración de rendimiento
  static const int batchSize = 100; // Procesar en lotes de 100
  static const bool enableLazyLoading = true;
  static const int lazyLoadingThreshold = 50; // Cargar más después de 50 items
} 