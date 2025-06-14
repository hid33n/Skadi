import '../models/category.dart';
import 'firestore_service.dart';

class CategoryService {
  final FirestoreService _firestoreService;

  CategoryService(this._firestoreService);

  Future<List<Category>> getCategories() async {
    return _firestoreService.getCategories();
  }

  Future<void> addCategory(Category category) async {
    await _firestoreService.addCategory(category);
  }

  Future<void> updateCategory(String id, Category category) async {
    await _firestoreService.updateCategory(id, category);
  }

  Future<void> deleteCategory(String id) async {
    await _firestoreService.deleteCategory(id);
  }

  Future<Category?> getCategoryById(String id) async {
    return _firestoreService.getCategoryById(id);
  }
} 