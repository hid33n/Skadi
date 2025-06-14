import 'package:flutter/foundation.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../services/firestore_service.dart';

class SaleViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<Sale> _sales = [];
  bool _isLoading = false;
  String? _error;

  SaleViewModel(this._firestoreService);

  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sales = await _firestoreService.getSales();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSale(Sale sale) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.addSale(sale);
      await loadSales();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSale(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.deleteSale(id);
      await loadSales();
      _error = null;
    } catch (e) {
      _error = e.toString();
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
} 