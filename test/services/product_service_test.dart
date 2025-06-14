import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock/services/product_service.dart';
import 'package:stock/models/product.dart';
import 'package:stock/services/firestore_service.dart';
import '../test_helper.dart';

class MockFirestoreService extends Mock implements FirestoreService {
  @override
  Future<List<Product>> getProducts() async {
    return [];
  }

  @override
  Future<void> addProduct(Product product) async {}

  @override
  Future<void> updateProduct(String id, Product product) async {}

  @override
  Future<void> deleteProduct(String id) async {}
}

void main() {
  late MockFirestoreService mockFirestoreService;
  late ProductService productService;

  setUp(() {
    mockFirestoreService = MockFirestoreService();
    productService = ProductService(mockFirestoreService);
  });

  group('ProductService Tests', () {
    test('getProducts returns list of products', () async {
      // Arrange
      final mockProducts = [
        Product(
          id: '1',
          name: 'Product 1',
          description: 'Description 1',
          price: 10.0,
          stock: 5,
          minStock: 2,
          maxStock: 10,
          categoryId: 'cat1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: '2',
          name: 'Product 2',
          description: 'Description 2',
          price: 20.0,
          stock: 10,
          minStock: 5,
          maxStock: 20,
          categoryId: 'cat2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockFirestoreService.getProducts())
          .thenAnswer((_) async => mockProducts);

      // Act
      final products = await productService.getProducts();

      // Assert
      expect(products.length, 2);
      expect(products[0].name, 'Product 1');
      expect(products[1].name, 'Product 2');
      verify(mockFirestoreService.getProducts()).called(1);
    });

    test('getProducts returns empty list when no products exist', () async {
      // Arrange
      when(mockFirestoreService.getProducts())
          .thenAnswer((_) async => []);

      // Act
      final products = await productService.getProducts();

      // Assert
      expect(products, isEmpty);
      verify(mockFirestoreService.getProducts()).called(1);
    });

    test('addProduct adds a product', () async {
      // Arrange
      final product = Product(
        id: '',
        name: 'New Product',
        description: 'New Description',
        price: 15.0,
        stock: 8,
        minStock: 3,
        maxStock: 15,
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockFirestoreService.addProduct(product))
          .thenAnswer((_) async {});

      // Act
      await productService.addProduct(product);

      // Assert
      verify(mockFirestoreService.addProduct(product)).called(1);
    });

    test('addProduct throws error when name is empty', () async {
      // Arrange
      final product = Product(
        id: '',
        name: '',
        description: 'New Description',
        price: 15.0,
        stock: 8,
        minStock: 3,
        maxStock: 15,
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => productService.addProduct(product),
        throwsException,
      );
    });

    test('addProduct throws error when price is negative', () async {
      // Arrange
      final product = Product(
        id: '',
        name: 'New Product',
        description: 'New Description',
        price: -15.0,
        stock: 8,
        minStock: 3,
        maxStock: 15,
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => productService.addProduct(product),
        throwsException,
      );
    });

    test('addProduct throws error when stock is negative', () async {
      // Arrange
      final product = Product(
        id: '',
        name: 'New Product',
        description: 'New Description',
        price: 15.0,
        stock: -8,
        minStock: 3,
        maxStock: 15,
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => productService.addProduct(product),
        throwsException,
      );
    });

    test('addProduct throws error when minStock is negative', () async {
      // Arrange
      final product = Product(
        id: '',
        name: 'New Product',
        description: 'New Description',
        price: 15.0,
        stock: 8,
        minStock: -3,
        maxStock: 15,
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => productService.addProduct(product),
        throwsException,
      );
    });

    test('updateProduct updates a product', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Updated Product',
        description: 'Updated Description',
        price: 25.0,
        stock: 15,
        minStock: 5,
        maxStock: 25,
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockFirestoreService.updateProduct('1', product))
          .thenAnswer((_) async {});

      // Act
      await productService.updateProduct(product);

      // Assert
      verify(mockFirestoreService.updateProduct('1', product)).called(1);
    });

    test('updateProduct throws error when name is empty', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: '',
        description: 'Updated Description',
        price: 25.0,
        stock: 15,
        minStock: 5,
        maxStock: 25,
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => productService.updateProduct(product),
        throwsException,
      );
    });

    test('updateProduct throws error when price is negative', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Updated Product',
        description: 'Updated Description',
        price: -25.0,
        stock: 15,
        minStock: 5,
        maxStock: 25,
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => productService.updateProduct(product),
        throwsException,
      );
    });

    test('updateProduct throws error when stock is negative', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Updated Product',
        description: 'Updated Description',
        price: 25.0,
        stock: -15,
        minStock: 5,
        maxStock: 25,
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => productService.updateProduct(product),
        throwsException,
      );
    });

    test('updateProduct throws error when minStock is negative', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Updated Product',
        description: 'Updated Description',
        price: 25.0,
        stock: 15,
        minStock: -5,
        maxStock: 25,
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => productService.updateProduct(product),
        throwsException,
      );
    });

    test('deleteProduct deletes a product', () async {
      // Arrange
      when(mockFirestoreService.deleteProduct('1'))
          .thenAnswer((_) async {});

      // Act
      await productService.deleteProduct('1');

      // Assert
      verify(mockFirestoreService.deleteProduct('1')).called(1);
    });

    test('updateStock updates product stock', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Product 1',
        description: 'Description 1',
        price: 10.0,
        stock: 5,
        minStock: 2,
        maxStock: 10,
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await mockFirestoreService.addProduct(product);

      // Act
      await productService.updateStock('1', 10);

      // Assert
      final products = await mockFirestoreService.getProducts();
      expect(products.length, 1);
      expect(products[0].stock, 10);
    });

    test('updateStock throws error when product not found', () async {
      // Arrange
      when(mockFirestoreService.getProducts())
          .thenAnswer((_) async => []);

      // Act & Assert
      expect(
        () => productService.updateStock('non-existent', 10),
        throwsException,
      );
    });

    test('updateStock throws error when new stock is negative', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Product 1',
        description: 'Description 1',
        price: 10.0,
        stock: 5,
        minStock: 2,
        maxStock: 10,
        categoryId: 'cat1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockFirestoreService.getProducts())
          .thenAnswer((_) async => [product]);

      // Act & Assert
      expect(
        () => productService.updateStock('1', -10),
        throwsException,
      );
    });
  });
} 