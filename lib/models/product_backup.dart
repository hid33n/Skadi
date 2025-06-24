import 'package:flutter/foundation.dart';

/// Modelo para representar un producto
class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final int minStock;
  final String? categoryId;
  final String? barcode;
  final String? brand;
  final String? model;
  final String? year;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.minStock,
    this.categoryId,
    this.barcode,
    this.brand,
    this.model,
    this.year,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'minStock': minStock,
      'categoryId': categoryId,
      'barcode': barcode,
      'brand': brand,
      'model': model,
      'year': year,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] as String,
      description: map['description'] as String?,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      minStock: map['minStock'] as int,
      categoryId: map['categoryId'] as String?,
      barcode: map['barcode'] as String?,
      brand: map['brand'] as String?,
      model: map['model'] as String?,
      year: map['year'] as String?,
      imageUrl: map['imageUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    int? minStock,
    String? categoryId,
    String? barcode,
    String? brand,
    String? model,
    String? year,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      categoryId: categoryId ?? this.categoryId,
      barcode: barcode ?? this.barcode,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, description: $description, price: $price, stock: $stock, minStock: $minStock, categoryId: $categoryId, barcode: $barcode, brand: $brand, model: $model, year: $year, imageUrl: $imageUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
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
        other.categoryId == categoryId &&
        other.barcode == barcode &&
        other.brand == brand &&
        other.model == model &&
        other.year == year &&
        other.imageUrl == imageUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        price.hashCode ^
        stock.hashCode ^
        minStock.hashCode ^
        categoryId.hashCode ^
        barcode.hashCode ^
        brand.hashCode ^
        model.hashCode ^
        year.hashCode ^
        imageUrl.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
} 