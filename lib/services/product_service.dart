import '../models/product.dart';
import 'firestore_service.dart';

class ProductService {
  final FirestoreService _firestoreService;

  ProductService(this._firestoreService);

  Future<List<Product>> getProducts() async {
    return _firestoreService.getProducts();
  }

  Future<void> addProduct(Product product) async {
    await _firestoreService.addProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await _firestoreService.updateProduct(product.id, product);
  }

  Future<void> deleteProduct(String id) async {
    await _firestoreService.deleteProduct(id);
  }

  Future<void> updateStock(String id, int newStock) async {
    final products = await getProducts();
    final product = products.firstWhere((p) => p.id == id);
    final updated = product.copyWith(
      stock: newStock,
      updatedAt: DateTime.now(),
    );
    await _firestoreService.updateProduct(id, updated);
  }
} 