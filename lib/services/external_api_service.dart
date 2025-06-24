import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class ExternalApiService {
  final Dio _dio = Dio();
  
  // APIs gratuitas para datos de motos y repuestos
  static const String _motorcycleApiBase = 'https://api.nhtsa.gov/vehicles';
  static const String _partsApiBase = 'https://api.parts.com/api';
  static const String _openMotoApi = 'https://api.openmoto.com';

  /// Obtener información de motos por marca y modelo
  Future<Map<String, dynamic>?> getMotorcycleInfo({
    required String make,
    required String model,
    String? year,
  }) async {
    try {
      final response = await _dio.get(
        '$_motorcycleApiBase/GetModelsForMake/$make',
        queryParameters: {
          'format': 'json',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final results = data['Results'] as List;
        
        // Buscar el modelo específico
        final modelInfo = results.firstWhere(
          (item) => item['Model_Name'].toString().toLowerCase().contains(model.toLowerCase()),
          orElse: () => null,
        );

        if (modelInfo != null) {
          return {
            'make': make,
            'model': modelInfo['Model_Name'],
            'makeId': modelInfo['Make_ID'],
            'modelId': modelInfo['Model_ID'],
            'year': year,
          };
        }
      }
      return null;
    } catch (e) {
      print('Error obteniendo información de moto: $e');
      return null;
    }
  }

  /// Obtener catálogo de repuestos por categoría
  Future<List<Map<String, dynamic>>> getPartsCatalog({
    required String category,
    String? brand,
    String? model,
  }) async {
    try {
      // Simulación de catálogo de repuestos (en producción usarías APIs reales)
      final categories = {
        'frenos': [
          {
            'name': 'Pastillas de Freno Delanteras',
            'brand': 'Brembo',
            'compatibility': ['Honda', 'Yamaha', 'Kawasaki'],
            'price_range': {'min': 15.0, 'max': 45.0},
            'description': 'Pastillas de freno de alta calidad para motos',
          },
          {
            'name': 'Discos de Freno',
            'brand': 'Galfer',
            'compatibility': ['Honda', 'Yamaha', 'Suzuki'],
            'price_range': {'min': 80.0, 'max': 200.0},
            'description': 'Discos de freno ventilados',
          },
        ],
        'aceite': [
          {
            'name': 'Aceite de Motor 10W-40',
            'brand': 'Motul',
            'compatibility': ['Universal'],
            'price_range': {'min': 8.0, 'max': 15.0},
            'description': 'Aceite sintético para motos',
          },
          {
            'name': 'Aceite de Transmisión',
            'brand': 'Castrol',
            'compatibility': ['Universal'],
            'price_range': {'min': 12.0, 'max': 25.0},
            'description': 'Aceite específico para transmisión',
          },
        ],
        'filtros': [
          {
            'name': 'Filtro de Aire',
            'brand': 'K&N',
            'compatibility': ['Honda', 'Yamaha', 'Kawasaki', 'Suzuki'],
            'price_range': {'min': 25.0, 'max': 60.0},
            'description': 'Filtro de aire de alto rendimiento',
          },
          {
            'name': 'Filtro de Aceite',
            'brand': 'Hiflo',
            'compatibility': ['Universal'],
            'price_range': {'min': 5.0, 'max': 15.0},
            'description': 'Filtro de aceite estándar',
          },
        ],
        'neumaticos': [
          {
            'name': 'Neumático Delantero 120/70-17',
            'brand': 'Michelin',
            'compatibility': ['Sport', 'Naked'],
            'price_range': {'min': 80.0, 'max': 150.0},
            'description': 'Neumático deportivo',
          },
          {
            'name': 'Neumático Trasero 180/55-17',
            'brand': 'Pirelli',
            'compatibility': ['Sport', 'Naked'],
            'price_range': {'min': 120.0, 'max': 200.0},
            'description': 'Neumático trasero de alto rendimiento',
          },
        ],
        'baterias': [
          {
            'name': 'Batería 12V 7Ah',
            'brand': 'Yuasa',
            'compatibility': ['Universal'],
            'price_range': {'min': 40.0, 'max': 80.0},
            'description': 'Batería de gel sellada',
          },
          {
            'name': 'Batería 12V 10Ah',
            'brand': 'MotoBatt',
            'compatibility': ['Universal'],
            'price_range': {'min': 60.0, 'max': 120.0},
            'description': 'Batería de litio',
          },
        ],
      };

      final catalog = categories[category.toLowerCase()] ?? [];
      
      // Filtrar por marca si se especifica
      if (brand != null) {
        return catalog.where((part) {
          final compat = part['compatibility'] as List;
          return compat.any((c) => c.toString().toLowerCase().contains(brand.toLowerCase()));
        }).toList();
      }

      return catalog;
    } catch (e) {
      print('Error obteniendo catálogo de repuestos: $e');
      return [];
    }
  }

  /// Obtener precios de referencia de repuestos
  Future<Map<String, dynamic>> getReferencePrices({
    required String partName,
    String? brand,
  }) async {
    try {
      // Simulación de precios de referencia
      final priceData = {
        'Pastillas de Freno Delanteras': {
          'min_price': 12.0,
          'max_price': 50.0,
          'avg_price': 25.0,
          'currency': 'USD',
          'last_updated': DateTime.now().toIso8601String(),
        },
        'Aceite de Motor 10W-40': {
          'min_price': 6.0,
          'max_price': 18.0,
          'avg_price': 12.0,
          'currency': 'USD',
          'last_updated': DateTime.now().toIso8601String(),
        },
        'Filtro de Aire': {
          'min_price': 20.0,
          'max_price': 70.0,
          'avg_price': 35.0,
          'currency': 'USD',
          'last_updated': DateTime.now().toIso8601String(),
        },
      };

      return priceData[partName] ?? {
        'min_price': 0.0,
        'max_price': 0.0,
        'avg_price': 0.0,
        'currency': 'USD',
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error obteniendo precios de referencia: $e');
      return {};
    }
  }

  /// Buscar repuestos por compatibilidad
  Future<List<Map<String, dynamic>>> searchPartsByCompatibility({
    required String motorcycleMake,
    required String motorcycleModel,
    String? year,
    String? category,
  }) async {
    try {
      // Simulación de búsqueda por compatibilidad
      final compatibleParts = [
        {
          'name': 'Pastillas de Freno Delanteras',
          'brand': 'Brembo',
          'compatibility': ['$motorcycleMake $motorcycleModel'],
          'price': 25.0,
          'category': 'frenos',
          'stock_available': true,
        },
        {
          'name': 'Aceite de Motor 10W-40',
          'brand': 'Motul',
          'compatibility': ['Universal'],
          'price': 12.0,
          'category': 'aceite',
          'stock_available': true,
        },
        {
          'name': 'Filtro de Aire',
          'brand': 'K&N',
          'compatibility': ['$motorcycleMake $motorcycleModel'],
          'price': 35.0,
          'category': 'filtros',
          'stock_available': false,
        },
      ];

      if (category != null) {
        return compatibleParts
            .where((part) => part['category'] == category.toLowerCase())
            .toList();
      }

      return compatibleParts;
    } catch (e) {
      print('Error buscando repuestos por compatibilidad: $e');
      return [];
    }
  }

  /// Obtener información técnica de motos
  Future<Map<String, dynamic>?> getMotorcycleSpecs({
    required String make,
    required String model,
    String? year,
  }) async {
    try {
      // Simulación de especificaciones técnicas
      final specs = {
        'Honda CBR600RR': {
          'engine': '599cc Inline-4',
          'power': '118 hp',
          'torque': '66 Nm',
          'weight': '194 kg',
          'fuel_capacity': '18.5L',
          'transmission': '6-speed',
          'brakes': 'Dual disc front, Single disc rear',
        },
        'Yamaha R6': {
          'engine': '599cc Inline-4',
          'power': '116 hp',
          'torque': '61 Nm',
          'weight': '190 kg',
          'fuel_capacity': '16L',
          'transmission': '6-speed',
          'brakes': 'Dual disc front, Single disc rear',
        },
        'Kawasaki Ninja 650': {
          'engine': '649cc Parallel-twin',
          'power': '67 hp',
          'torque': '64 Nm',
          'weight': '193 kg',
          'fuel_capacity': '15L',
          'transmission': '6-speed',
          'brakes': 'Dual disc front, Single disc rear',
        },
      };

      final key = '$make $model';
      return specs[key];
    } catch (e) {
      print('Error obteniendo especificaciones: $e');
      return null;
    }
  }

  /// Obtener códigos de repuestos OEM
  Future<List<Map<String, dynamic>>> getOEMParts({
    required String make,
    required String model,
    String? category,
  }) async {
    try {
      // Simulación de códigos OEM
      final oemParts = [
        {
          'oem_code': 'HON-12345',
          'name': 'Pastillas de Freno Delanteras',
          'brand': make,
          'model': model,
          'category': 'frenos',
          'price': 45.0,
        },
        {
          'oem_code': 'HON-67890',
          'name': 'Filtro de Aceite',
          'brand': make,
          'model': model,
          'category': 'filtros',
          'price': 12.0,
        },
        {
          'oem_code': 'HON-11111',
          'name': 'Bujía',
          'brand': make,
          'model': model,
          'category': 'motor',
          'price': 8.0,
        },
      ];

      if (category != null) {
        return oemParts
            .where((part) => part['category'] == category.toLowerCase())
            .toList();
      }

      return oemParts;
    } catch (e) {
      print('Error obteniendo códigos OEM: $e');
      return [];
    }
  }
} 