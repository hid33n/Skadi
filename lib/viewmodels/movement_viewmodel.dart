import 'package:flutter/material.dart';
import '../models/movement.dart';
import '../services/firestore_service.dart';

class MovementViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<Movement> _movements = [];
  bool _isLoading = false;
  String _error = '';

  MovementViewModel(this._firestoreService);

  List<Movement> get movements => _movements;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadMovements() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _movements = await _firestoreService.getMovements();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMovement(Movement movement) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _firestoreService.addMovement(movement);
      await loadMovements();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteMovement(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _firestoreService.deleteMovement(id);
      await loadMovements();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<Movement> getMovementsByProduct(String productId) {
    return _movements.where((m) => m.productId == productId).toList();
  }

  List<Movement> getRecentMovements({int limit = 5}) {
    final sortedMovements = List<Movement>.from(_movements)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedMovements.take(limit).toList();
  }
} 