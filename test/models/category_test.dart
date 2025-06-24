import 'package:flutter_test/flutter_test.dart';
import 'package:stock/models/category.dart';

void main() {
  group('Category Model Tests', () {
    test('Category.fromMap should create Category from map', () {
      // Arrange
      final now = DateTime.now();
      final map = {
        'name': 'Test Category',
        'description': 'Test Description',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      // Act
      final category = Category.fromMap(map, 'test-id');

      // Assert
      expect(category.id, 'test-id');
      expect(category.name, 'Test Category');
      expect(category.description, 'Test Description');
      expect(category.createdAt, isA<DateTime>());
      expect(category.updatedAt, isA<DateTime>());
    });

    test('Category.toMap should convert Category to map', () {
      // Arrange
      final now = DateTime.now();
      final category = Category(
        id: 'test-id',
        name: 'Test Category',
        description: 'Test Description',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final map = category.toMap();

      // Assert
      expect(map['name'], 'Test Category');
      expect(map['description'], 'Test Description');
      expect(map['createdAt'], now.toIso8601String());
      expect(map['updatedAt'], now.toIso8601String());
    });

    test('Category.copyWith should create new Category with updated fields', () {
      // Arrange
      final now = DateTime.now();
      final category = Category(
        id: 'test-id',
        name: 'Test Category',
        description: 'Test Description',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final updatedCategory = category.copyWith(
        name: 'Updated Category',
        description: 'Updated Description',
      );

      // Assert
      expect(updatedCategory.id, 'test-id');
      expect(updatedCategory.name, 'Updated Category');
      expect(updatedCategory.description, 'Updated Description');
      expect(updatedCategory.createdAt, now);
      expect(updatedCategory.updatedAt, now);
    });

    test('Category.fromJson should create Category from JSON', () {
      // Arrange
      final now = DateTime.now();
      final json = {
        'id': 'test-id',
        'name': 'Test Category',
        'description': 'Test Description',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      // Act
      final category = Category.fromJson(json);

      // Assert
      expect(category.id, 'test-id');
      expect(category.name, 'Test Category');
      expect(category.description, 'Test Description');
      expect(category.createdAt, isA<DateTime>());
      expect(category.updatedAt, isA<DateTime>());
    });

    test('Category.toJson should convert Category to JSON', () {
      // Arrange
      final now = DateTime.now();
      final category = Category(
        id: 'test-id',
        name: 'Test Category',
        description: 'Test Description',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final json = category.toJson();

      // Assert
      expect(json['id'], 'test-id');
      expect(json['name'], 'Test Category');
      expect(json['description'], 'Test Description');
      expect(json['createdAt'], now.toIso8601String());
      expect(json['updatedAt'], now.toIso8601String());
    });
  });
} 