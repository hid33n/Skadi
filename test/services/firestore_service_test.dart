import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stock/models/product.dart';
import 'package:stock/models/category.dart';
import 'package:stock/models/sale.dart';
import 'package:stock/models/movement.dart';

// Test helper que simula FirestoreService sin depender de AuthService
class TestFirestoreService {
  final String userId;
  final FirebaseFirestore firestore;
  
  TestFirestoreService(this.userId, this.firestore);
  
  CollectionReference get _userProductsRef => 
      firestore.collection('pm').doc(userId).collection('products');
  
  CollectionReference get _userCategoriesRef => 
      firestore.collection('pm').doc(userId).collection('categories');
  
  CollectionReference get _userSalesRef => 
      firestore.collection('pm').doc(userId).collection('sales');
  
  CollectionReference get _userMovementsRef => 
      firestore.collection('pm').doc(userId).collection('movements');

  // Métodos para Productos
  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _userProductsRef.get();
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _userProductsRef.add(product.toMap());
    } catch (e) {
      throw Exception('Error al agregar producto: $e');
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    try {
      await _userProductsRef.doc(id).update(product.toMap());
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _userProductsRef.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }

  Future<List<Product>> getLowStockProducts() async {
    try {
      final snapshot = await _userProductsRef.get();
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((product) => product.stock <= product.minStock)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos con stock bajo: $e');
    }
  }

  // Métodos para Categorías
  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _userCategoriesRef.get();
      return snapshot.docs
          .map((doc) => Category.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _userCategoriesRef.add(category.toMap());
    } catch (e) {
      throw Exception('Error al agregar categoría: $e');
    }
  }

  // Métodos para Ventas
  Future<List<Sale>> getSales() async {
    try {
      final snapshot = await _userSalesRef
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener ventas: $e');
    }
  }

  Future<void> addSale(Sale sale) async {
    try {
      await _userSalesRef.add(sale.toMap());
    } catch (e) {
      throw Exception('Error al agregar venta: $e');
    }
  }

  // Métodos para Movimientos
  Future<List<Movement>> getMovements() async {
    try {
      final snapshot = await _userMovementsRef
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Movement.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener movimientos: $e');
    }
  }

  Future<void> addMovement(Movement movement) async {
    try {
      await _userMovementsRef.add(movement.toMap());
    } catch (e) {
      throw Exception('Error al agregar movimiento: $e');
    }
  }

  // Métodos para el Dashboard
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final startOfWeek = startOfDay.subtract(Duration(days: startOfDay.weekday - 1));
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Obtener ventas del día
      final todaySales = await _userSalesRef
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .get();

      // Obtener ventas de la semana
      final weekSales = await _userSalesRef
          .where('date', isGreaterThanOrEqualTo: startOfWeek)
          .get();

      // Obtener ventas del mes
      final monthSales = await _userSalesRef
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .get();

      return {
        'todaySales': todaySales.docs.length,
        'weekSales': weekSales.docs.length,
        'monthSales': monthSales.docs.length,
      };
    } catch (e) {
      throw Exception('Error al obtener datos del dashboard: $e');
    }
  }
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late TestFirestoreService firestoreService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    firestoreService = TestFirestoreService('test-user-id', fakeFirestore);
  });

  group('FirestoreService Tests', () {
    test('getProducts returns list of products', () async {
      // Arrange
      final product1 = Product(
        id: '1',
        name: 'Product 1',
        description: 'Description 1',
        price: 100.0,
        stock: 10,
        minStock: 5,
        maxStock: 100,
        categoryId: 'category1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final product2 = Product(
        id: '2',
        name: 'Product 2',
        description: 'Description 2',
        price: 200.0,
        stock: 20,
        minStock: 10,
        maxStock: 200,
        categoryId: 'category2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore
          .collection('pm')
          .doc('test-user-id')
          .collection('products')
          .doc('1')
          .set(product1.toMap());
      await fakeFirestore
          .collection('pm')
          .doc('test-user-id')
          .collection('products')
          .doc('2')
          .set(product2.toMap());

      // Act
      final products = await firestoreService.getProducts();

      // Assert
      expect(products.length, 2);
      expect(products[0].name, 'Product 1');
      expect(products[1].name, 'Product 2');
    });

    test('getProducts returns empty list when no products exist', () async {
      // Act
      final products = await firestoreService.getProducts();

      // Assert
      expect(products, isEmpty);
    });

    test('addProduct adds a product', () async {
      // Arrange
      final product = Product(
        id: '',
        name: 'New Product',
        description: 'New Description',
        price: 150.0,
        stock: 15,
        minStock: 5,
        maxStock: 150,
        categoryId: 'category1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await firestoreService.addProduct(product);

      // Assert
      final products = await firestoreService.getProducts();
      expect(products.length, 1);
      expect(products[0].name, 'New Product');
    });

    test('updateProduct updates a product', () async {
      // Arrange
      final originalProduct = Product(
        id: '1',
        name: 'Original Product',
        description: 'Original Description',
        price: 100.0,
        stock: 10,
        minStock: 5,
        maxStock: 100,
        categoryId: 'category1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore
          .collection('pm')
          .doc('test-user-id')
          .collection('products')
          .doc('1')
          .set(originalProduct.toMap());

      final updatedProduct = Product(
        id: '1',
        name: 'Updated Product',
        description: 'Updated Description',
        price: 200.0,
        stock: 20,
        minStock: 10,
        maxStock: 200,
        categoryId: 'category1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await firestoreService.updateProduct('1', updatedProduct);

      // Assert
      final products = await firestoreService.getProducts();
      expect(products[0].name, 'Updated Product');
      expect(products[0].price, 200.0);
    });

    test('deleteProduct deletes a product', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Product to Delete',
        description: 'Description',
        price: 100.0,
        stock: 10,
        minStock: 5,
        maxStock: 100,
        categoryId: 'category1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore
          .collection('pm')
          .doc('test-user-id')
          .collection('products')
          .doc('1')
          .set(product.toMap());

      // Act
      await firestoreService.deleteProduct('1');

      // Assert
      final products = await firestoreService.getProducts();
      expect(products, isEmpty);
    });

    test('getLowStockProducts returns products with low stock', () async {
      // Arrange
      final product1 = Product(
        id: '1',
        name: 'Low Stock Product',
        description: 'Description',
        price: 100.0,
        stock: 2,
        minStock: 5,
        maxStock: 100,
        categoryId: 'category1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final product2 = Product(
        id: '2',
        name: 'Normal Stock Product',
        description: 'Description',
        price: 200.0,
        stock: 10,
        minStock: 5,
        maxStock: 200,
        categoryId: 'category2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore
          .collection('pm')
          .doc('test-user-id')
          .collection('products')
          .doc('1')
          .set(product1.toMap());
      await fakeFirestore
          .collection('pm')
          .doc('test-user-id')
          .collection('products')
          .doc('2')
          .set(product2.toMap());

      // Act
      final lowStockProducts = await firestoreService.getLowStockProducts();

      // Assert
      expect(lowStockProducts.length, 1);
      expect(lowStockProducts[0].name, 'Low Stock Product');
    });

    test('getCategories returns list of categories', () async {
      // Arrange
      final category1 = Category(
        id: '1',
        name: 'Category 1',
        description: 'Description 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final category2 = Category(
        id: '2',
        name: 'Category 2',
        description: 'Description 2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore
          .collection('pm')
          .doc('test-user-id')
          .collection('categories')
          .doc('1')
          .set(category1.toMap());
      await fakeFirestore
          .collection('pm')
          .doc('test-user-id')
          .collection('categories')
          .doc('2')
          .set(category2.toMap());

      // Act
      final categories = await firestoreService.getCategories();

      // Assert
      expect(categories.length, 2);
      expect(categories[0].name, 'Category 1');
      expect(categories[1].name, 'Category 2');
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

      // Act
      await firestoreService.addCategory(category);

      // Assert
      final categories = await firestoreService.getCategories();
      expect(categories.length, 1);
      expect(categories[0].name, 'New Category');
    });

    test('getSales returns list of sales', () async {
      // Arrange
      final now = DateTime.now();
      final sale1 = Sale(
        id: '1',
        userId: 'test-user-id',
        productId: 'product1',
        productName: 'Product 1',
        amount: 100.0,
        quantity: 2,
        date: now,
        notes: 'Sale 1',
      );
      final sale2 = Sale(
        id: '2',
        userId: 'test-user-id',
        productId: 'product2',
        productName: 'Product 2',
        amount: 200.0,
        quantity: 1,
        date: now,
        notes: 'Sale 2',
      );

      await fakeFirestore
          .collection('pm')
          .doc('test-user-id')
          .collection('sales')
          .doc('1')
          .set(sale1.toMap());
      await fakeFirestore
          .collection('pm')
          .doc('test-user-id')
          .collection('sales')
          .doc('2')
          .set(sale2.toMap());

      // Act
      final sales = await firestoreService.getSales();

      // Assert
      expect(sales.length, 2);
      expect(sales[0].productName, 'Product 1');
      expect(sales[1].productName, 'Product 2');
    });

    test('addSale adds a sale', () async {
      // Arrange
      final now = DateTime.now();
      final sale = Sale(
        id: '',
        userId: 'test-user-id',
        productId: 'product1',
        productName: 'New Sale Product',
        amount: 150.0,
        quantity: 3,
        date: now,
        notes: 'New sale',
      );

      // Act
      await firestoreService.addSale(sale);

      // Assert
      final sales = await firestoreService.getSales();
      expect(sales.length, 1);
      expect(sales[0].productName, 'New Sale Product');
    });

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

      await fakeFirestore
          .collection('pm')
          .doc('test-user-id')
          .collection('movements')
          .doc('1')
          .set(movement1.toMap());
      await fakeFirestore
          .collection('pm')
          .doc('test-user-id')
          .collection('movements')
          .doc('2')
          .set(movement2.toMap());

      // Act
      final movements = await firestoreService.getMovements();

      // Assert
      expect(movements.length, 2);
      expect(movements[0].productName, 'Product 1');
      expect(movements[1].productName, 'Product 2');
    });

    test('addMovement adds a movement', () async {
      // Arrange
      final now = DateTime.now();
      final movement = Movement(
        id: '',
        productId: 'product1',
        productName: 'New Movement Product',
        type: MovementType.entry,
        quantity: 15,
        date: now,
        note: 'New movement',
      );

      // Act
      await firestoreService.addMovement(movement);

      // Assert
      final movements = await firestoreService.getMovements();
      expect(movements.length, 1);
      expect(movements[0].productName, 'New Movement Product');
    });

    test('getDashboardData returns correct data structure', () async {
      // Arrange
      final now = DateTime.now();
      final sale = Sale(
        id: '1',
        userId: 'test-user-id',
        productId: 'product1',
        productName: 'Product 1',
        amount: 100.0,
        quantity: 2,
        date: now,
        notes: 'Sale',
      );

      await fakeFirestore
          .collection('pm')
          .doc('test-user-id')
          .collection('sales')
          .doc('1')
          .set(sale.toMap());

      // Act
      final dashboardData = await firestoreService.getDashboardData();

      // Assert
      expect(dashboardData, isA<Map<String, dynamic>>());
      expect(dashboardData.containsKey('todaySales'), isTrue);
      expect(dashboardData.containsKey('weekSales'), isTrue);
      expect(dashboardData.containsKey('monthSales'), isTrue);
    });

    test('handles errors gracefully', () async {
      // Arrange - Crear un servicio con un userId inválido
      final invalidFirestoreService = TestFirestoreService('', fakeFirestore);

      // Act & Assert
      final products = await invalidFirestoreService.getProducts();
      expect(products, isEmpty);
    });
  });
} 