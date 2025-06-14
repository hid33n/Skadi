import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock/services/sale_service.dart';
import 'package:stock/models/sale.dart';
import 'package:stock/services/firestore_service.dart';

class MockFirestoreService extends Mock implements FirestoreService {
  @override
  Future<List<Sale>> getSales() async {
    return [];
  }

  @override
  Future<void> addSale(Sale sale) async {}

  @override
  Future<void> deleteSale(String id) async {}
}

void main() {
  late MockFirestoreService mockFirestoreService;
  late SaleService saleService;

  setUp(() {
    mockFirestoreService = MockFirestoreService();
    saleService = SaleService(mockFirestoreService);
  });

  group('SaleService Tests', () {
    test('getSales should return list of sales', () async {
      // Arrange
      final mockSales = [
        Sale(
          id: '1',
          userId: 'user1',
          productId: 'prod1',
          productName: 'Product 1',
          quantity: 2,
          amount: 20.0,
          date: DateTime.now(),
          notes: 'Test sale 1',
        ),
        Sale(
          id: '2',
          userId: 'user1',
          productId: 'prod2',
          productName: 'Product 2',
          quantity: 3,
          amount: 30.0,
          date: DateTime.now(),
          notes: 'Test sale 2',
        ),
      ];

      when(mockFirestoreService.getSales())
          .thenAnswer((_) async => mockSales);

      // Act
      final sales = await saleService.getSales();

      // Assert
      expect(sales.length, 2);
      expect(sales[0].productName, 'Product 1');
      expect(sales[1].productName, 'Product 2');
      verify(mockFirestoreService.getSales()).called(1);
    });

    test('getSales should return empty list when no sales exist', () async {
      // Arrange
      when(mockFirestoreService.getSales())
          .thenAnswer((_) async => []);

      // Act
      final sales = await saleService.getSales();

      // Assert
      expect(sales, isEmpty);
      verify(mockFirestoreService.getSales()).called(1);
    });

    test('addSale should add sale to Firestore', () async {
      // Arrange
      final sale = Sale(
        id: '',
        userId: 'user1',
        productId: 'prod1',
        productName: 'New Product',
        quantity: 4,
        amount: 40.0,
        date: DateTime.now(),
        notes: 'New sale',
      );

      when(mockFirestoreService.addSale(sale))
          .thenAnswer((_) async => null);

      // Act
      await saleService.addSale(sale);

      // Assert
      verify(mockFirestoreService.addSale(sale)).called(1);
    });

    test('addSale throws error when quantity is zero', () async {
      // Arrange
      final sale = Sale(
        id: '',
        userId: 'user1',
        productId: 'prod1',
        productName: 'New Product',
        quantity: 0,
        amount: 0.0,
        date: DateTime.now(),
        notes: 'Invalid sale',
      );

      // Act & Assert
      expect(
        () => saleService.addSale(sale),
        throwsException,
      );
    });

    test('addSale throws error when amount is negative', () async {
      // Arrange
      final sale = Sale(
        id: '',
        userId: 'user1',
        productId: 'prod1',
        productName: 'New Product',
        quantity: 4,
        amount: -40.0,
        date: DateTime.now(),
        notes: 'Invalid sale',
      );

      // Act & Assert
      expect(
        () => saleService.addSale(sale),
        throwsException,
      );
    });

    test('deleteSale should delete sale from Firestore', () async {
      // Arrange
      when(mockFirestoreService.deleteSale('1'))
          .thenAnswer((_) async => null);

      // Act
      await saleService.deleteSale('1');

      // Assert
      verify(mockFirestoreService.deleteSale('1')).called(1);
    });

    test('getSalesStats should return correct statistics', () async {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      final mockSales = [
        Sale(
          id: '1',
          userId: 'user1',
          productId: 'prod1',
          productName: 'Product 1',
          quantity: 2,
          amount: 20.0,
          date: today,
          notes: 'Today sale',
        ),
        Sale(
          id: '2',
          userId: 'user1',
          productId: 'prod2',
          productName: 'Product 2',
          quantity: 3,
          amount: 30.0,
          date: firstDayOfMonth,
          notes: 'Month sale',
        ),
        Sale(
          id: '3',
          userId: 'user1',
          productId: 'prod3',
          productName: 'Product 3',
          quantity: 1,
          amount: 15.0,
          date: today.subtract(const Duration(days: 1)),
          notes: 'Yesterday sale',
        ),
      ];

      when(mockFirestoreService.getSales())
          .thenAnswer((_) async => mockSales);

      // Act
      final stats = await saleService.getSalesStats();

      // Assert
      expect(stats['todaySales'], 1);
      expect(stats['todayTotal'], 20.0);
      expect(stats['monthSales'], 2);
      expect(stats['monthTotal'], 50.0);
      expect(stats['totalSales'], 3);
      expect(stats['totalAmount'], 65.0);
      expect(stats['recentSales'].length, 3);
      expect(stats['dailySales'].length, 7);
    });

    test('getSalesStats should handle empty sales list', () async {
      // Arrange
      when(mockFirestoreService.getSales())
          .thenAnswer((_) async => []);

      // Act
      final stats = await saleService.getSalesStats();

      // Assert
      expect(stats['todaySales'], 0);
      expect(stats['todayTotal'], 0.0);
      expect(stats['monthSales'], 0);
      expect(stats['monthTotal'], 0.0);
      expect(stats['totalSales'], 0);
      expect(stats['totalAmount'], 0.0);
      expect(stats['recentSales'], isEmpty);
      expect(stats['dailySales'].length, 7);
    });
  });
} 