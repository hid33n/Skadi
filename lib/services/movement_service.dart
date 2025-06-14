import '../models/movement.dart';
import 'firestore_service.dart';

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
    return await _firestoreService.getMovementsByProduct(productId);
  }

  Future<List<Movement>> getMovementsByDateRange(DateTime startDate, DateTime endDate) async {
    if (endDate.isBefore(startDate)) {
      throw Exception('La fecha final debe ser posterior a la fecha inicial');
    }
    return await _firestoreService.getMovementsByDateRange(startDate, endDate);
  }

  Future<List<Movement>> getMovementsByType(MovementType type) async {
    return await _firestoreService.getMovementsByType(type);
  }
} 