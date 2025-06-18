import 'package:flutter/foundation.dart';

/// Modelo para representar un producto
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final int minStock;
  final int maxStock;
  final String categoryId;
  final String organizationId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;
  final String? barcode;
  final String? sku;
  final Map<String, dynamic>? attributes;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.minStock,
    required this.maxStock,
    required this.categoryId,
    required this.organizationId,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.barcode,
    this.sku,
    this.attributes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'minStock': minStock,
      'maxStock': maxStock,
      'categoryId': categoryId,
      'organizationId': organizationId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'barcode': barcode,
      'sku': sku,
      'attributes': attributes,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      minStock: map['minStock'] as int,
      maxStock: map['maxStock'] as int,
      categoryId: map['categoryId'] as String,
      organizationId: map['organizationId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      imageUrl: map['imageUrl'] as String?,
      barcode: map['barcode'] as String?,
      sku: map['sku'] as String?,
      attributes: map['attributes'] as Map<String, dynamic>?,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    int? minStock,
    int? maxStock,
    String? categoryId,
    String? organizationId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    String? barcode,
    String? sku,
    Map<String, dynamic>? attributes,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      categoryId: categoryId ?? this.categoryId,
      organizationId: organizationId ?? this.organizationId,
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
    return 'Product(id: $id, name: $name, description: $description, price: $price, stock: $stock, minStock: $minStock, maxStock: $maxStock, categoryId: $categoryId, organizationId: $organizationId, createdAt: $createdAt, updatedAt: $updatedAt, imageUrl: $imageUrl, barcode: $barcode, sku: $sku, attributes: $attributes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.price == price &&
        other.stock == stock &&
        other.minStock == minStock &&
        other.maxStock == maxStock &&
        other.categoryId == categoryId &&
        other.organizationId == organizationId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.imageUrl == imageUrl &&
        other.barcode == barcode &&
        other.sku == sku &&
        mapEquals(other.attributes, attributes);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        price.hashCode ^
        stock.hashCode ^
        minStock.hashCode ^
        maxStock.hashCode ^
        categoryId.hashCode ^
        organizationId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        imageUrl.hashCode ^
        barcode.hashCode ^
        sku.hashCode ^
        attributes.hashCode;
  }
} 