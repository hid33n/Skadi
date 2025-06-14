import 'package:flutter_test/flutter_test.dart';
import 'package:stock/models/movement.dart';

void main() {
  group('Movement Model Tests', () {
    test('Movement.fromMap should create Movement from map', () {
      // Arrange
      final map = {
        'productId': 'product-id',
        'productName': 'Test Product',
        'quantity': 5,
        'type': 'entry',
        'date': DateTime.now(),
        'note': 'Test Note',
      };

      // Act
      final movement = Movement.fromMap(map, 'test-id');

      // Assert
      expect(movement.id, 'test-id');
      expect(movement.productId, 'product-id');
      expect(movement.productName, 'Test Product');
      expect(movement.quantity, 5);
      expect(movement.type, MovementType.entry);
      expect(movement.note, 'Test Note');
    });

    test('Movement.toMap should convert Movement to map', () {
      // Arrange
      final movement = Movement(
        id: 'test-id',
        productId: 'product-id',
        productName: 'Test Product',
        quantity: 5,
        type: MovementType.entry,
        date: DateTime.now(),
        note: 'Test Note',
      );

      // Act
      final map = movement.toMap();

      // Assert
      expect(map['productId'], 'product-id');
      expect(map['productName'], 'Test Product');
      expect(map['quantity'], 5);
      expect(map['type'], MovementType.entry);
      expect(map['note'], 'Test Note');
    });

    test('Movement.copyWith should create new Movement with updated fields', () {
      // Arrange
      final movement = Movement(
        id: 'test-id',
        productId: 'product-id',
        productName: 'Test Product',
        quantity: 5,
        type: MovementType.entry,
        date: DateTime.now(),
        note: 'Test Note',
      );

      // Act
      final updatedMovement = movement.copyWith(
        productName: 'Updated Product',
        quantity: 10,
        type: MovementType.exit,
      );

      // Assert
      expect(updatedMovement.id, 'test-id');
      expect(updatedMovement.productId, 'product-id');
      expect(updatedMovement.productName, 'Updated Product');
      expect(updatedMovement.quantity, 10);
      expect(updatedMovement.type, MovementType.exit);
      expect(updatedMovement.note, 'Test Note');
    });
  });
} 