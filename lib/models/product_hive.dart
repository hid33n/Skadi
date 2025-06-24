import 'package:hive/hive.dart';

part 'product_hive.g.dart';

@HiveType(typeId: 0)
class ProductHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  double price;

  @HiveField(4)
  int stock;

  @HiveField(5)
  int minStock;

  @HiveField(6)
  int maxStock;

  @HiveField(7)
  String categoryId;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  @HiveField(10)
  String? imageUrl;

  @HiveField(11)
  String? barcode;

  @HiveField(12)
  String? sku;

  @HiveField(13)
  Map<String, dynamic>? attributes;

  ProductHive({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.minStock,
    required this.maxStock,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.barcode,
    this.sku,
    this.attributes,
  });

  // Convertir desde el modelo Product original
  factory ProductHive.fromProduct(dynamic product) {
    return ProductHive(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      stock: product.stock,
      minStock: product.minStock,
      maxStock: product.maxStock,
      categoryId: product.categoryId,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      imageUrl: product.imageUrl,
      barcode: product.barcode,
      sku: product.sku,
      attributes: product.attributes,
    );
  }

  // Convertir al modelo Product original
  Map<String, dynamic> toProductMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'minStock': minStock,
      'maxStock': maxStock,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'barcode': barcode,
      'sku': sku,
      'attributes': attributes,
    };
  }

  // Crear una copia con cambios
  ProductHive copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    int? minStock,
    int? maxStock,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    String? barcode,
    String? sku,
    Map<String, dynamic>? attributes,
  }) {
    return ProductHive(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      attributes: attributes ?? this.attributes,
    );
  }

  @override
  String toString() {
    return 'ProductHive(id: $id, name: $name, price: $price, stock: $stock)';
  }
} 