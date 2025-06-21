import 'package:flutter/foundation.dart' as foundation;
import '../models/dashboard_data.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../utils/error_handler.dart';

class DashboardViewModel extends foundation.ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthService _authService;
  
  DashboardData? _dashboardData;
  bool _isLoading = false;
  String? _error;

  DashboardViewModel(this._firestoreService, this._authService);

  DashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboardData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 Cargando datos del dashboard');
      
      // Cargar todos los datos necesarios
      final products = await _firestoreService.getProducts();
      final sales = await _firestoreService.getSales();
      final movements = await _firestoreService.getMovements();
      final categories = await _firestoreService.getCategories();
      
      // Calcular estadísticas
      final totalProducts = products.length;
      final totalSales = sales.length;
      final totalRevenue = sales.fold<double>(0, (sum, sale) => sum + sale.amount);
      final totalCategories = categories.length;
      
      // Calcular movimientos recientes (última semana)
      final now = DateTime.now();
      final lastWeek = now.subtract(const Duration(days: 7));
      final recentMovements = movements.where((movement) => 
        movement.date.isAfter(lastWeek)
      ).toList();
      
      _dashboardData = DashboardData(
        totalProducts: totalProducts,
        totalSales: totalSales,
        totalRevenue: totalRevenue,
        totalCategories: totalCategories,
        recentMovements: recentMovements,
        products: products,
        sales: sales,
        categories: categories,
      );
      
      print('✅ Dashboard data cargado exitosamente');
      print('  - Productos: $totalProducts');
      print('  - Ventas: $totalSales');
      print('  - Ingresos: \$${totalRevenue.toStringAsFixed(2)}');
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