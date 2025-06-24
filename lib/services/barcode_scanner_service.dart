import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import '../utils/error_handler.dart';

class BarcodeScannerService {
  static const String _apiUrl = 'https://world.openfoodfacts.org/api/v0/product/';
  
  /// Verificar permisos de cámara
  Future<bool> requestCameraPermission() async {
    if (kIsWeb) return true; // En web, el navegador gestiona el permiso
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Escanear código de barras
  Future<String?> scanBarcode() async {
    if (kIsWeb) {
      throw AppError(
        message: 'El escaneo de códigos de barras no está disponible en la versión web',
        type: ErrorType.permission,
      );
    }

    final hasPermission = await requestCameraPermission();
    if (!hasPermission) {
      throw AppError(
        message: 'Se requieren permisos de cámara para escanear códigos de barras',
        type: ErrorType.permission,
      );
    }

    // Retornar null para indicar que se necesita abrir el scanner
    // El resultado se manejará en la UI
    return null;
  }

  /// Obtener información del producto desde API externa usando el código de barras
  Future<Map<String, dynamic>?> getProductInfoFromBarcode(String barcode) async {
    try {
      // Intentar obtener información desde OpenFoodFacts (gratuito)
      final response = await http.get(
        Uri.parse('$_apiUrl$barcode.json'),
        headers: {'User-Agent': 'Stockcito-PM/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 1 && data['product'] != null) {
          final product = data['product'];
          
          return {
            'name': product['product_name'] ?? product['generic_name'] ?? 'Producto sin nombre',
            'description': product['generic_name'] ?? product['product_name'] ?? '',
            'brand': product['brands'] ?? '',
            'image_url': product['image_url'] ?? product['image_front_url'] ?? '',
            'barcode': barcode,
            'suggested_price': _extractPrice(product),
            'category': _extractCategory(product),
            'attributes': {
              'ingredients': product['ingredients_text'] ?? '',
              'nutrition_grade': product['nutrition_grade_fr'] ?? '',
              'allergens': product['allergens_tags'] ?? [],
            }
          };
        }
      }

      // Si no se encuentra en OpenFoodFacts, crear producto básico
      return {
        'name': 'Producto - $barcode',
        'description': 'Producto escaneado con código de barras: $barcode',
        'barcode': barcode,
        'suggested_price': 0.0,
        'category': 'Sin categorizar',
        'attributes': {
          'scanned_at': DateTime.now().toIso8601String(),
          'source': 'manual_scan'
        }
      };

    } catch (e) {
      // En caso de error, crear producto básico
      return {
        'name': 'Producto - $barcode',
        'description': 'Producto escaneado con código de barras: $barcode',
        'barcode': barcode,
        'suggested_price': 0.0,
        'category': 'Sin categorizar',
        'attributes': {
          'scanned_at': DateTime.now().toIso8601String(),
          'source': 'manual_scan',
          'error': e.toString()
        }
      };
    }
  }

  /// Extraer precio sugerido del producto
  double _extractPrice(Map<String, dynamic> product) {
    try {
      // Intentar extraer precio de diferentes campos
      final priceStr = product['price'] ?? 
                      product['prices']?['price'] ?? 
                      product['prices']?['current_price'] ?? 
                      '0';
      
      return double.tryParse(priceStr.toString().replaceAll(RegExp(r'[^\d.,]'), '')) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Extraer categoría del producto
  String _extractCategory(Map<String, dynamic> product) {
    try {
      final categories = product['categories_tags'] ?? [];
      if (categories.isNotEmpty) {
        // Buscar categorías relacionadas con motos/repuestos
        final motoCategories = categories.where((cat) => 
          cat.toString().toLowerCase().contains('motorcycle') ||
          cat.toString().toLowerCase().contains('auto') ||
          cat.toString().toLowerCase().contains('vehicle')
        ).toList();
        
        if (motoCategories.isNotEmpty) {
          return motoCategories.first.toString().split(':').last.replaceAll('_', ' ').toUpperCase();
        }
        
        return categories.first.toString().split(':').last.replaceAll('_', ' ').toUpperCase();
      }
      
      return 'Sin categorizar';
    } catch (e) {
      return 'Sin categorizar';
    }
  }

  /// Crear producto desde código de barras escaneado
  Product createProductFromBarcode(String barcode, Map<String, dynamic> productInfo, String categoryId) {
    return Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: productInfo['name'] ?? 'Producto - $barcode',
      description: productInfo['description'] ?? 'Producto escaneado con código de barras: $barcode',
      price: (productInfo['suggested_price'] as num?)?.toDouble() ?? 0.0,
      stock: 0, // Stock inicial en 0
      minStock: 5, // Stock mínimo por defecto
      maxStock: 100, // Stock máximo por defecto
      categoryId: categoryId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      barcode: barcode,
      imageUrl: productInfo['image_url'],
      attributes: productInfo['attributes'],
    );
  }

  /// Verificar si un código de barras ya existe en la base de datos
  Future<bool> isBarcodeExists(String barcode, List<Product> existingProducts) async {
    return existingProducts.any((product) => product.barcode == barcode);
  }

  /// Obtener producto existente por código de barras
  Product? getProductByBarcode(String barcode, List<Product> existingProducts) {
    try {
      return existingProducts.firstWhere((product) => product.barcode == barcode);
    } catch (e) {
      return null;
    }
  }
} 