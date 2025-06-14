import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/firestore_service.dart';

class CategoryViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoryViewModel(this._firestoreService) {
    loadCategories();
  }

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _firestoreService.getCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(Category category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.addCategory(category);
      await loadCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(Category category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.updateCategory(category.id, category);
      await loadCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  Map<String, int> getProductCountByCategory() {
    final Map<String, int> categoryCount = {};
    for (var category in _categories) {
      categoryCount[category.id] = 0; // Inicializar contador
    }
    return categoryCount;
  }
} 