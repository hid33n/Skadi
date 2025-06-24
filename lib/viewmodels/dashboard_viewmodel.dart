import 'package:flutter/foundation.dart' as foundation;
import '../models/dashboard_data.dart';
import '../services/hybrid_data_service.dart';
import '../services/auth_service.dart';
import '../utils/error_handler.dart';

class DashboardViewModel extends foundation.ChangeNotifier {
  final HybridDataService _dataService;
  final AuthService _authService;
  
  DashboardData? _dashboardData;
  bool _isLoading = false;
  String? _error;

  DashboardViewModel(this._dataService, this._authService);

  DashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboardData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 Cargando datos del dashboard');
      
      // Usar el método getDashboardData del servicio híbrido
      final dashboardMap = await _dataService.getDashboardData();
      
      // Cargar datos adicionales para el DashboardData
      final products = await _dataService.getAllProducts();
      final sales = await _dataService.getAllSales();
      final categories = await _dataService.getAllCategories();
      final movements = await _dataService.getAllMovements();
      
      // Calcular movimientos recientes (última semana)
      final now = DateTime.now();
      final lastWeek = now.subtract(const Duration(days: 7));
      final recentMovements = movements.where((movement) => 
        movement.date.isAfter(lastWeek)
      ).toList();
      
      _dashboardData = DashboardData(
        totalProducts: dashboardMap['totalProducts'] ?? products.length,
        totalSales: dashboardMap['totalSales'] ?? sales.length,
        totalRevenue: (dashboardMap['monthSales'] ?? 0.0).toDouble(),
        totalCategories: categories.length,
        recentMovements: recentMovements,
        products: products,
        sales: sales,
        categories: categories,
      );
      
      print('✅ Dashboard data cargado exitosamente');
      print('  - Productos: ${_dashboardData!.totalProducts}');
      print('  - Ventas: ${_dashboardData!.totalSales}');
      print('  - Ingresos: \$${_dashboardData!.totalRevenue.toStringAsFixed(2)}');
      print('  - Movimientos: ${recentMovements.length}');
      
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearData() {
    _dashboardData = null;
    notifyListeners();
  }
} 