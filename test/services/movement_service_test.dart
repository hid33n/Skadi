import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock/services/movement_service.dart';
import 'package:stock/models/movement.dart';
import 'package:stock/services/firestore_service.dart';
import '../test_helper.dart';

class MockFirestoreService extends Mock implements FirestoreService {
  @override
  Future<List<Movement>> getMovements() async {
    return [];
  }

  @override
  Future<void> addMovement(Movement movement) async {}

  @override
  Future<void> deleteMovement(String id) async {}

  @override
  Future<List<Movement>> getMovementsByProduct(String productId) async {
    return [];
  }

  @override
  Future<List<Movement>> getMovementsByDateRange(DateTime startDate, DateTime endDate) async {
    return [];
  }

  @override
  Future<List<Movement>> getMovementsByType(MovementType type) async {
    return [];
  }
}

void main() {
  late MockFirestoreService mockFirestoreService;
  late MovementService movementService;

  setUp(() {
    mockFirestoreService = MockFirestoreService();
    movementService = MovementService(mockFirestoreService);
  });

  group('MovementService Tests', () {
    test('getMovements should return list of movements', () async {
      // Arrange
      final mockMovements = [
        Movement(
          id: '1',
          productId: 'prod1',
          productName: 'Product 1',
          quantity: 5,
          type: MovementType.entry,
          date: DateTime.now(),
          note: 'Initial stock',
        ),
        Movement(
          id: '2',
          productId: 'prod2',
          productName: 'Product 2',
          quantity: 3,
          type: MovementType.exit,
          date: DateTime.now(),
          note: 'Sale',
        ),
      ];

      when(mockFirestoreService.getMovements())
          .thenAnswer((_) async => mockMovements);

      // Act
      final movements = await movementService.getMovements();

      // Assert
      expect(movements.length, 2);
      expect(movements[0].productName, 'Product 1');
      expect(movements[1].productName, 'Product 2');
      verify(mockFirestoreService.getMovements()).called(1);
    });

    test('getMovements should return empty list when no movements exist', () async {
      // Arrange
      when(mockFirestoreService.getMovements())
          .thenAnswer((_) async => []);

      // Act
      final movements = await movementService.getMovements();

      // Assert
      expect(movements, isEmpty);
      verify(mockFirestoreService.getMovements()).called(1);
    });

    test('addMovement should add movement to Firestore', () async {
      // Arrange
      final movement = Movement(
        id: '',
        productId: 'prod1',
        productName: 'New Product',
        quantity: 10,
        type: MovementType.entry,
        date: DateTime.now(),
        note: 'New stock',
      );

      when(mockFirestoreService.addMovement(movement))
          .thenAnswer((_) async {});

      // Act
      await movementService.addMovement(movement);

      // Assert
      verify(mockFirestoreService.addMovement(movement)).called(1);
    });

    test('addMovement throws error when quantity is zero', () async {
      // Arrange
      final movement = Movement(
        id: '',
        productId: 'prod1',
        productName: 'New Product',
        quantity: 0,
        type: MovementType.entry,
        date: DateTime.now(),
        note: 'Invalid movement',
      );

      // Act & Assert
      expect(
        () => movementService.addMovement(movement),
        throwsException,
      );
    });

    test('addMovement throws error when quantity is negative', () async {
      // Arrange
      final movement = Movement(
        id: '',
        productId: 'prod1',
        productName: 'New Product',
        quantity: -10,
        type: MovementType.entry,
        date: DateTime.now(),
        note: 'Invalid movement',
      );

      // Act & Assert
      expect(
        () => movementService.addMovement(movement),
        throwsException,
      );
    });

    test('deleteMovement should delete movement from Firestore', () async {
      // Arrange
      when(mockFirestoreService.deleteMovement('1'))
          .thenAnswer((_) async {});

      // Act
      await movementService.deleteMovement('1');

      // Assert
      verify(mockFirestoreService.deleteMovement('1')).called(1);
    });

    test('getMovementsByProduct should return movements for specific product', () async {
      // Arrange
      final mockMovements = [
        Movement(
          id: '1',
          productId: 'prod1',
          productName: 'Product 1',
          quantity: 5,
          type: MovementType.entry,
          date: DateTime.now(),
          note: 'Initial stock',
        ),
        Movement(
          id: '2',
          productId: 'prod1',
          productName: 'Product 1',
          quantity: 2,
          type: MovementType.exit,
          date: DateTime.now(),
          note: 'Sale',
        ),
      ];

      when(mockFirestoreService.getMovementsByProduct('prod1'))
          .thenAnswer((_) async => mockMovements);

      // Act
      final movements = await movementService.getMovementsByProduct('prod1');

      // Assert
      expect(movements.length, 2);
      expect(movements[0].productId, 'prod1');
      expect(movements[1].productId, 'prod1');
      verify(mockFirestoreService.getMovementsByProduct('prod1')).called(1);
    });

    test('getMovementsByProduct should return empty list when no movements for product', () async {
      // Arrange
      when(mockFirestoreService.getMovementsByProduct('non-existent'))
          .thenAnswer((_) async => []);

      // Act
      final movements = await movementService.getMovementsByProduct('non-existent');

      // Assert
      expect(movements, isEmpty);
      verify(mockFirestoreService.getMovementsByProduct('non-existent')).called(1);
    });

    test('getMovementsByDateRange should return movements within date range', () async {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 31);
      final mockMovements = [
        Movement(
          id: '1',
          productId: 'prod1',
          productName: 'Product 1',
          quantity: 5,
          type: MovementType.entry,
          date: DateTime(2024, 1, 15),
          note: 'Initial stock',
        ),
      ];

      when(mockFirestoreService.getMovementsByDateRange(startDate, endDate))
          .thenAnswer((_) async => mockMovements);

      // Act
      final movements = await movementService.getMovementsByDateRange(startDate, endDate);

      // Assert
      expect(movements.length, 1);
      expect(movements[0].productName, 'Product 1');
      verify(mockFirestoreService.getMovementsByDateRange(startDate, endDate)).called(1);
    });

    test('getMovementsByDateRange should return empty list when no movements in range', () async {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 31);

      when(mockFirestoreService.getMovementsByDateRange(startDate, endDate))
          .thenAnswer((_) async => []);

      // Act
      final movements = await movementService.getMovementsByDateRange(startDate, endDate);

      // Assert
      expect(movements, isEmpty);
      verify(mockFirestoreService.getMovementsByDateRange(startDate, endDate)).called(1);
    });

    test('getMovementsByDateRange should throw error when end date is before start date', () async {
      // Arrange
      final startDate = DateTime(2024, 1, 31);
      final endDate = DateTime(2024, 1, 1);

      // Act & Assert
      expect(
        () => movementService.getMovementsByDateRange(startDate, endDate),
        throwsException,
      );
    });

    test('getMovementsByType should return movements of specific type', () async {
      // Arrange
      final mockMovements = [
        Movement(
          id: '1',
          productId: 'prod1',
          productName: 'Product 1',
          quantity: 5,
          type: MovementType.entry,
          date: DateTime.now(),
          note: 'Initial stock',
        ),
        Movement(
          id: '2',
          productId: 'prod2',
          productName: 'Product 2',
          quantity: 3,
          type: MovementType.entry,
          date: DateTime.now(),
          note: 'Restock',
        ),
      ];

      when(mockFirestoreService.getMovementsByType(MovementType.entry))
          .thenAnswer((_) async => mockMovements);

      // Act
      final movements = await movementService.getMovementsByType(MovementType.entry);

      // Assert
      expect(movements.length, 2);
      expect(movements[0].type, MovementType.entry);
      expect(movements[1].type, MovementType.entry);
      verify(mockFirestoreService.getMovementsByType(MovementType.entry)).called(1);
    });

    test('getMovementsByType should return empty list when no movements of type', () async {
      // Arrange
      when(mockFirestoreService.getMovementsByType(MovementType.exit))
          .thenAnswer((_) async => []);

      // Act
      final movements = await movementService.getMovementsByType(MovementType.exit);

      // Assert
      expect(movements, isEmpty);
      verify(mockFirestoreService.getMovementsByType(MovementType.exit)).called(1);
    });
  });
} 