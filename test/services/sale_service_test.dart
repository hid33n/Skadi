import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stock/services/sale_service.dart';
import 'package:stock/models/sale.dart';
import 'package:stock/utils/error_handler.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late SaleService saleService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    saleService = SaleService(fakeFirestore);
  });

  group('SaleService Tests', () {
    test('getSales returns list of sales', () async {
      // Arrange
      final now = DateTime.now();
      final sale1 = Sale(
        id: '1',
        userId: 'user1',
        productId: 'product1',
        productName: 'Product 1',
        amount: 100.0,
        quantity: 2,
        date: now,
        notes: 'Test sale 1',
      );
      final sale2 = Sale(
        id: '2',
        userId: 'user2',
        productId: 'product2',
        productName: 'Product 2',
        amount: 150.0,
        quantity: 1,
        date: now,
        notes: 'Test sale 2',
      );

      await fakeFirestore.collection('sales').doc('1').set(sale1.toMap());
      await fakeFirestore.collection('sales').doc('2').set(sale2.toMap());

      // Act
      final sales = await saleService.getSales();

      // Assert
      expect(sales.length, 2);
      expect(sales[0].productName, 'Product 1');
      expect(sales[1].productName, 'Product 2');
    });

    test('getSales returns empty list when no sales exist', () async {
      // Act
      final sales = await saleService.getSales();

      // Assert
      expect(sales, isEmpty);
    });

    test('addSale adds a sale', () async {
      // Arrange
      final now = DateTime.now();
      final sale = Sale(
        id: '',
        userId: 'user1',
        productId: 'product1',
        productName: 'New Product',
        amount: 200.0,
        quantity: 3,
        date: now,
        notes: 'New sale',
      );

      // Act
      final id = await saleService.addSale(sale);

      // Assert
      expect(id, isNotEmpty);
      final addedSale = await fakeFirestore.collection('sales').doc(id).get();
      expect(addedSale.exists, isTrue);
      expect(addedSale.data()!['productName'], 'New Product');
    });

    test('getSale returns a sale', () async {
      // Arrange
      final now = DateTime.now();
      final sale = Sale(
        id: '1',
        userId: 'user1',
        productId: 'product1',
        productName: 'Test Product',
        amount: 100.0,
        quantity: 2,
        date: now,
        notes: 'Test sale',
      );

      await fakeFirestore.collection('sales').doc('1').set(sale.toMap());

      // Act
      final result = await saleService.getSale('1');

      // Assert
      expect(result?.productName, 'Test Product');
      expect(result?.amount, 100.0);
    });

    test('getSale returns null when sale does not exist', () async {
      // Act
      final result = await saleService.getSale('non-existent');

      // Assert
      expect(result, isNull);
    });

    test('updateSale updates a sale', () async {
      // Arrange
      final now = DateTime.now();
      final originalSale = Sale(
        id: '1',
        userId: 'user1',
        productId: 'product1',
        productName: 'Original Product',
        amount: 100.0,
        quantity: 2,
        date: now,
        notes: 'Original sale',
      );

      await fakeFirestore.collection('sales').doc('1').set(originalSale.toMap());

      final updatedSale = Sale(
        id: '1',
        userId: 'user1',
        productId: 'product1',
        productName: 'Updated Product',
        amount: 150.0,
        quantity: 3,
        date: now,
        notes: 'Updated sale',
      );

      // Act
      await saleService.updateSale('1', updatedSale);

      // Assert
      final doc = await fakeFirestore.collection('sales').doc('1').get();
      expect(doc.data()!['productName'], 'Updated Product');
      expect(doc.data()!['amount'], 150.0);
    });

    test('deleteSale deletes a sale', () async {
      // Arrange
      final now = DateTime.now();
      final sale = Sale(
        id: '1',
        userId: 'user1',
        productId: 'product1',
        productName: 'Product to Delete',
        amount: 100.0,
        quantity: 2,
        date: now,
        notes: 'Sale to delete',
      );

      await fakeFirestore.collection('sales').doc('1').set(sale.toMap());

      // Act
      await saleService.deleteSale('1');

      // Assert
      final doc = await fakeFirestore.collection('sales').doc('1').get();
      expect(doc.exists, isFalse);
    });

    test('getSalesByDateRange returns sales in date range', () async {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      final sale1 = Sale(
        id: '1',
        userId: 'user1',
        productId: 'product1',
        productName: 'Product 1',
        amount: 100.0,
        quantity: 2,
        date: now,
        notes: 'Today sale',
      );
      final sale2 = Sale(
        id: '2',
        userId: 'user2',
        productId: 'product2',
        productName: 'Product 2',
        amount: 150.0,
        quantity: 1,
        date: yesterday,
        notes: 'Yesterday sale',
      );

      await fakeFirestore.collection('sales').doc('1').set(sale1.toMap());
      await fakeFirestore.collection('sales').doc('2').set(sale2.toMap());

      // Act
      final results = await saleService.getSalesByDateRange(yesterday, tomorrow);

      // Assert
      expect(results.length, 2);
    });

    test('getSalesByProduct returns sales for specific product', () async {
      // Arrange
      final now = DateTime.now();
      final sale1 = Sale(
        id: '1',
        userId: 'user1',
        productId: 'product1',
        productName: 'Product 1',
        amount: 100.0,
        quantity: 2,
        date: now,
        notes: 'Sale 1',
      );
      final sale2 = Sale(
        id: '2',
        userId: 'user2',
        productId: 'product2',
        productName: 'Product 2',
        amount: 150.0,
        quantity: 1,
        date: now,
        notes: 'Sale 2',
      );

      await fakeFirestore.collection('sales').doc('1').set(sale1.toMap());
      await fakeFirestore.collection('sales').doc('2').set(sale2.toMap());

      // Act
      final results = await saleService.getSalesByProduct('product1');

      // Assert
      expect(results.length, 1);
      expect(results[0].productId, 'product1');
    });

    test('getSalesStats returns correct statistics', () async {
      // Arrange
      final now = DateTime.now();
      final sale1 = Sale(
        id: '1',
        userId: 'user1',
        productId: 'product1',
        productName: 'Product 1',
        amount: 100.0,
        quantity: 2,
        date: now,
        notes: 'Sale 1',
      );
      final sale2 = Sale(
        id: '2',
        userId: 'user2',
        productId: 'product2',
        productName: 'Product 2',
        amount: 150.0,
        quantity: 1,
        date: now,
        notes: 'Sale 2',
      );

      await fakeFirestore.collection('sales').doc('1').set(sale1.toMap());
      await fakeFirestore.collection('sales').doc('2').set(sale2.toMap());

      // Act
      final stats = await saleService.getSalesStats();

      // Assert
      expect(stats['totalSales'], 2);
      expect(stats['totalRevenue'], 250.0);
      expect(stats['averageSale'], 125.0);
      expect(stats['monthlyStats'], isA<Map<String, double>>());
    });

    test('getTopSellingProducts returns top selling products', () async {
      // Arrange
      final now = DateTime.now();
      final sale1 = Sale(
        id: '1',
        userId: 'user1',
        productId: 'product1',
        productName: 'Product 1',
        amount: 100.0,
        quantity: 2,
        date: now,
        notes: 'Sale 1',
      );
      final sale2 = Sale(
        id: '2',
        userId: 'user2',
        productId: 'product1',
        productName: 'Product 1',
        amount: 150.0,
        quantity: 1,
        date: now,
        notes: 'Sale 2',
      );
      final sale3 = Sale(
        id: '3',
        userId: 'user3',
        productId: 'product2',
        productName: 'Product 2',
        amount: 200.0,
        quantity: 1,
        date: now,
        notes: 'Sale 3',
      );

      await fakeFirestore.collection('sales').doc('1').set(sale1.toMap());
      await fakeFirestore.collection('sales').doc('2').set(sale2.toMap());
      await fakeFirestore.collection('sales').doc('3').set(sale3.toMap());

      // Act
      final topProducts = await saleService.getTopSellingProducts();

      // Assert
      expect(topProducts.length, 2);
      expect(topProducts[0]['productId'], 'product1');
      expect(topProducts[0]['salesCount'], 2);
      expect(topProducts[1]['productId'], 'product2');
      expect(topProducts[1]['salesCount'], 1);
    });
  });
} 