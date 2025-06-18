import '../models/movement.dart';
import '../utils/error_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MovementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtener movimientos de una organización específica
  Future<List<Movement>> getMovements(String organizationId) async {
    try {
      final querySnapshot = await _firestore
          .collection('movements')
          .where('organizationId', isEqualTo: organizationId)
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Movement.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener movimiento por ID (verificando organización)
  Future<Movement?> getMovement(String id, String organizationId) async {
    try {
      final doc = await _firestore.collection('movements').doc(id).get();
      if (doc.exists) {
        final movement = Movement.fromMap(doc.data()!, doc.id);
        // Verificar que el movimiento pertenece a la organización
        if (movement.organizationId == organizationId) {
          return movement;
        }
      }
      return null;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Agregar movimiento
  Future<String> addMovement(Movement movement) async {
    try {
      if (movement.quantity <= 0) {
        throw AppError.validation('La cantidad debe ser mayor a cero');
      }
      
      final docRef = await _firestore.collection('movements').add(movement.toMap());
      return docRef.id;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Eliminar movimiento
  Future<void> deleteMovement(String id, String organizationId) async {
    try {
      // Verificar que el movimiento pertenece a la organización antes de eliminar
      final movement = await getMovement(id, organizationId);
      if (movement != null) {
        await _firestore.collection('movements').doc(id).delete();
      } else {
        throw AppError.permission('No tienes permisos para eliminar este movimiento');
      }
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener movimientos por producto
  Future<List<Movement>> getMovementsByProduct(String productId, String organizationId) async {
    try {
      final querySnapshot = await _firestore
          .collection('movements')
          .where('organizationId', isEqualTo: organizationId)
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
    DateTime endDate, 
    String organizationId
  ) async {
    try {
      if (endDate.isBefore(startDate)) {
        throw AppError.validation('La fecha final debe ser posterior a la fecha inicial');
      }
      
      final querySnapshot = await _firestore
          .collection('movements')
          .where('organizationId', isEqualTo: organizationId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
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
  Future<List<Movement>> getMovementsByType(MovementType type, String organizationId) async {
    try {
      final movements = await getMovements(organizationId);
      return movements.where((m) => m.type == type).toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener movimientos recientes
  Future<List<Movement>> getRecentMovements(String organizationId, {int limit = 10}) async {
    try {
      final movements = await getMovements(organizationId);
      return movements.take(limit).toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener historial de movimientos de un producto
  Future<List<Movement>> getProductHistory(String productId, String organizationId, {int limit = 50}) async {
    try {
      final movements = await getMovementsByProduct(productId, organizationId);
      return movements.take(limit).toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener estadísticas de movimientos
  Future<Map<String, dynamic>> getMovementStats(String organizationId) async {
    try {
      final movements = await getMovements(organizationId);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      // Movimientos del día
      final todayMovements = movements.where((m) {
        final movementDate = m.date;
        return movementDate.isAfter(today) || movementDate.isAtSameMomentAs(today);
      }).toList();

      // Movimientos del mes
      final monthMovements = movements.where((m) {
        final movementDate = m.date;
        return movementDate.isAfter(firstDayOfMonth) || movementDate.isAtSameMomentAs(firstDayOfMonth);
      }).toList();

      // Contar por tipo
      final entries = movements.where((m) => m.type == MovementType.entry).length;
      final exits = movements.where((m) => m.type == MovementType.exit).length;

      // Movimientos por día de los últimos 7 días
      final dailyMovements = <Map<String, dynamic>>[];
      for (var i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final dayMovements = movements.where((m) {
          final movementDate = m.date;
          return movementDate.year == date.year &&
              movementDate.month == date.month &&
              movementDate.day == date.day;
        }).toList();

        dailyMovements.add({
          'date': date,
          'entries': dayMovements.where((m) => m.type == MovementType.entry).length,
          'exits': dayMovements.where((m) => m.type == MovementType.exit).length,
          'total': dayMovements.length,
        });
      }

      return {
        'totalMovements': movements.length,
        'todayMovements': todayMovements.length,
        'monthMovements': monthMovements.length,
        'entries': entries,
        'exits': exits,
        'dailyMovements': dailyMovements,
        'recentMovements': movements.take(5).map((m) => m.toMap()).toList(),
      };
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }
} 