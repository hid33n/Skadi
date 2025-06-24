import 'package:flutter_test/flutter_test.dart';
import 'package:stock/models/sale.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Sale Model Tests', () {
    test('Sale.fromMap should create Sale from map', () {
      // Arrange
      final now = DateTime.now();
      final map = {
        'userId': 'user-id',
        'productId': 'product-id',
        'productName': 'Test Product',
        'amount': 10.0,
        'quantity': 2,
        'date': Timestamp.fromDate(now),
        'notes': 'Test Notes',
      };

      // Act
      final sale = Sale.fromMap(map, 'test-id');

      // Assert
      expect(sale.id, 'test-id');
      expect(sale.userId, 'user-id');
      expect(sale.productId, 'product-id');
      expect(sale.productName, 'Test Product');
      expect(sale.amount, 10.0);
      expect(sale.quantity, 2);
      expect(sale.notes, 'Test Notes');
    });

    test('Sale.toMap should convert Sale to map', () {
      // Arrange
      final now = DateTime.now();
      final sale = Sale(
        id: 'test-id',
        userId: 'user-id',
        productId: 'product-id',
        productName: 'Test Product',
        amount: 10.0,
        quantity: 2,
        date: now,
        notes: 'Test Notes',
      );

      // Act
      final map = sale.toMap();

      // Assert
      expect(map['userId'], 'user-id');
      expect(map['productId'], 'product-id');
      expect(map['productName'], 'Test Product');
      expect(map['amount'], 10.0);
      expect(map['quantity'], 2);
      expect(map['notes'], 'Test Notes');
      expect(map['date'], isA<Timestamp>());
    });

    test('Sale should format date correctly', () {
      // Arrange
      final sale = Sale(
        id: 'test-id',
        userId: 'user-id',
        productId: 'product-id',
        productName: 'Test Product',
        amount: 10.0,
        quantity: 2,
        date: DateTime(2023, 12, 25, 14, 30),
        notes: 'Test Notes',
      );

      // Act & Assert
      expect(sale.formattedDate, '25/12/2023 14:30');
    });

    test('Sale should format total correctly', () {
      // Arrange
      final sale = Sale(
        id: 'test-id',
        userId: 'user-id',
        productId: 'product-id',
        productName: 'Test Product',
        amount: 10.50,
        quantity: 2,
        date: DateTime.now(),
        notes: 'Test Notes',
      );

      // Act & Assert
      expect(sale.formattedTotal, '\$10.50');
    });

    test('Sale should handle null notes', () {
      // Arrange
      final now = DateTime.now();
      final sale = Sale(
        id: 'test-id',
        userId: 'user-id',
        productId: 'product-id',
        productName: 'Test Product',
        amount: 10.0,
        quantity: 2,
        date: now,
        notes: null,
      );

      // Act
      final map = sale.toMap();

      // Assert
      expect(map['notes'], isNull);
      expect(sale.notes, isNull);
    });
  });

  group('SaleItem Model Tests', () {
    test('SaleItem.fromJson should create SaleItem from JSON', () {
      // Arrange
      final json = {
        'productId': 'product-id',
        'productName': 'Test Product',
        'quantity': 2,
        'unitPrice': 5.0,
        'subtotal': 10.0,
      };

      // Act
      final saleItem = SaleItem.fromJson(json);

      // Assert
      expect(saleItem.productId, 'product-id');
      expect(saleItem.productName, 'Test Product');
      expect(saleItem.quantity, 2);
      expect(saleItem.unitPrice, 5.0);
      expect(saleItem.subtotal, 10.0);
    });

    test('SaleItem.toJson should convert SaleItem to JSON', () {
      // Arrange
      final saleItem = SaleItem(
        productId: 'product-id',
        productName: 'Test Product',
        quantity: 2,
        unitPrice: 5.0,
        subtotal: 10.0,
      );

      // Act
      final json = saleItem.toJson();

      // Assert
      expect(json['productId'], 'product-id');
      expect(json['productName'], 'Test Product');
      expect(json['quantity'], 2);
      expect(json['unitPrice'], 5.0);
      expect(json['subtotal'], 10.0);
    });
  });
} 