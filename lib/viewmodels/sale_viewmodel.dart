import 'package:flutter/foundation.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../services/firestore_service.dart';
import '../utils/error_handler.dart';
import '../utils/error_handler.dart';
import 'package:flutter/material.dart';

class SaleViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<Sale> _sales = [];
  bool _isLoading = false;
  AppError? _error;

  SaleViewModel(this._firestoreService);

  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  double get totalSales => _sales.fold(0, (sum, sale) => sum + sale.amount);
  int get salesCount => _sales.length;

  Future<void> loadSales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sales = await _firestoreService.getSales();
    } catch (e) {
      _error = AppError.fromException(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSale(Sale sale) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.addSale(sale);
      await loadSales();
      return true;
    } catch (e) {
      _error = AppError.fromException(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSale(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.deleteSale(id);
      await loadSales();
      return true;
    } catch (e) {
      _error = AppError.fromException(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double calculateTotalSales() {
    return _sales.fold<double>(0, (sum, sale) => sum + sale.amount);
  }

  List<Sale> getRecentSales() {
    return _sales.take(5).toList();
  }

  List<Sale> searchSales(String query) {
    if (query.isEmpty) return _sales;
    
    final lowercaseQuery = query.toLowerCase();
    return _sales.where((sale) {
      return sale.productName.toLowerCase().contains(lowercaseQuery) ||
          (sale.notes?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  List<Sale> getSalesByDateRange(DateTime start, DateTime end) {
    return _sales.where((sale) {
      return sale.date.isAfter(start) && sale.date.isBefore(end);
    }).toList();
  }

  Map<String, double> getTopSellingProducts() {
    final productSales = <String, double>{};
    
    for (var sale in _sales) {
      productSales[sale.productId] = (productSales[sale.productId] ?? 0) + sale.amount;
    }

    final sortedProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedProducts.take(5));
  }

  List<SalesDataPoint> getSalesByPeriod() {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    
    // Agrupar ventas por día
    final Map<String, double> dailySales = {};
    for (var i = 0; i < 7; i++) {
      final date = lastWeek.add(Duration(days: i));
      final dateStr = '${date.day}/${date.month}';
      dailySales[dateStr] = 0;
    }

    // Sumar ventas por día
    for (var sale in _sales) {
      if (sale.date.isAfter(lastWeek)) {
        final dateStr = '${sale.date.day}/${sale.date.month}';
        dailySales[dateStr] = (dailySales[dateStr] ?? 0) + sale.amount;
      }
    }

    // Convertir a lista de puntos de datos
    return dailySales.entries.map((entry) {
      return SalesDataPoint(
        date: entry.key,
        amount: entry.value,
      );
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool get hasError => _error != null;
  bool get hasSales => _sales.isNotEmpty;
}

class SalesDataPoint {
  final String date;
  final double amount;

  SalesDataPoint({
    required this.date,
    required this.amount,
  });
} 