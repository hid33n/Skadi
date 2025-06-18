import 'package:flutter/foundation.dart';
import '../models/dashboard_data.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/category.dart' as app_category;
import '../models/movement.dart';
import '../models/organization.dart';
import '../services/user_data_service.dart';
import '../services/auth_service.dart';
import '../utils/error_handler.dart';

class DashboardViewModel extends ChangeNotifier {
  final UserDataService _userDataService = UserDataService();
  final AuthService _authService = AuthService();

  DashboardData? _dashboardData;
  Organization? _currentOrganization;
  bool _isLoading = false;
  String? _error;

  DashboardData? get dashboardData => _dashboardData;
  Organization? get currentOrganization => _currentOrganization;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters para acceso directo a los datos
  List<Product> get products => _dashboardData?.products ?? [];
  List<Sale> get sales => _dashboardData?.sales ?? [];
  List<app_category.Category> get categories => _dashboardData?.categories ?? [];
  List<Movement> get movements => _dashboardData?.recentMovements ?? [];

  // Métodos para obtener productos con stock bajo
  List<Product> getLowStockProductsLocal() {
    return products.where((product) => 
      product.stock <= product.minStock
    ).toList();
  }

  // Método para cargar productos (alias para loadDashboardData)
  Future<void> loadProducts() async {
    await loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    _setLoading(true);
    _clearError();

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _setError('Usuario no autenticado');
        return;
      }

      // Primero cargar la organización del usuario
      _currentOrganization = await _userDataService.getOrganization(currentUser.uid);
      
      if (_currentOrganization == null) {
        _setError('No se encontró la organización del usuario');
        return;
      }

      // Cargar datos en paralelo usando el organizationId
      final results = await Future.wait([
        _userDataService.getProducts(currentUser.uid, _currentOrganization!.id),
        _userDataService.getSales(currentUser.uid, _currentOrganization!.id),
        _userDataService.getCategories(currentUser.uid, _currentOrganization!.id),
        _userDataService.getMovements(currentUser.uid, _currentOrganization!.id),
      ]);

      final products = results[0] as List<Product>;
      final sales = results[1] as List<Sale>;
      final categories = results[2] as List<app_category.Category>;
      final movements = results[3] as List<Movement>;

      // Calcular estadísticas
      final totalProducts = products.length;
      final totalSales = sales.length;
      final totalRevenue = sales.fold<double>(0, (sum, sale) => sum + sale.amount);
      final totalCategories = categories.length;
      final recentMovements = movements.take(10).toList();

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

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Método para cargar datos con organizationId específico
  Future<void> loadDashboardDataForOrganization(String organizationId) async {
    _setLoading(true);
    _clearError();

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _setError('Usuario no autenticado');
        return;
      }

      // Cargar datos en paralelo usando el organizationId proporcionado
      final results = await Future.wait([
        _userDataService.getProducts(currentUser.uid, organizationId),
        _userDataService.getSales(currentUser.uid, organizationId),
        _userDataService.getCategories(currentUser.uid, organizationId),
        _userDataService.getMovements(currentUser.uid, organizationId),
      ]);

      final products = results[0] as List<Product>;
      final sales = results[1] as List<Sale>;
      final categories = results[2] as List<app_category.Category>;
      final movements = results[3] as List<Movement>;

      // Calcular estadísticas
      final totalProducts = products.length;
      final totalSales = sales.length;
      final totalRevenue = sales.fold<double>(0, (sum, sale) => sum + sale.amount);
      final totalCategories = categories.length;
      final recentMovements = movements.take(10).toList();

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

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void clearData() {
    _dashboardData = null;
    _currentOrganization = null;
    _clearError();
    notifyListeners();
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
} 