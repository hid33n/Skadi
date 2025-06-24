import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stock/services/category_service.dart';
import 'package:stock/models/category.dart';
import 'package:stock/utils/error_handler.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late CategoryService categoryService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    categoryService = CategoryService(fakeFirestore);
  });

  group('CategoryService Tests', () {
    test('getCategories returns list of categories', () async {
      // Arrange
      final now = DateTime.now();
      final category1 = Category(
        id: '1',
        name: 'Category 1',
        description: 'Description 1',
        createdAt: now,
        updatedAt: now,
      );
      final category2 = Category(
        id: '2',
        name: 'Category 2',
        description: 'Description 2',
        createdAt: now,
        updatedAt: now,
      );

      // Agregar datos de prueba al fake firestore
      await fakeFirestore.collection('categories').doc('1').set(category1.toMap());
      await fakeFirestore.collection('categories').doc('2').set(category2.toMap());

      // Act
      final categories = await categoryService.getCategories();

      // Assert
      expect(categories.length, 2);
      expect(categories[0].name, 'Category 1');
      expect(categories[1].name, 'Category 2');
    });

    test('getCategories returns empty list when no categories exist', () async {
      // Act
      final categories = await categoryService.getCategories();

      // Assert
      expect(categories, isEmpty);
    });

    test('addCategory adds a category', () async {
      // Arrange
      final now = DateTime.now();
      final category = Category(
        id: '',
        name: 'New Category',
        description: 'New Description',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final id = await categoryService.addCategory(category);

      // Assert
      expect(id, isNotEmpty);
      final addedCategory = await fakeFirestore.collection('categories').doc(id).get();
      expect(addedCategory.exists, isTrue);
      expect(addedCategory.data()!['name'], 'New Category');
    });

    test('updateCategory updates a category', () async {
      // Arrange
      final now = DateTime.now();
      final originalCategory = Category(
        id: '1',
        name: 'Original Category',
        description: 'Original Description',
        createdAt: now,
        updatedAt: now,
      );

      await fakeFirestore.collection('categories').doc('1').set(originalCategory.toMap());

      final updatedCategory = Category(
        id: '1',
        name: 'Updated Category',
        description: 'Updated Description',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      await categoryService.updateCategory('1', updatedCategory);

      // Assert
      final doc = await fakeFirestore.collection('categories').doc('1').get();
      expect(doc.data()!['name'], 'Updated Category');
      expect(doc.data()!['description'], 'Updated Description');
    });

    test('deleteCategory deletes a category', () async {
      // Arrange
      final now = DateTime.now();
      final category = Category(
        id: '1',
        name: 'Category to Delete',
        description: 'Description',
        createdAt: now,
        updatedAt: now,
      );

      await fakeFirestore.collection('categories').doc('1').set(category.toMap());

      // Act
      await categoryService.deleteCategory('1');

      // Assert
      final doc = await fakeFirestore.collection('categories').doc('1').get();
      expect(doc.exists, isFalse);
    });

    test('deleteCategory throws error when category has associated products', () async {
      // Arrange
      final now = DateTime.now();
      final category = Category(
        id: '1',
        name: 'Category with Products',
        description: 'Description',
        createdAt: now,
        updatedAt: now,
      );

      await fakeFirestore.collection('categories').doc('1').set(category.toMap());
      
      // Agregar un producto que use esta categoría
      await fakeFirestore.collection('products').add({
        'name': 'Test Product',
        'categoryId': '1',
      });

      // Act & Assert
      expect(
        () => categoryService.deleteCategory('1'),
        throwsA(isA<AppError>()),
      );
    });

    test('getCategoryById returns a category', () async {
      // Arrange
      final now = DateTime.now();
      final category = Category(
        id: '1',
        name: 'Category 1',
        description: 'Description 1',
        createdAt: now,
        updatedAt: now,
      );

      await fakeFirestore.collection('categories').doc('1').set(category.toMap());

      // Act
      final result = await categoryService.getCategoryById('1');

      // Assert
      expect(result?.name, 'Category 1');
      expect(result?.description, 'Description 1');
    });

    test('getCategoryById returns null when category does not exist', () async {
      // Act
      final result = await categoryService.getCategoryById('non-existent');

      // Assert
      expect(result, isNull);
    });

    test('searchCategories returns matching categories', () async {
      // Arrange
      final now = DateTime.now();
      final category1 = Category(
        id: '1',
        name: 'Electronics',
        description: 'Electronic devices',
        createdAt: now,
        updatedAt: now,
      );
      final category2 = Category(
        id: '2',
        name: 'Clothing',
        description: 'Clothing items',
        createdAt: now,
        updatedAt: now,
      );

      await fakeFirestore.collection('categories').doc('1').set(category1.toMap());
      await fakeFirestore.collection('categories').doc('2').set(category2.toMap());

      // Act
      final results = await categoryService.searchCategories('electronics');

      // Assert
      expect(results.length, 1);
      expect(results[0].name, 'Electronics');
    });

    test('getCategoryStats returns correct statistics', () async {
      // Arrange
      final now = DateTime.now();
      final category1 = Category(
        id: '1',
        name: 'Electronics',
        description: 'Electronic devices',
        createdAt: now,
        updatedAt: now,
      );
      final category2 = Category(
        id: '2',
        name: 'Clothing',
        description: 'Clothing items',
        createdAt: now,
        updatedAt: now,
      );

      await fakeFirestore.collection('categories').doc('1').set(category1.toMap());
      await fakeFirestore.collection('categories').doc('2').set(category2.toMap());

      // Agregar algunos productos
      await fakeFirestore.collection('products').add({
        'name': 'Phone',
        'categoryId': '1',
      });
      await fakeFirestore.collection('products').add({
        'name': 'Laptop',
        'categoryId': '1',
      });

      // Act
      final stats = await categoryService.getCategoryStats();

      // Assert
      expect(stats['totalCategories'], 2);
      expect(stats['categoriesWithProducts'], 1);
      expect(stats['emptyCategories'], 1);
      expect(stats['categoryDistribution']['Electronics'], 2);
      expect(stats['categoryDistribution']['Clothing'], 0);
    });
  });
} 