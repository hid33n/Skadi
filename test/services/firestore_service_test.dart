import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:stock/models/product.dart';
import 'package:stock/models/category.dart';
import 'package:stock/models/sale.dart';
import 'package:stock/models/movement.dart';
import 'package:stock/services/firestore_service.dart';
import 'package:stock/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockAuthService extends Mock implements AuthService {
  final User? _currentUser;
  final Stream<User?> _authStateChanges;

  MockAuthService({User? currentUser, Stream<User?>? authStateChanges})
      : _currentUser = currentUser,
        _authStateChanges = authStateChanges ?? Stream.value(currentUser);

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> get authStateChanges => _authStateChanges;

  @override
  Future<UserCredential> signInWithEmailOrUsername(String emailOrUsername, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<UserCredential> registerWithEmailAndPassword(String email, String password, String username) async {
    throw UnimplementedError();
  }

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile() async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateUserProfile(String username) async {}
}

class MockUser extends Mock implements User {
  @override
  String get uid => 'test-uid';
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockAuthService mockAuthService;
  late FirestoreService firestoreService;
  late MockUser mockUser;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockUser = MockUser();
    mockAuthService = MockAuthService(currentUser: mockUser);
    firestoreService = FirestoreService(mockAuthService);
  });

  group('FirestoreService Tests', () {
    test('getProducts returns list of products', () async {
      // Arrange
      final products = [
        Product(
          id: '1',
          name: 'Product 1',
          description: 'Description 1',
          price: 10.0,
          stock: 5,
          categoryId: 'cat1',
          minStock: 3,
          category: 'Category 1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: '2',
          name: 'Product 2',
          description: 'Description 2',
          price: 20.0,
          stock: 10,
          categoryId: 'cat2',
          minStock: 5,
          category: 'Category 2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (var product in products) {
        await fakeFirestore.collection('products').doc(product.id).set({
          ...product.toMap(),
          'userId': mockUser.uid,
        });
      }

      // Act
      final result = await firestoreService.getProducts();

      // Assert
      expect(result.length, 2);
      expect(result[0].name, 'Product 1');
      expect(result[1].name, 'Product 2');
    });

    test('getProducts returns empty list when no products exist', () async {
      // Act
      final result = await firestoreService.getProducts();

      // Assert
      expect(result, isEmpty);
    });

    test('addProduct adds a product', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'New Product',
        description: 'New Description',
        price: 15.0,
        stock: 8,
        categoryId: 'cat1',
        minStock: 4,
        category: 'Category 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await firestoreService.addProduct(product);

      // Assert
      final doc = await fakeFirestore.collection('products').doc(product.id).get();
      expect(doc.exists, true);
      expect(doc.data()?['name'], 'New Product');
      expect(doc.data()?['userId'], mockUser.uid);
    });

    test('updateProduct updates a product', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Updated Product',
        description: 'Updated Description',
        price: 25.0,
        stock: 12,
        categoryId: 'cat1',
        minStock: 6,
        category: 'Category 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore.collection('products').doc(product.id).set({
        ...product.toMap(),
        'userId': mockUser.uid,
      });

      // Act
      await firestoreService.updateProduct(product.id, product);

      // Assert
      final doc = await fakeFirestore.collection('products').doc(product.id).get();
      expect(doc.data()?['name'], 'Updated Product');
      expect(doc.data()?['userId'], mockUser.uid);
    });

    test('updateProduct throws error when product does not exist', () async {
      // Arrange
      final product = Product(
        id: 'non-existent',
        name: 'Updated Product',
        description: 'Updated Description',
        price: 25.0,
        stock: 12,
        categoryId: 'cat1',
        minStock: 6,
        category: 'Category 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => firestoreService.updateProduct(product.id, product),
        throwsException,
      );
    });

    test('deleteProduct deletes a product', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Product to Delete',
        description: 'Description',
        price: 10.0,
        stock: 5,
        categoryId: 'cat1',
        minStock: 3,
        category: 'Category 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore.collection('products').doc(product.id).set({
        ...product.toMap(),
        'userId': mockUser.uid,
      });

      // Act
      await firestoreService.deleteProduct(product.id);

      // Assert
      final doc = await fakeFirestore.collection('products').doc(product.id).get();
      expect(doc.exists, false);
    });

    test('deleteProduct throws error when product does not exist', () async {
      // Act & Assert
      expect(
        () => firestoreService.deleteProduct('non-existent'),
        throwsException,
      );
    });

    test('getLowStockProducts returns products with low stock', () async {
      // Arrange
      final products = [
        Product(
          id: '1',
          name: 'Low Stock Product',
          description: 'Description 1',
          price: 10.0,
          stock: 2,
          categoryId: 'cat1',
          minStock: 5,
          category: 'Category 1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: '2',
          name: 'Normal Stock Product',
          description: 'Description 2',
          price: 20.0,
          stock: 10,
          categoryId: 'cat2',
          minStock: 5,
          category: 'Category 2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (var product in products) {
        await fakeFirestore.collection('products').doc(product.id).set({
          ...product.toMap(),
          'userId': mockUser.uid,
        });
      }

      // Act
      final result = await firestoreService.getLowStockProducts();

      // Assert
      expect(result.length, 1);
      expect(result[0].name, 'Low Stock Product');
    });

    test('getLowStockProducts returns empty list when no products have low stock', () async {
      // Arrange
      final products = [
        Product(
          id: '1',
          name: 'Normal Stock Product 1',
          description: 'Description 1',
          price: 10.0,
          stock: 10,
          categoryId: 'cat1',
          minStock: 5,
          category: 'Category 1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: '2',
          name: 'Normal Stock Product 2',
          description: 'Description 2',
          price: 20.0,
          stock: 15,
          categoryId: 'cat2',
          minStock: 5,
          category: 'Category 2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (var product in products) {
        await fakeFirestore.collection('products').doc(product.id).set({
          ...product.toMap(),
          'userId': mockUser.uid,
        });
      }

      // Act
      final result = await firestoreService.getLowStockProducts();

      // Assert
      expect(result, isEmpty);
    });

    test('getDashboardData returns correct data structure', () async {
      // Arrange
      final now = DateTime.now();
      final sales = [
        Sale(
          id: '1',
          userId: 'user1',
          productId: 'prod1',
          productName: 'Product 1',
          amount: 20.0,
          quantity: 2,
          date: now,
        ),
        Sale(
          id: '2',
          userId: 'user1',
          productId: 'prod2',
          productName: 'Product 2',
          amount: 30.0,
          quantity: 3,
          date: now.subtract(const Duration(days: 1)),
        ),
      ];

      for (var sale in sales) {
        await fakeFirestore.collection('sales').doc(sale.id).set({
          ...sale.toMap(),
          'userId': mockUser.uid,
        });
      }

      // Act
      final result = await firestoreService.getDashboardData();

      // Assert
      expect(result['totalSales'], 50.0);
      expect(result['totalProducts'], 2);
      expect(result['recentSales'].length, 2);
    });
  });
} 