import '../models/movement.dart';
import 'firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MovementService {
  final FirestoreService _firestoreService;

  MovementService(this._firestoreService);

  Future<List<Movement>> getMovements() async {
    return await _firestoreService.getMovements();
  }

  Future<void> addMovement(Movement movement) async {
    if (movement.quantity <= 0) {
      throw Exception('La cantidad debe ser mayor a cero');
    }
    await _firestoreService.addMovement(movement);
  }

  Future<void> deleteMovement(String id) async {
    await _firestoreService.deleteMovement(id);
  }

  Future<List<Movement>> getMovementsByProduct(String productId) async {
    try {
      final movements = await _firestoreService.getMovements();
      return movements.where((m) => m.productId == productId).toList();
    } catch (e) {
      throw Exception('Error al obtener movimientos por producto: $e');
    }
  }

  Future<List<Movement>> getMovementsByDateRange(DateTime startDate, DateTime endDate) async {
    if (endDate.isBefore(startDate)) {
      throw Exception('La fecha final debe ser posterior a la fecha inicial');
    }
    try {
      final movements = await _firestoreService.getMovements();
      return movements.where((m) => 
        m.date.isAfter(startDate) && m.date.isBefore(endDate)
      ).toList();
    } catch (e) {
      throw Exception('Error al obtener movimientos por rango de fechas: $e');
    }
  }

  Future<List<Movement>> getMovementsByType(MovementType type) async {
    try {
      final movements = await _firestoreService.getMovements();
      return movements.where((m) => m.type == type).toList();
    } catch (e) {
      throw Exception('Error al obtener movimientos por tipo: $e');
    }
  }

  // Método para obtener movimientos recientes
  Future<List<Movement>> getRecentMovements({int limit = 10}) async {
    try {
      final movements = await _firestoreService.getMovements();
      return movements.take(limit).toList();
    } catch (e) {
      throw Exception('Error al obtener movimientos recientes: $e');
    }
  }

  // Método para obtener el historial de movimientos de un producto
  Future<List<Movement>> getProductHistory(String productId, {int limit = 50}) async {
    try {
      final movements = await getMovementsByProduct(productId);
      return movements.take(limit).toList();
    } catch (e) {
      throw Exception('Error al obtener historial del producto: $e');
    }
  }
} 