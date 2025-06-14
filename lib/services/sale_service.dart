import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale.dart';
import 'firestore_service.dart';

class SaleService {
  final FirestoreService _firestoreService;

  SaleService(this._firestoreService);

  Future<List<Sale>> getSales() async {
    return _firestoreService.getSales();
  }

  Future<void> addSale(Sale sale) async {
    await _firestoreService.addSale(sale);
  }

  Future<void> deleteSale(String id) async {
    await _firestoreService.deleteSale(id);
  }

  Future<Map<String, dynamic>> getSalesStats() async {
    final sales = await getSales();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    // Calcular ventas del día
    final todaySales = sales.where((s) {
      final saleDate = s.date;
      return saleDate.isAfter(today) || saleDate.isAtSameMomentAs(today);
    }).toList();

    // Calcular ventas del mes
    final monthSales = sales.where((s) {
      final saleDate = s.date;
      return saleDate.isAfter(firstDayOfMonth) || saleDate.isAtSameMomentAs(firstDayOfMonth);
    }).toList();

    // Calcular ventas diarias de los últimos 7 días
    final dailySales = <Map<String, dynamic>>[];
    for (var i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final daySales = sales.where((s) {
        final saleDate = s.date;
        return saleDate.year == date.year &&
            saleDate.month == date.month &&
            saleDate.day == date.day;
      }).toList();

      dailySales.add({
        'date': date,
        'total': daySales.fold<double>(
          0,
          (sum, sale) => sum + sale.amount,
        ),
        'count': daySales.length,
      });
    }

    return {
      'todaySales': todaySales.length,
      'todayTotal': todaySales.fold<double>(
        0,
        (sum, sale) => sum + sale.amount,
      ),
      'monthSales': monthSales.length,
      'monthTotal': monthSales.fold<double>(
        0,
        (sum, sale) => sum + sale.amount,
      ),
      'totalSales': sales.length,
      'totalAmount': sales.fold<double>(
        0,
        (sum, sale) => sum + sale.amount,
      ),
      'recentSales': sales.take(5).map((s) => s.toMap()).toList(),
      'dailySales': dailySales,
    };
  }
} 