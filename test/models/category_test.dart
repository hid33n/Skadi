import 'package:flutter_test/flutter_test.dart';
import 'package:stock/models/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Category Model Tests', () {
    test('Category.fromMap should create Category from map', () {
      // Arrange
      final map = {
        'name': 'Test Category',
        'description': 'Test Description',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      // Act
      final category = Category.fromMap(map, 'test-id');

      // Assert
      expect(category.id, 'test-id');
      expect(category.name, 'Test Category');
      expect(category.description, 'Test Description');
    });

    test('Category.toMap should convert Category to map', () {
      // Arrange
      final category = Category(
        id: 'test-id',
        name: 'Test Category',
        description: 'Test Description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final map = category.toMap();

      // Assert
      expect(map['name'], 'Test Category');
      expect(map['description'], 'Test Description');
    });

    test('Category.copyWith should create new Category with updated fields', () {
      // Arrange
      final category = Category(
        id: 'test-id',
        name: 'Test Category',
        description: 'Test Description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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
    });
  });
} 