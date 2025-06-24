import 'package:flutter_test/flutter_test.dart';
import 'package:stock/models/movement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Movement Model Tests', () {
    test('Movement.fromMap should create Movement from map', () {
      // Arrange
      final now = DateTime.now();
      final map = {
        'productId': 'product-id',
        'productName': 'Test Product',
        'quantity': 5,
        'type': 'entry',
        'date': Timestamp.fromDate(now),
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
      final now = DateTime.now();
      final movement = Movement(
        id: 'test-id',
        productId: 'product-id',
        productName: 'Test Product',
        quantity: 5,
        type: MovementType.entry,
        date: now,
        note: 'Test Note',
      );

      // Act
      final map = movement.toMap();

      // Assert
      expect(map['productId'], 'product-id');
      expect(map['productName'], 'Test Product');
      expect(map['quantity'], 5);
      expect(map['type'], 'entry');
      expect(map['note'], 'Test Note');
      expect(map['date'], isA<Timestamp>());
    });

    test('Movement.copyWith should create new Movement with updated fields', () {
      // Arrange
      final now = DateTime.now();
      final movement = Movement(
        id: 'test-id',
        productId: 'product-id',
        productName: 'Test Product',
        quantity: 5,
        type: MovementType.entry,
        date: now,
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

    test('Movement should handle exit type correctly', () {
      // Arrange
      final now = DateTime.now();
      final movement = Movement(
        id: 'test-id',
        productId: 'product-id',
        productName: 'Test Product',
        quantity: 3,
        type: MovementType.exit,
        date: now,
        note: 'Sale',
      );

      // Act
      final map = movement.toMap();

      // Assert
      expect(map['type'], 'exit');
      expect(movement.type, MovementType.exit);
    });

    test('Movement should handle null note', () {
      // Arrange
      final now = DateTime.now();
      final movement = Movement(
        id: 'test-id',
        productId: 'product-id',
        productName: 'Test Product',
        quantity: 5,
        type: MovementType.entry,
        date: now,
        note: null,
      );

      // Act
      final map = movement.toMap();

      // Assert
      expect(map['note'], isNull);
      expect(movement.note, isNull);
    });
  });
} 