import 'package:flutter_test/flutter_test.dart';
import 'package:stock/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('Product.fromMap should create Product from map', () {
      // Arrange
      final now = DateTime.now();
      final map = {
        'name': 'Test Product',
        'description': 'Test Description',
        'price': 10.0,
        'stock': 5,
        'categoryId': 'category-id',
        'minStock': 2,
        'maxStock': 10,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      // Act
      final product = Product.fromMap(map, 'test-id');

      // Assert
      expect(product.id, 'test-id');
      expect(product.name, 'Test Product');
      expect(product.description, 'Test Description');
      expect(product.price, 10.0);
      expect(product.stock, 5);
      expect(product.categoryId, 'category-id');
      expect(product.minStock, 2);
      expect(product.maxStock, 10);
    });

    test('Product.toMap should convert Product to map', () {
      // Arrange
      final now = DateTime.now();
      final product = Product(
        id: 'test-id',
        name: 'Test Product',
        description: 'Test Description',
        price: 10.0,
        stock: 5,
        categoryId: 'category-id',
        minStock: 2,
        maxStock: 10,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final map = product.toMap();

      // Assert
      expect(map['name'], 'Test Product');
      expect(map['description'], 'Test Description');
      expect(map['price'], 10.0);
      expect(map['stock'], 5);
      expect(map['categoryId'], 'category-id');
      expect(map['minStock'], 2);
      expect(map['maxStock'], 10);
      expect(map['createdAt'], now.toIso8601String());
      expect(map['updatedAt'], now.toIso8601String());
    });

    test('Product.copyWith should create new Product with updated fields', () {
      // Arrange
      final now = DateTime.now();
      final product = Product(
        id: 'test-id',
        name: 'Test Product',
        description: 'Test Description',
        price: 10.0,
        stock: 5,
        categoryId: 'category-id',
        minStock: 2,
        maxStock: 10,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final updatedProduct = product.copyWith(
        name: 'Updated Product',
        price: 15.0,
      );

      // Assert
      expect(updatedProduct.id, 'test-id');
      expect(updatedProduct.name, 'Updated Product');
      expect(updatedProduct.price, 15.0);
      expect(updatedProduct.description, 'Test Description');
      expect(updatedProduct.stock, 5);
      expect(updatedProduct.categoryId, 'category-id');
      expect(updatedProduct.minStock, 2);
      expect(updatedProduct.maxStock, 10);
      expect(updatedProduct.createdAt, now);
      expect(updatedProduct.updatedAt, now);
    });

    test('Product should handle optional fields correctly', () {
      // Arrange
      final now = DateTime.now();
      final product = Product(
        id: 'test-id',
        name: 'Test Product',
        description: 'Test Description',
        price: 10.0,
        stock: 5,
        categoryId: 'category-id',
        minStock: 2,
        maxStock: 10,
        createdAt: now,
        updatedAt: now,
        imageUrl: 'https://example.com/image.jpg',
        barcode: '123456789',
        sku: 'SKU123',
        attributes: {'color': 'red', 'size': 'large'},
      );

      // Act
      final map = product.toMap();

      // Assert
      expect(map['imageUrl'], 'https://example.com/image.jpg');
      expect(map['barcode'], '123456789');
      expect(map['sku'], 'SKU123');
      expect(map['attributes'], {'color': 'red', 'size': 'large'});
    });

    test('Product should handle null optional fields', () {
      // Arrange
      final now = DateTime.now();
      final product = Product(
        id: 'test-id',
        name: 'Test Product',
        description: 'Test Description',
        price: 10.0,
        stock: 5,
        categoryId: 'category-id',
        minStock: 2,
        maxStock: 10,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final map = product.toMap();

      // Assert
      expect(map['imageUrl'], isNull);
      expect(map['barcode'], isNull);
      expect(map['sku'], isNull);
      expect(map['attributes'], isNull);
    });
  });
} 