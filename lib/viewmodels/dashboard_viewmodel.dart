import 'package:flutter/foundation.dart';
import 'package:stock/services/firestore_service.dart';
import 'package:stock/models/product.dart';
import 'package:stock/models/sale.dart';

class DashboardViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  bool _isLoading = false;
  String? _error;
  List<Product> _lowStockProducts = [];
  List<Sale> _recentSales = [];
  double _totalSales = 0.0;

  DashboardViewModel(this._firestoreService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Product> get lowStockProducts => _lowStockProducts;
  List<Sale> get recentSales => _recentSales;
  double get totalSales => _totalSales;

  Future<void> loadDashboardData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final dashboardData = await _firestoreService.getDashboardData();
      _lowStockProducts = dashboardData['lowStockProducts'] as List<Product>;
      _recentSales = dashboardData['recentSales'] as List<Sale>;
      _totalSales = dashboardData['totalSales'] as double;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
} 