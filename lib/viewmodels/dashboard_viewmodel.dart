import 'package:flutter/foundation.dart';
import 'package:stock/services/firestore_service.dart';
import 'package:stock/models/product.dart';
import 'package:stock/models/sale.dart';
import 'package:stock/models/category.dart' as models;

class DashboardViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  bool _isLoading = false;
  String? _error;
  List<Product> _lowStockProducts = [];
  List<models.Category> _categories = [];
  List<Product> _products = [];
  double _todaySales = 0.0;
  double _weekSales = 0.0;
  double _monthSales = 0.0;

  DashboardViewModel(this._firestoreService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Product> get lowStockProducts => _lowStockProducts;
  List<models.Category> get categories => _categories;
  List<Product> get products => _products;
  double get todaySales => _todaySales;
  double get weekSales => _weekSales;
  double get monthSales => _monthSales;

  Future<void> loadDashboardData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final dashboardData = await _firestoreService.getDashboardData();
      
      _lowStockProducts = (dashboardData['lowStockProducts'] as List?)?.cast<Product>() ?? [];
      _categories = (dashboardData['categories'] as List?)?.cast<models.Category>() ?? [];
      _products = (dashboardData['products'] as List?)?.cast<Product>() ?? [];
      _todaySales = (dashboardData['todaySales'] as num?)?.toDouble() ?? 0.0;
      _weekSales = (dashboardData['weekSales'] as num?)?.toDouble() ?? 0.0;
      _monthSales = (dashboardData['monthSales'] as num?)?.toDouble() ?? 0.0;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
} 