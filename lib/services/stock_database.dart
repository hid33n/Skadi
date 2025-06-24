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

part 'stock_database.g.dart';

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
  int get schemaVersion => 2;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'stock.db'));
    return NativeDatabase(file);
  });
}
*/ 