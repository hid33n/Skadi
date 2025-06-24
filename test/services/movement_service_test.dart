import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stock/services/movement_service.dart';
import 'package:stock/models/movement.dart';
import 'package:stock/utils/error_handler.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MovementService movementService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    movementService = MovementService(fakeFirestore);
  });

  group('MovementService Tests', () {
    test('getMovements returns list of movements', () async {
      // Arrange
      final now = DateTime.now();
      final movement1 = Movement(
        id: '1',
        productId: 'product1',
        productName: 'Product 1',
        type: MovementType.entry,
        quantity: 10,
        date: now,
        note: 'Initial stock',
      );
      final movement2 = Movement(
        id: '2',
        productId: 'product2',
        productName: 'Product 2',
        type: MovementType.exit,
        quantity: 5,
        date: now,
        note: 'Sale',
      );

      await fakeFirestore.collection('movements').doc('1').set(movement1.toMap());
      await fakeFirestore.collection('movements').doc('2').set(movement2.toMap());

      // Act
      final movements = await movementService.getMovements();

      // Assert
      expect(movements.length, 2);
      expect(movements[0].productName, 'Product 1');
      expect(movements[1].productName, 'Product 2');
    });

    test('getMovements returns empty list when no movements exist', () async {
      // Act
      final movements = await movementService.getMovements();

      // Assert
      expect(movements, isEmpty);
    });

    test('addMovement adds a movement', () async {
      // Arrange
      final now = DateTime.now();
      final movement = Movement(
        id: '',
        productId: 'product1',
        productName: 'New Product',
        type: MovementType.entry,
        quantity: 15,
        date: now,
        note: 'New movement',
      );

      // Act
      final id = await movementService.addMovement(movement);

      // Assert
      expect(id, isNotEmpty);
      final addedMovement = await fakeFirestore.collection('movements').doc(id).get();
      expect(addedMovement.exists, isTrue);
      expect(addedMovement.data()!['productName'], 'New Product');
    });

    test('getMovement returns a movement', () async {
      // Arrange
      final now = DateTime.now();
      final movement = Movement(
        id: '1',
        productId: 'product1',
        productName: 'Test Product',
        type: MovementType.entry,
        quantity: 10,
        date: now,
        note: 'Test movement',
      );

      await fakeFirestore.collection('movements').doc('1').set(movement.toMap());

      // Act
      final result = await movementService.getMovement('1');

      // Assert
      expect(result?.productName, 'Test Product');
      expect(result?.type, MovementType.entry);
    });

    test('getMovement returns null when movement does not exist', () async {
      // Act
      final result = await movementService.getMovement('non-existent');

      // Assert
      expect(result, isNull);
    });

    test('updateMovement updates a movement', () async {
      // Arrange
      final now = DateTime.now();
      final originalMovement = Movement(
        id: '1',
        productId: 'product1',
        productName: 'Original Product',
        type: MovementType.entry,
        quantity: 10,
        date: now,
        note: 'Original movement',
      );

      await fakeFirestore.collection('movements').doc('1').set(originalMovement.toMap());

      final updatedMovement = Movement(
        id: '1',
        productId: 'product1',
        productName: 'Updated Product',
        type: MovementType.exit,
        quantity: 5,
        date: now,
        note: 'Updated movement',
      );

      // Act
      await movementService.updateMovement('1', updatedMovement);

      // Assert
      final doc = await fakeFirestore.collection('movements').doc('1').get();
      expect(doc.data()!['productName'], 'Updated Product');
      expect(doc.data()!['type'], 'exit');
    });

    test('deleteMovement deletes a movement', () async {
      // Arrange
      final now = DateTime.now();
      final movement = Movement(
        id: '1',
        productId: 'product1',
        productName: 'Product to Delete',
        type: MovementType.entry,
        quantity: 10,
        date: now,
        note: 'Movement to delete',
      );

      await fakeFirestore.collection('movements').doc('1').set(movement.toMap());

      // Act
      await movementService.deleteMovement('1');

      // Assert
      final doc = await fakeFirestore.collection('movements').doc('1').get();
      expect(doc.exists, isFalse);
    });

    test('getMovementsByProduct returns movements for specific product', () async {
      // Arrange
      final now = DateTime.now();
      final movement1 = Movement(
        id: '1',
        productId: 'product1',
        productName: 'Product 1',
        type: MovementType.entry,
        quantity: 10,
        date: now,
        note: 'Movement 1',
      );
      final movement2 = Movement(
        id: '2',
        productId: 'product2',
        productName: 'Product 2',
        type: MovementType.exit,
        quantity: 5,
        date: now,
        note: 'Movement 2',
      );

      await fakeFirestore.collection('movements').doc('1').set(movement1.toMap());
      await fakeFirestore.collection('movements').doc('2').set(movement2.toMap());

      // Act
      final results = await movementService.getMovementsByProduct('product1');

      // Assert
      expect(results.length, 1);
      expect(results[0].productId, 'product1');
    });

    test('getMovementsByType returns movements of specific type', () async {
      // Arrange
      final now = DateTime.now();
      final movement1 = Movement(
        id: '1',
        productId: 'product1',
        productName: 'Product 1',
        type: MovementType.entry,
        quantity: 10,
        date: now,
        note: 'Entry movement',
      );
      final movement2 = Movement(
        id: '2',
        productId: 'product2',
        productName: 'Product 2',
        type: MovementType.exit,
        quantity: 5,
        date: now,
        note: 'Exit movement',
      );

      await fakeFirestore.collection('movements').doc('1').set(movement1.toMap());
      await fakeFirestore.collection('movements').doc('2').set(movement2.toMap());

      // Act
      final results = await movementService.getMovementsByType(MovementType.entry);

      // Assert
      expect(results.length, 1);
      expect(results[0].type, MovementType.entry);
    });

    test('getRecentMovements returns limited movements', () async {
      // Arrange
      final now = DateTime.now();
      final movement1 = Movement(
        id: '1',
        productId: 'product1',
        productName: 'Product 1',
        type: MovementType.entry,
        quantity: 10,
        date: now,
        note: 'Movement 1',
      );
      final movement2 = Movement(
        id: '2',
        productId: 'product2',
        productName: 'Product 2',
        type: MovementType.exit,
        quantity: 5,
        date: now,
        note: 'Movement 2',
      );

      await fakeFirestore.collection('movements').doc('1').set(movement1.toMap());
      await fakeFirestore.collection('movements').doc('2').set(movement2.toMap());

      // Act
      final results = await movementService.getRecentMovements(limit: 1);

      // Assert
      expect(results.length, 1);
    });

    test('getMovementStats returns correct statistics', () async {
      // Arrange
      final now = DateTime.now();
      final movement1 = Movement(
        id: '1',
        productId: 'product1',
        productName: 'Product 1',
        type: MovementType.entry,
        quantity: 10,
        date: now,
        note: 'Entry movement',
      );
      final movement2 = Movement(
        id: '2',
        productId: 'product2',
        productName: 'Product 2',
        type: MovementType.exit,
        quantity: 5,
        date: now,
        note: 'Exit movement',
      );

      await fakeFirestore.collection('movements').doc('1').set(movement1.toMap());
      await fakeFirestore.collection('movements').doc('2').set(movement2.toMap());

      // Act
      final stats = await movementService.getMovementStats();

      // Assert
      expect(stats['totalMovements'], 2);
      expect(stats['movementsByType']['entry'], 1);
      expect(stats['movementsByType']['exit'], 1);
      expect(stats['recentMovements'], 2);
    });
  });
} 