import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale.dart';
import '../utils/error_handler.dart';

class SaleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtener ventas de una organización específica
  Future<List<Sale>> getSales(String organizationId) async {
    try {
      final querySnapshot = await _firestore
          .collection('sales')
          .where('organizationId', isEqualTo: organizationId)
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Sale.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener venta por ID (verificando organización)
  Future<Sale?> getSale(String id, String organizationId) async {
    try {
      final doc = await _firestore.collection('sales').doc(id).get();
      if (doc.exists) {
        final sale = Sale.fromMap(doc.data()!, doc.id);
        // Verificar que la venta pertenece a la organización
        if (sale.organizationId == organizationId) {
          return sale;
        }
      }
      return null;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Agregar venta
  Future<String> addSale(Sale sale) async {
    try {
      final docRef = await _firestore.collection('sales').add(sale.toMap());
      return docRef.id;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Eliminar venta
  Future<void> deleteSale(String id, String organizationId) async {
    try {
      // Verificar que la venta pertenece a la organización antes de eliminar
      final sale = await getSale(id, organizationId);
      if (sale != null) {
        await _firestore.collection('sales').doc(id).delete();
      } else {
        throw AppError.validation('No tienes permisos para eliminar esta venta');
      }
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener ventas por rango de fechas
  Future<List<Sale>> getSalesByDateRange(
    DateTime startDate, 
    DateTime endDate, 
    String organizationId
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('sales')
          .where('organizationId', isEqualTo: organizationId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Sale.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener ventas por producto
  Future<List<Sale>> getSalesByProduct(String productId, String organizationId) async {
    try {
      final querySnapshot = await _firestore
          .collection('sales')
          .where('organizationId', isEqualTo: organizationId)
          .where('productId', isEqualTo: productId)
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Sale.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener estadísticas de ventas
  Future<Map<String, dynamic>> getSalesStats(String organizationId) async {
    try {
      final sales = await getSales(organizationId);
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

      // Calcular ventas por mes de los últimos 12 meses
      final monthlySales = <Map<String, dynamic>>[];
      for (var i = 11; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final monthEnd = DateTime(now.year, now.month - i + 1, 0);
        
        final monthSalesData = sales.where((s) {
          final saleDate = s.date;
          return saleDate.isAfter(month.subtract(const Duration(days: 1))) &&
                 saleDate.isBefore(monthEnd.add(const Duration(days: 1)));
        }).toList();

        monthlySales.add({
          'month': month,
          'total': monthSalesData.fold<double>(
            0,
            (sum, sale) => sum + sale.amount,
          ),
          'count': monthSalesData.length,
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
        'monthlySales': monthlySales,
        'averageSaleAmount': sales.isNotEmpty 
          ? sales.fold<double>(0, (sum, sale) => sum + sale.amount) / sales.length 
          : 0,
      };
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener productos más vendidos
  Future<List<Map<String, dynamic>>> getTopSellingProducts(String organizationId) async {
    try {
      final sales = await getSales(organizationId);
      final productSales = <String, Map<String, dynamic>>{};

      for (final sale in sales) {
        if (productSales.containsKey(sale.productId)) {
          productSales[sale.productId]!['quantity'] += sale.quantity;
          productSales[sale.productId]!['amount'] += sale.amount;
        } else {
          productSales[sale.productId] = {
            'productId': sale.productId,
            'productName': sale.productName,
            'quantity': sale.quantity,
            'amount': sale.amount,
          };
        }
      }

      final sortedProducts = productSales.values.toList()
        ..sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));

      return sortedProducts.take(10).toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }
} 