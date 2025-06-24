import 'package:flutter/foundation.dart' as foundation;
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../services/hybrid_data_service.dart';
import '../services/auth_service.dart';
import '../utils/error_handler.dart';

class SaleViewModel extends foundation.ChangeNotifier {
  final HybridDataService _dataService;
  final AuthService _authService;
  
  List<Sale> _sales = [];
  Sale? _selectedSale;
  Map<String, dynamic> _saleStats = {};
  bool _isLoading = false;
  String? _error;

  SaleViewModel(this._dataService, this._authService);

  List<Sale> get sales => _sales;
  Sale? get selectedSale => _selectedSale;
  Map<String, dynamic> get saleStats => _saleStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSales() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 Cargando ventas');
      
      _sales = await _dataService.getAllSales();
      
      print('📊 Ventas cargadas: ${_sales.length}');
      for (var sale in _sales) {
        print('  - Venta ${sale.id}: \$${sale.amount} - ${sale.quantity} items');
      }
      
      await _loadSaleStats();
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSale(String saleId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _selectedSale = _sales.firstWhere((sale) => sale.id == saleId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSale(Sale sale) async {
    try {
      print('🔄 SaleViewModel: Agregando venta: \$${sale.amount}');
      
      await _dataService.createSale(sale);
      await loadSales();
      print('✅ SaleViewModel: Venta agregada exitosamente');
      return true;
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSale(String id) async {
    try {
      print('🔄 SaleViewModel: Eliminando venta con ID: $id');
      
      await _dataService.deleteSale(id);
      await loadSales();
      print('✅ SaleViewModel: Venta eliminada exitosamente');
      return true;
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      notifyListeners();
      return false;
    }
  }

  List<Sale> searchSales(String query) {
    if (query.isEmpty) return _sales;
    
    return _sales.where((sale) {
      return sale.id.toLowerCase().contains(query.toLowerCase()) ||
             sale.productName.toLowerCase().contains(query.toLowerCase()) ||
             (sale.notes?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  List<Sale> getSalesByDateRange(DateTime startDate, DateTime endDate) {
    return _sales.where((sale) {
      return sale.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             sale.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Sale? getSaleById(String id) {
    try {
      return _sales.firstWhere((sale) => sale.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadSaleStats() async {
    try {
      if (_sales.isEmpty) {
        _saleStats = {
          'totalSales': 0,
          'totalRevenue': 0.0,
          'averageSaleValue': 0.0,
          'totalItemsSold': 0,
        };
        return;
      }

      double totalRevenue = 0.0;
      int totalItemsSold = 0;

      for (var sale in _sales) {
        totalRevenue += sale.amount;
        totalItemsSold += sale.quantity;
      }

      _saleStats = {
        'totalSales': _sales.length,
        'totalRevenue': totalRevenue,
        'averageSaleValue': totalRevenue / _sales.length,
        'totalItemsSold': totalItemsSold,
      };
    } catch (e, stackTrace) {
      print('❌ Error cargando estadísticas de ventas: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedSale() {
    _selectedSale = null;
    notifyListeners();
  }
} 