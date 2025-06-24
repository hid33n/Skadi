// ARCHIVO TEMPORALMENTE COMENTADO PARA MIGRAR A HIVE
/*
import 'dart:io';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/product.dart';
import '../models/category.dart';
import '../models/sale.dart';
import '../models/movement.dart';

part 'database_service.g.dart';

// Tablas de la base de datos
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  RealColumn get price => real()();
  IntColumn get stock => integer()();
  IntColumn get minStock => integer()();
  IntColumn get maxStock => integer()();
  TextColumn get barcode => text().nullable()();
  TextColumn get sku => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get attributes => text().nullable(); // JSON string
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get color => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Sales extends Table {
  TextColumn get id => text()();
  RealColumn get total => real()();
  TextColumn get customerName => text().nullable()();
  TextColumn get customerPhone => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SaleItems extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get productId => text()();
  RealColumn get price => real()();
  IntColumn get quantity => integer()();
  RealColumn get subtotal => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class Movements extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get type => text()(); // 'in' o 'out'
  IntColumn get quantity => integer()();
  TextColumn get reason => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Products, Categories, Sales, SaleItems, Movements])
class StockDatabase extends _$StockDatabase {
  StockDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2; // Incrementado para la nueva estructura

  // Métodos para Productos
  Future<List<Product>> getAllProducts() async {
    final query = select(products);
    final results = await query.get();
    
    return results.map((row) => Product(
      id: row.id,
      name: row.name,
      description: row.description ?? '',
      categoryId: row.categoryId ?? '',
      price: row.price,
      stock: row.stock,
      minStock: row.minStock,
      maxStock: row.maxStock,
      barcode: row.barcode,
      sku: row.sku,
      imageUrl: row.imageUrl,
      attributes: row.attributes != null ? jsonDecode(row.attributes!) : null,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    )).toList();
  }

  Future<Product?> getProductById(String id) async {
    final query = select(products)..where((p) => p.id.equals(id));
    final result = await query.getSingleOrNull();
    
    if (result == null) return null;
    
    return Product(
      id: result.id,
      name: result.name,
      description: result.description ?? '',
      categoryId: result.categoryId ?? '',
      price: result.price,
      stock: result.stock,
      minStock: result.minStock,
      maxStock: result.maxStock,
      barcode: result.barcode,
      sku: result.sku,
      imageUrl: result.imageUrl,
      attributes: result.attributes != null ? jsonDecode(result.attributes!) : null,
      createdAt: result.createdAt,
      updatedAt: result.updatedAt,
    );
  }

  Future<void> insertProduct(Product product) async {
    await into(products).insert(ProductsCompanion.insert(
      id: product.id,
      name: product.name,
      description: Value(product.description),
      categoryId: Value(product.categoryId),
      price: product.price,
      stock: product.stock,
      minStock: product.minStock,
      maxStock: product.maxStock,
      barcode: Value(product.barcode),
      sku: Value(product.sku),
      imageUrl: Value(product.imageUrl),
      attributes: Value(product.attributes != null ? jsonEncode(product.attributes!) : null),
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    ));
  }

  Future<void> updateProduct(Product product) async {
    await update(products)
        .replace(ProductsCompanion.insert(
          id: product.id,
          name: product.name,
          description: Value(product.description),
          categoryId: Value(product.categoryId),
          price: product.price,
          stock: product.stock,
          minStock: product.minStock,
          maxStock: product.maxStock,
      barcode: Value(product.barcode),
      sku: Value(product.sku),
      imageUrl: Value(product.imageUrl),
      attributes: Value(product.attributes != null ? jsonEncode(product.attributes!) : null),
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    ));
  }

  Future<void> deleteProduct(String id) async {
    await (delete(products)..where((p) => p.id.equals(id))).go();
  }

  Future<List<Product>> getLowStockProducts() async {
    final query = select(products)
        .join([innerJoin(categories, categories.id.equalsExp(products.categoryId))])
        .where(products.stock.isSmallerOrEqualValue(products.minStock));
    
    final results = await query.get();
    
    return results.map((row) => Product(
      id: row.readTable(products).id,
      name: row.readTable(products).name,
      description: row.readTable(products).description ?? '',
      categoryId: row.readTable(products).categoryId ?? '',
      price: row.readTable(products).price,
      stock: row.readTable(products).stock,
      minStock: row.readTable(products).minStock,
      maxStock: row.readTable(products).maxStock,
      barcode: row.readTable(products).barcode,
      sku: row.readTable(products).sku,
      imageUrl: row.readTable(products).imageUrl,
      attributes: row.readTable(products).attributes != null ? jsonDecode(row.readTable(products).attributes!) : null,
      createdAt: row.readTable(products).createdAt,
      updatedAt: row.readTable(products).updatedAt,
    )).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final lowercaseQuery = query.toLowerCase();
    final queryBuilder = select(products)
        .where((p) => p.name.contains(lowercaseQuery) | 
                     p.description.contains(lowercaseQuery) |
                     p.barcode.contains(lowercaseQuery));
    
    final results = await queryBuilder.get();
    
    return results.map((row) => Product(
      id: row.id,
      name: row.name,
      description: row.description ?? '',
      categoryId: row.categoryId ?? '',
      price: row.price,
      stock: row.stock,
      minStock: row.minStock,
      maxStock: row.maxStock,
      barcode: row.barcode,
      sku: row.sku,
      imageUrl: row.imageUrl,
      attributes: row.attributes != null ? jsonDecode(row.attributes!) : null,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    )).toList();
  }

  // Métodos para Categorías
  Future<List<Category>> getAllCategories() async {
    final query = select(categories);
    final results = await query.get();
    
    return results.map((row) => Category(
      id: row.id,
      name: row.name,
      description: row.description ?? '',
      color: row.color,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    )).toList();
  }

  Future<Category?> getCategoryById(String id) async {
    final query = select(categories)..where((c) => c.id.equals(id));
    final result = await query.getSingleOrNull();
    
    if (result == null) return null;
    
    return Category(
      id: result.id,
      name: result.name,
      description: result.description ?? '',
      color: result.color,
      createdAt: result.createdAt,
      updatedAt: result.updatedAt,
    );
  }

  Future<void> insertCategory(Category category) async {
    await into(categories).insert(CategoriesCompanion.insert(
      id: category.id,
      name: category.name,
      description: Value(category.description),
      color: Value(category.color),
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    ));
  }

  Future<void> updateCategory(Category category) async {
    await update(categories)
        .replace(CategoriesCompanion.insert(
          id: category.id,
          name: category.name,
          description: Value(category.description),
          color: Value(category.color),
          createdAt: category.createdAt,
          updatedAt: category.updatedAt,
        ));
  }

  Future<void> deleteCategory(String id) async {
    await (delete(categories)..where((c) => c.id.equals(id))).go();
  }

  // Métodos para Ventas
  Future<List<Sale>> getAllSales() async {
    final query = select(sales);
    final results = await query.get();
    
    return results.map((row) => Sale(
      id: row.id,
      total: row.total,
      customerName: row.customerName,
      customerPhone: row.customerPhone,
      notes: row.notes,
      date: row.date,
      createdAt: row.createdAt,
      items: [], // Los items se cargan por separado
    )).toList();
  }

  Future<Sale?> getSaleById(String id) async {
    final query = select(sales)..where((s) => s.id.equals(id));
    final result = await query.getSingleOrNull();
    
    if (result == null) return null;
    
    // Cargar items de la venta
    final itemsQuery = select(saleItems)..where((si) => si.saleId.equals(id));
    final items = await itemsQuery.get();
    
    final saleItems = items.map((item) => SaleItem(
      id: item.id,
      saleId: item.saleId,
      productId: item.productId,
      price: item.price,
      quantity: item.quantity,
      subtotal: item.subtotal,
    )).toList();
    
    return Sale(
      id: result.id,
      total: result.total,
      customerName: result.customerName,
      customerPhone: result.customerPhone,
      notes: result.notes,
      date: result.date,
      createdAt: result.createdAt,
      items: saleItems,
    );
  }

  Future<void> insertSale(Sale sale) async {
    await into(sales).insert(SalesCompanion.insert(
      id: sale.id,
      total: sale.total,
      customerName: Value(sale.customerName),
      customerPhone: Value(sale.customerPhone),
      notes: Value(sale.notes),
      date: sale.date,
      createdAt: sale.createdAt,
    ));
    
    // Insertar items de la venta
    for (final item in sale.items) {
      await into(saleItems).insert(SaleItemsCompanion.insert(
        id: item.id,
        saleId: item.saleId,
        productId: item.productId,
        price: item.price,
        quantity: item.quantity,
        subtotal: item.subtotal,
      ));
    }
  }

  Future<void> deleteSale(String id) async {
    // Eliminar items primero
    await (delete(saleItems)..where((si) => si.saleId.equals(id))).go();
    // Eliminar venta
    await (delete(sales)..where((s) => s.id.equals(id))).go();
  }

  // Métodos para Movimientos
  Future<List<Movement>> getAllMovements() async {
    final query = select(movements);
    final results = await query.get();
    
    return results.map((row) => Movement(
      id: row.id,
      productId: row.productId,
      type: row.type,
      quantity: row.quantity,
      reason: row.reason,
      notes: row.notes,
      date: row.date,
      createdAt: row.createdAt,
    )).toList();
  }

  Future<void> insertMovement(Movement movement) async {
    await into(movements).insert(MovementsCompanion.insert(
      id: movement.id,
      productId: movement.productId,
      type: movement.type,
      quantity: movement.quantity,
      reason: Value(movement.reason),
      notes: Value(movement.notes),
      date: movement.date,
      createdAt: movement.createdAt,
    ));
  }

  Future<void> deleteMovement(String id) async {
    await (delete(movements)..where((m) => m.id.equals(id))).go();
  }

  // Métodos para Dashboard
  Future<Map<String, dynamic>> getDashboardData() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(Duration(days: startOfDay.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    // Ventas del día
    final todaySalesQuery = select(sales)
        .where((s) => s.date.isAfterValue(startOfDay));
    final todaySales = await todaySalesQuery.get();
    final todayTotal = todaySales.fold<double>(0, (sum, sale) => sum + sale.total);

    // Ventas de la semana
    final weekSalesQuery = select(sales)
        .where((s) => s.date.isAfterValue(startOfWeek));
    final weekSales = await weekSalesQuery.get();
    final weekTotal = weekSales.fold<double>(0, (sum, sale) => sum + sale.total);

    // Ventas del mes
    final monthSalesQuery = select(sales)
        .where((s) => s.date.isAfterValue(startOfMonth));
    final monthSales = await monthSalesQuery.get();
    final monthTotal = monthSales.fold<double>(0, (sum, sale) => sum + sale.total);

    // Productos con stock bajo
    final lowStockProducts = await getLowStockProducts();

    // Total de productos con stock
    final totalProductsQuery = select(products)
        .where((p) => p.stock.isBiggerThanValue(0));
    final totalProducts = await totalProductsQuery.get();

    return {
      'todaySales': todayTotal,
      'weekSales': weekTotal,
      'monthSales': monthTotal,
      'lowStockCount': lowStockProducts.length,
      'totalProducts': totalProducts.length,
      'recentSales': todaySales.take(5).map((sale) => sale.toMap()).toList(),
    };
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'stock.db'));
    return NativeDatabase(file);
  });
}
*/ 