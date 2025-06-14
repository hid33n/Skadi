import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stock/models/category.dart';
import 'package:stock/services/category_service.dart';
import 'package:stock/services/firestore_service.dart';
import '../test_helper.dart';

class MockFirestoreService extends Mock implements FirestoreService {
  @override
  Future<List<Category>> getCategories() async {
    return [];
  }

  @override
  Future<void> addCategory(Category category) async {}

  @override
  Future<void> updateCategory(String id, Category category) async {}

  @override
  Future<void> deleteCategory(String id) async {}

  @override
  Future<Category?> getCategoryById(String id) async {
    return null;
  }
}

void main() {
  late MockFirestoreService mockFirestoreService;
  late CategoryService categoryService;

  setUp(() {
    mockFirestoreService = MockFirestoreService();
    categoryService = CategoryService(mockFirestoreService);
  });

  group('CategoryService Tests', () {
    test('getCategories returns list of categories', () async {
      // Arrange
      final mockCategories = [
        Category(
          id: '1',
          name: 'Category 1',
          description: 'Description 1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Category(
          id: '2',
          name: 'Category 2',
          description: 'Description 2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockFirestoreService.getCategories())
          .thenAnswer((_) async => mockCategories);

      // Act
      final categories = await categoryService.getCategories();

      // Assert
      expect(categories.length, 2);
      expect(categories[0].name, 'Category 1');
      expect(categories[1].name, 'Category 2');
      verify(mockFirestoreService.getCategories()).called(1);
    });

    test('getCategories returns empty list when no categories exist', () async {
      // Arrange
      when(mockFirestoreService.getCategories())
          .thenAnswer((_) async => []);

      // Act
      final categories = await categoryService.getCategories();

      // Assert
      expect(categories, isEmpty);
      verify(mockFirestoreService.getCategories()).called(1);
    });

    test('addCategory adds a category', () async {
      // Arrange
      final category = Category(
        id: '',
        name: 'New Category',
        description: 'New Description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockFirestoreService.addCategory(category))
          .thenAnswer((_) async => null);

      // Act
      await categoryService.addCategory(category);

      // Assert
      verify(mockFirestoreService.addCategory(category)).called(1);
    });

    test('addCategory throws error when name is empty', () async {
      // Arrange
      final category = Category(
        id: '',
        name: '',
        description: 'New Description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => categoryService.addCategory(category),
        throwsException,
      );
    });

    test('updateCategory updates a category', () async {
      // Arrange
      final category = Category(
        id: '1',
        name: 'Updated Category',
        description: 'Updated Description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockFirestoreService.updateCategory('1', category))
          .thenAnswer((_) async => null);

      // Act
      await categoryService.updateCategory('1', category);

      // Assert
      verify(mockFirestoreService.updateCategory('1', category)).called(1);
    });

    test('updateCategory throws error when name is empty', () async {
      // Arrange
      final category = Category(
        id: '1',
        name: '',
        description: 'Updated Description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => categoryService.updateCategory('1', category),
        throwsException,
      );
    });

    test('updateCategory throws error when category does not exist', () async {
      // Arrange
      final category = Category(
        id: 'non-existent',
        name: 'Updated Category',
        description: 'Updated Description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockFirestoreService.updateCategory('non-existent', category))
          .thenThrow(Exception('Category not found'));

      // Act & Assert
      expect(
        () => categoryService.updateCategory('non-existent', category),
        throwsException,
      );
    });

    test('deleteCategory deletes a category', () async {
      // Arrange
      when(mockFirestoreService.deleteCategory('1'))
          .thenAnswer((_) async => null);

      // Act
      await categoryService.deleteCategory('1');

      // Assert
      verify(mockFirestoreService.deleteCategory('1')).called(1);
    });

    test('deleteCategory throws error when category does not exist', () async {
      // Arrange
      when(mockFirestoreService.deleteCategory('non-existent'))
          .thenThrow(Exception('Category not found'));

      // Act & Assert
      expect(
        () => categoryService.deleteCategory('non-existent'),
        throwsException,
      );
    });

    test('getCategoryById returns a category', () async {
      // Arrange
      final mockCategory = Category(
        id: '1',
        name: 'Category 1',
        description: 'Description 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockFirestoreService.getCategoryById('1'))
          .thenAnswer((_) async => mockCategory);

      // Act
      final category = await categoryService.getCategoryById('1');

      // Assert
      expect(category?.name, 'Category 1');
      expect(category?.description, 'Description 1');
      verify(mockFirestoreService.getCategoryById('1')).called(1);
    });

    test('getCategoryById returns null when category does not exist', () async {
      // Arrange
      when(mockFirestoreService.getCategoryById('non-existent'))
          .thenAnswer((_) async => null);

      // Act
      final category = await categoryService.getCategoryById('non-existent');

      // Assert
      expect(category, isNull);
      verify(mockFirestoreService.getCategoryById('non-existent')).called(1);
    });
  });
} 