import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_hive.dart';
import '../models/category_hive.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/sale.dart';
import '../models/movement.dart';

class HiveDatabaseService {
  static const String _productsBoxName = 'products';
  static const String _categoriesBoxName = 'categories';
  static const String _salesBoxName = 'sales';
  static const String _movementsBoxName = 'movements';
  
  late Box<ProductHive> _productsBox;
  late Box<CategoryHive> _categoriesBox;
  late Box _salesBox;
  late Box _movementsBox;
  
  bool _isInitialized = false;

  /// Inicializar Hive y abrir las cajas
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Inicializar Hive
    await Hive.initFlutter();
    
    // Registrar adaptadores
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryHiveAdapter());
    }

    // Abrir cajas
    _productsBox = await Hive.openBox<ProductHive>(_productsBoxName);
    _categoriesBox = await Hive.openBox<CategoryHive>(_categoriesBoxName);
    _salesBox = await Hive.openBox(_salesBoxName);
    _movementsBox = await Hive.openBox(_movementsBoxName);

    _isInitialized = true;
  }

  /// Cerrar todas las cajas
  Future<void> close() async {
    await _productsBox.close();
    await _categoriesBox.close();
    await _salesBox.close();
    await _movementsBox.close();
    _isInitialized = false;
  }

  // ===== PRODUCTOS =====

  /// Obtener todos los productos
  Future<List<Product>> getAllProducts() async {
    await _ensureInitialized();
    
    final products = _productsBox.values.toList();
    return products.map((productHive) => Product.fromMap(
      productHive.toProductMap(),
      productHive.id,
    )).toList();
  }

  /// Obtener producto por ID
  Future<Product?> getProductById(String id) async {
    await _ensureInitialized();
    
    final productHive = _productsBox.values.where(
      (product) => product.id == id,
    ).firstOrNull;
    
    if (productHive == null) return null;
    
    return Product.fromMap(productHive.toProductMap(), productHive.id);
  }

  /// Obtener producto por código de barras
  Future<Product?> getProductByBarcode(String barcode) async {
    await _ensureInitialized();
    
    final productHive = _productsBox.values.where(
      (product) => product.barcode == barcode,
    ).firstOrNull;
    
    if (productHive == null) return null;
    
    return Product.fromMap(productHive.toProductMap(), productHive.id);
  }

  /// Insertar producto
  Future<void> insertProduct(Product product) async {
    await _ensureInitialized();
    
    final productHive = ProductHive.fromProduct(product);
    await _productsBox.put(product.id, productHive);
  }

  /// Actualizar producto
  Future<void> updateProduct(Product product) async {
    await _ensureInitialized();
    
    final productHive = ProductHive.fromProduct(product);
    await _productsBox.put(product.id, productHive);
  }

  /// Eliminar producto
  Future<void> deleteProduct(String id) async {
    await _ensureInitialized();
    
    await _productsBox.delete(id);
  }

  /// Obtener productos con stock bajo
  Future<List<Product>> getLowStockProducts() async {
    await _ensureInitialized();
    
    final products = _productsBox.values.where(
      (product) => product.stock <= product.minStock,
    ).toList();
    
    return products.map((productHive) => Product.fromMap(
      productHive.toProductMap(),
      productHive.id,
    )).toList();
  }

  /// Buscar productos por nombre o descripción
  Future<List<Product>> searchProducts(String query) async {
    await _ensureInitialized();
    
    final lowercaseQuery = query.toLowerCase();
    final products = _productsBox.values.where((product) =>
      product.name.toLowerCase().contains(lowercaseQuery) ||
      product.description.toLowerCase().contains(lowercaseQuery) ||
      (product.barcode?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
    
    return products.map((productHive) => Product.fromMap(
      productHive.toProductMap(),
      productHive.id,
    )).toList();
  }

  // ===== CATEGORÍAS =====

  /// Obtener todas las categorías
  Future<List<Category>> getAllCategories() async {
    await _ensureInitialized();
    
    final categories = _categoriesBox.values.toList();
    return categories.map((categoryHive) => Category.fromMap(
      categoryHive.toCategoryMap(),
      categoryHive.id,
    )).toList();
  }

  /// Obtener categoría por ID
  Future<Category?> getCategoryById(String id) async {
    await _ensureInitialized();
    
    final categoryHive = _categoriesBox.values.where(
      (category) => category.id == id,
    ).firstOrNull;
    
    if (categoryHive == null) return null;
    
    return Category.fromMap(categoryHive.toCategoryMap(), categoryHive.id);
  }

  /// Insertar categoría
  Future<void> insertCategory(Category category) async {
    await _ensureInitialized();
    
    final categoryHive = CategoryHive.fromCategory(category);
    await _categoriesBox.put(category.id, categoryHive);
  }

  /// Actualizar categoría
  Future<void> updateCategory(Category category) async {
    await _ensureInitialized();
    
    final categoryHive = CategoryHive.fromCategory(category);
    await _categoriesBox.put(category.id, categoryHive);
  }

  /// Eliminar categoría
  Future<void> deleteCategory(String id) async {
    await _ensureInitialized();
    
    await _categoriesBox.delete(id);
  }

  // ===== VENTAS =====

  /// Obtener todas las ventas
  Future<List<Sale>> getAllSales() async {
    await _ensureInitialized();
    
    final sales = _salesBox.values.toList();
    return sales.map((saleData) => Sale.fromMap(
      Map<String, dynamic>.from(saleData),
      saleData['id'] as String,
    )).toList();
  }

  /// Insertar venta
  Future<void> insertSale(Sale sale) async {
    await _ensureInitialized();
    
    await _salesBox.put(sale.id, sale.toMap());
  }

  /// Eliminar venta
  Future<void> deleteSale(String id) async {
    await _ensureInitialized();
    
    await _salesBox.delete(id);
  }

  // ===== MOVIMIENTOS =====

  /// Obtener todos los movimientos
  Future<List<Movement>> getAllMovements() async {
    await _ensureInitialized();
    
    final movements = _movementsBox.values.toList();
    return movements.map((movementData) => Movement.fromMap(
      Map<String, dynamic>.from(movementData),
      movementData['id'] as String,
    )).toList();
  }

  /// Insertar movimiento
  Future<void> insertMovement(Movement movement) async {
    await _ensureInitialized();
    
    await _movementsBox.put(movement.id, movement.toMap());
  }

  /// Eliminar movimiento
  Future<void> deleteMovement(String id) async {
    await _ensureInitialized();
    
    await _movementsBox.delete(id);
  }

  // ===== DASHBOARD =====

  /// Obtener datos del dashboard
  Future<Map<String, dynamic>> getDashboardData() async {
    await _ensureInitialized();
    
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(Duration(days: startOfDay.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    // Ventas del día
    final todaySales = _salesBox.values.where((sale) {
      final saleDate = DateTime.parse(sale['date']);
      return saleDate.isAfter(startOfDay);
    }).toList();
    
    final todayTotal = todaySales.fold<double>(0, (sum, sale) => sum + (sale['total'] as double));

    // Ventas de la semana
    final weekSales = _salesBox.values.where((sale) {
      final saleDate = DateTime.parse(sale['date']);
      return saleDate.isAfter(startOfWeek);
    }).toList();
    
    final weekTotal = weekSales.fold<double>(0, (sum, sale) => sum + (sale['total'] as double));

    // Ventas del mes
    final monthSales = _salesBox.values.where((sale) {
      final saleDate = DateTime.parse(sale['date']);
      return saleDate.isAfter(startOfMonth);
    }).toList();
    
    final monthTotal = monthSales.fold<double>(0, (sum, sale) => sum + (sale['total'] as double));

    // Productos con stock bajo
    final lowStockProducts = await getLowStockProducts();

    // Total de productos con stock
    final totalProducts = _productsBox.values.where((product) => product.stock > 0).length;

    return {
      'todaySales': todayTotal,
      'weekSales': weekTotal,
      'monthSales': monthTotal,
      'lowStockCount': lowStockProducts.length,
      'totalProducts': totalProducts,
      'recentSales': todaySales.take(5).toList(),
    };
  }

  // ===== UTILIDADES =====

  /// Asegurar que la base de datos esté inicializada
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Limpiar todos los datos (para testing)
  Future<void> clearAllData() async {
    await _ensureInitialized();
    
    await _productsBox.clear();
    await _categoriesBox.clear();
    await _salesBox.clear();
    await _movementsBox.clear();
  }

  /// Obtener estadísticas de la base de datos
  Future<Map<String, int>> getDatabaseStats() async {
    await _ensureInitialized();
    
    return {
      'products': _productsBox.length,
      'categories': _categoriesBox.length,
      'sales': _salesBox.length,
      'movements': _movementsBox.length,
    };
  }
} 