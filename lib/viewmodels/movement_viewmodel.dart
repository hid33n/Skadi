import 'package:flutter/material.dart';
import '../models/movement.dart';
import '../services/user_data_service.dart';
import '../services/auth_service.dart';
import '../utils/error_handler.dart';

class MovementViewModel extends ChangeNotifier {
  final UserDataService _userDataService = UserDataService();
  final AuthService _authService = AuthService();
  
  List<Movement> _movements = [];
  bool _isLoading = false;
  String? _error;

  List<Movement> get movements => _movements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Cargar movimientos del usuario actual para una organización específica
  Future<void> loadMovements(String organizationId) async {
    _setLoading(true);
    _clearError();

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _setError('Usuario no autenticado');
        return;
      }

      _movements = await _userDataService.getMovements(currentUser.uid, organizationId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Agregar movimiento
  Future<bool> addMovement(Movement movement) async {
    _setLoading(true);
    _clearError();

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _setError('Usuario no autenticado');
        return false;
      }

      final movementId = await _userDataService.addMovement(currentUser.uid, movement);
      if (movementId.isNotEmpty) {
        // Recargar movimientos
        await loadMovements(movement.organizationId);
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar movimiento
  Future<bool> updateMovement(Movement movement) async {
    _setLoading(true);
    _clearError();

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _setError('Usuario no autenticado');
        return false;
      }

      await _userDataService.updateMovement(currentUser.uid, movement.id, movement);
      // Recargar movimientos
      await loadMovements(movement.organizationId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Eliminar movimiento
  Future<bool> deleteMovement(String id, String organizationId) async {
    _setLoading(true);
    _clearError();

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _setError('Usuario no autenticado');
        return false;
      }

      await _userDataService.deleteMovement(currentUser.uid, id);
      // Recargar movimientos
      await loadMovements(organizationId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Obtener movimientos por producto
  List<Movement> getMovementsByProduct(String productId) {
    return _movements.where((movement) => movement.productId == productId).toList();
  }

  /// Obtener movimientos por tipo
  List<Movement> getMovementsByType(MovementType type) {
    return _movements.where((movement) => movement.type == type).toList();
  }

  /// Obtener movimientos por rango de fechas
  List<Movement> getMovementsByDateRange(DateTime startDate, DateTime endDate) {
    return _movements.where((movement) {
      return movement.date.isAfter(startDate) && movement.date.isBefore(endDate);
    }).toList();
  }

  /// Obtener movimientos recientes
  List<Movement> getRecentMovements({int limit = 10}) {
    final sortedMovements = List<Movement>.from(_movements);
    sortedMovements.sort((a, b) => b.date.compareTo(a.date));
    return sortedMovements.take(limit).toList();
  }

  /// Obtener estadísticas de movimientos
  Map<String, dynamic> getMovementStats() {
    final totalMovements = _movements.length;
    final entryMovements = _movements.where((m) => m.type == MovementType.entry).length;
    final exitMovements = _movements.where((m) => m.type == MovementType.exit).length;
    
    final totalQuantity = _movements.fold<int>(0, (sum, movement) => sum + movement.quantity);
    final entryQuantity = _movements
        .where((m) => m.type == MovementType.entry)
        .fold<int>(0, (sum, movement) => sum + movement.quantity);
    final exitQuantity = _movements
        .where((m) => m.type == MovementType.exit)
        .fold<int>(0, (sum, movement) => sum + movement.quantity);

    return {
      'totalMovements': totalMovements,
      'entryMovements': entryMovements,
      'exitMovements': exitMovements,
      'totalQuantity': totalQuantity,
      'entryQuantity': entryQuantity,
      'exitQuantity': exitQuantity,
      'netQuantity': entryQuantity - exitQuantity,
    };
  }

  /// Limpiar datos
  void clear() {
    _movements.clear();
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