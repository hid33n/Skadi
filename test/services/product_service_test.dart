import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stock/services/product_service.dart';
import 'package:stock/models/product.dart';
import 'package:stock/utils/error_handler.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ProductService productService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    productService = ProductService(fakeFirestore);
  });

  group('ProductService Tests', () {
    test('getProducts returns list of products', () async {
      // Arrange
      final now = DateTime.now();
      final product1 = Product(
        id: '1',
        name: 'Product 1',
        description: 'Description 1',
        price: 10.0,
        stock: 5,
        minStock: 2,
        maxStock: 10,
        categoryId: 'cat1',
        createdAt: now,
        updatedAt: now,
      );
      final product2 = Product(
        id: '2',
        name: 'Product 2',
        description: 'Description 2',
        price: 20.0,
        stock: 10,
        minStock: 5,
        maxStock: 20,
        categoryId: 'cat2',
        createdAt: now,
        updatedAt: now,
      );

      await fakeFirestore.collection('products').doc('1').set(product1.toMap());
      await fakeFirestore.collection('products').doc('2').set(product2.toMap());

      // Act
      final products = await productService.getProducts();

      // Assert
      expect(products.length, 2);
      expect(products[0].name, 'Product 1');
      expect(products[1].name, 'Product 2');
    });

    test('getProducts returns empty list when no products exist', () async {
      // Act
      final products = await productService.getProducts();

      // Assert
      expect(products, isEmpty);
    });

    test('addProduct adds a product', () async {
      // Arrange
      final now = DateTime.now();
      final product = Product(
        id: '',
        name: 'New Product',
        description: 'New Description',
        price: 15.0,
        stock: 8,
        minStock: 3,
        maxStock: 15,
        categoryId: 'cat1',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final id = await productService.addProduct(product);

      // Assert
      expect(id, isNotEmpty);
      final addedProduct = await fakeFirestore.collection('products').doc(id).get();
      expect(addedProduct.exists, isTrue);
      expect(addedProduct.data()!['name'], 'New Product');
    });

    test('getProduct returns a product', () async {
      // Arrange
      final now = DateTime.now();
      final product = Product(
        id: '1',
        name: 'Test Product',
        description: 'Test Description',
        price: 15.0,
        stock: 8,
        minStock: 3,
        maxStock: 15,
        categoryId: 'cat1',
        createdAt: now,
        updatedAt: now,
      );

      await fakeFirestore.collection('products').doc('1').set(product.toMap());

      // Act
      final result = await productService.getProduct('1');

      // Assert
      expect(result?.name, 'Test Product');
      expect(result?.price, 15.0);
    });

    test('getProduct returns null when product does not exist', () async {
      // Act
      final result = await productService.getProduct('non-existent');

      // Assert
      expect(result, isNull);
    });

    test('updateProduct updates a product', () async {
      // Arrange
      final now = DateTime.now();
      final originalProduct = Product(
        id: '1',
        name: 'Original Product',
        description: 'Original Description',
        price: 10.0,
        stock: 5,
        minStock: 2,
        maxStock: 10,
        categoryId: 'cat1',
        createdAt: now,
        updatedAt: now,
      );

      await fakeFirestore.collection('products').doc('1').set(originalProduct.toMap());

      final updatedProduct = Product(
        id: '1',
        name: 'Updated Product',
        description: 'Updated Description',
        price: 20.0,
        stock: 10,
        minStock: 5,
        maxStock: 20,
        categoryId: 'cat1',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      await productService.updateProduct('1', updatedProduct);

      // Assert
      final doc = await fakeFirestore.collection('products').doc('1').get();
      expect(doc.data()!['name'], 'Updated Product');
      expect(doc.data()!['price'], 20.0);
    });

    test('deleteProduct deletes a product', () async {
      // Arrange
      final now = DateTime.now();
      final product = Product(
        id: '1',
        name: 'Product to Delete',
        description: 'Description',
        price: 10.0,
        stock: 5,
        minStock: 2,
        maxStock: 10,
        categoryId: 'cat1',
        createdAt: now,
        updatedAt: now,
      );

      await fakeFirestore.collection('products').doc('1').set(product.toMap());

      // Act
      await productService.deleteProduct('1');

      // Assert
      final doc = await fakeFirestore.collection('products').doc('1').get();
      expect(doc.exists, isFalse);
    });

    test('updateStock updates product stock', () async {
      // Arrange
      final now = DateTime.now();
      final product = Product(
        id: '1',
        name: 'Test Product',
        description: 'Test Description',
        price: 10.0,
        stock: 5,
        minStock: 2,
        maxStock: 10,
        categoryId: 'cat1',
        createdAt: now,
        updatedAt: now,
      );

      await fakeFirestore.collection('products').doc('1').set(product.toMap());

      // Act
      await productService.updateStock('1', 15);

      // Assert
      final doc = await fakeFirestore.collection('products').doc('1').get();
      expect(doc.data()!['stock'], 15);
    });

    test('searchProducts returns matching products', () async {
      // Arrange
      final now = DateTime.now();
      final product1 = Product(
        id: '1',
        name: 'iPhone',
        description: 'Smartphone',
        price: 999.0,
        stock: 5,
        minStock: 2,
        maxStock: 10,
        categoryId: 'cat1',
        createdAt: now,
        updatedAt: now,
      );
      final product2 = Product(
        id: '2',
        name: 'Samsung Galaxy',
        description: 'Android phone',
        price: 799.0,
        stock: 3,
        minStock: 2,
        maxStock: 10,
        categoryId: 'cat1',
        createdAt: now,
        updatedAt: now,
      );

      await fakeFirestore.collection('products').doc('1').set(product1.toMap());
      await fakeFirestore.collection('products').doc('2').set(product2.toMap());

      // Act
      final results = await productService.searchProducts('iPhone');

      // Assert
      expect(results.length, 1);
      expect(results[0].name, 'iPhone');
    });

    test('getProductsByCategory returns products in category', () async {
      // Arrange
      final now = DateTime.now();
      final product1 = Product(
        id: '1',
        name: 'iPhone',
        description: 'Smartphone',
        price: 999.0,
        stock: 5,
        minStock: 2,
        maxStock: 10,
        categoryId: 'electronics',
        createdAt: now,
        updatedAt: now,
      );
      final product2 = Product(
        id: '2',
        name: 'T-Shirt',
        description: 'Cotton shirt',
        price: 25.0,
        stock: 20,
        minStock: 5,
        maxStock: 50,
        categoryId: 'clothing',
        createdAt: now,
        updatedAt: now,
      );

      await fakeFirestore.collection('products').doc('1').set(product1.toMap());
      await fakeFirestore.collection('products').doc('2').set(product2.toMap());

      // Act
      final results = await productService.getProductsByCategory('electronics');

      // Assert
      expect(results.length, 1);
      expect(results[0].name, 'iPhone');
    });

    test('getLowStockProducts returns products with low stock', () async {
      // Arrange
      final now = DateTime.now();
      final product1 = Product(
        id: '1',
        name: 'Low Stock Product',
        description: 'Description',
        price: 10.0,
        stock: 1,
        minStock: 5,
        maxStock: 10,
        categoryId: 'cat1',
        createdAt: now,
        updatedAt: now,
      );
      final product2 = Product(
        id: '2',
        name: 'Normal Stock Product',
        description: 'Description',
        price: 10.0,
        stock: 10,
        minStock: 5,
        maxStock: 20,
        categoryId: 'cat1',
        createdAt: now,
        updatedAt: now,
      );

      await fakeFirestore.collection('products').doc('1').set(product1.toMap());
      await fakeFirestore.collection('products').doc('2').set(product2.toMap());

      // Act
      final results = await productService.getLowStockProducts();

      // Assert
      expect(results.length, 1);
      expect(results[0].name, 'Low Stock Product');
    });

    test('getProductStats returns correct statistics', () async {
      // Arrange
      final now = DateTime.now();
      final product1 = Product(
        id: '1',
        name: 'Product 1',
        description: 'Description',
        price: 10.0,
        stock: 5,
        minStock: 2,
        maxStock: 10,
        categoryId: 'cat1',
        createdAt: now,
        updatedAt: now,
      );
      final product2 = Product(
        id: '2',
        name: 'Product 2',
        description: 'Description',
        price: 20.0,
        stock: 0,
        minStock: 5,
        maxStock: 20,
        categoryId: 'cat1',
        createdAt: now,
        updatedAt: now,
      );

      await fakeFirestore.collection('products').doc('1').set(product1.toMap());
      await fakeFirestore.collection('products').doc('2').set(product2.toMap());

      // Act
      final stats = await productService.getProductStats();

      // Assert
      expect(stats['totalProducts'], 2);
      expect(stats['totalValue'], 50.0); // 10*5 + 20*0
      expect(stats['outOfStockProducts'], 1);
      expect(stats['averagePrice'], 15.0); // (10+20)/2
    });
  });
} 