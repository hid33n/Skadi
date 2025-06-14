import 'package:flutter_test/flutter_test.dart';
import 'package:stock/models/sale.dart';

void main() {
  group('Sale Model Tests', () {
    test('Sale.fromMap should create Sale from map', () {
      // Arrange
      final map = {
        'userId': 'user-id',
        'productId': 'product-id',
        'productName': 'Test Product',
        'amount': 10.0,
        'quantity': 2,
        'date': DateTime.now(),
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
      final sale = Sale(
        id: 'test-id',
        userId: 'user-id',
        productId: 'product-id',
        productName: 'Test Product',
        amount: 10.0,
        quantity: 2,
        date: DateTime.now(),
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
    });

    // test('Sale.copyWith should create new Sale with updated fields', () {
    //   // Arrange
    //   final sale = Sale(
    //     id: 'test-id',
    //     userId: 'user-id',
    //     productId: 'product-id',
    //     productName: 'Test Product',
    //     amount: 10.0,
    //     quantity: 2,
    //     date: DateTime.now(),
    //     notes: 'Test Notes',
    //   );

    //   // Act
    //   final updatedSale = sale.copyWith(
    //     amount: 200.0,
    //   );

    //   // Assert
    //   expect(updatedSale.id, 'test-id');
    //   expect(updatedSale.userId, 'user-id');
    //   expect(updatedSale.productId, 'product-id');
    //   expect(updatedSale.productName, 'Test Product');
    //   expect(updatedSale.amount, 200.0);
    //   expect(updatedSale.quantity, 2);
    //   expect(updatedSale.notes, 'Test Notes');
    // });
  });
} 