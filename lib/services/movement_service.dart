import '../models/movement.dart';
import '../utils/error_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MovementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtener todos los movimientos
  Future<List<Movement>> getMovements() async {
    try {
      final querySnapshot = await _firestore
          .collection('movements')
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Movement.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener movimiento por ID
  Future<Movement?> getMovement(String id) async {
    try {
      final doc = await _firestore.collection('movements').doc(id).get();
      if (doc.exists) {
        return Movement.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Agregar movimiento
  Future<String> addMovement(Movement movement) async {
    try {
      final docRef = await _firestore.collection('movements').add(movement.toMap());
      return docRef.id;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Actualizar movimiento
  Future<void> updateMovement(String id, Movement movement) async {
    try {
      await _firestore.collection('movements').doc(id).update(movement.toMap());
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Eliminar movimiento
  Future<void> deleteMovement(String id) async {
    try {
      final movement = await getMovement(id);
      if (movement != null) {
        await _firestore.collection('movements').doc(id).delete();
      }
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener movimientos por producto
  Future<List<Movement>> getMovementsByProduct(String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection('movements')
          .where('productId', isEqualTo: productId)
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Movement.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener movimientos por rango de fechas
  Future<List<Movement>> getMovementsByDateRange(
    DateTime startDate,
    DateTime endDate
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('movements')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Movement.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener movimientos por tipo
  Future<List<Movement>> getMovementsByType(MovementType type) async {
    try {
      final movements = await getMovements();
      return movements.where((movement) => movement.type == type).toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener movimientos recientes
  Future<List<Movement>> getRecentMovements({int limit = 10}) async {
    try {
      final movements = await getMovements();
      return movements.take(limit).toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener estadísticas de movimientos
  Future<Map<String, dynamic>> getMovementStats() async {
    try {
      final movements = await getMovements();
      final totalMovements = movements.length;
      
      // Contar por tipo
      final movementsByType = <String, int>{};
      for (final movement in movements) {
        final typeString = movement.type.toString().split('.').last;
        movementsByType[typeString] = (movementsByType[typeString] ?? 0) + 1;
      }
      
      // Movimientos recientes (última semana)
      final now = DateTime.now();
      final lastWeek = now.subtract(const Duration(days: 7));
      final recentMovements = movements.where((movement) => 
        movement.date.isAfter(lastWeek)
      ).length;
      
      return {
        'totalMovements': totalMovements,
        'movementsByType': movementsByType,
        'recentMovements': recentMovements,
      };
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }
} 