import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/sale.dart';
import '../models/movement.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;

  FirestoreService(this._authService);

  String get _userId => _authService.currentUser?.uid ?? '';

  // Métodos para Productos
  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('userId', isEqualTo: _userId)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection('products').add({
        ...product.toMap(),
        'userId': _userId,
      });
    } catch (e) {
      throw Exception('Error al agregar producto: $e');
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    try {
      await _firestore.collection('products').doc(id).update(product.toMap());
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }

  Future<List<Product>> getLowStockProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('userId', isEqualTo: _userId)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .where((product) => product.stock <= product.minStock)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos con stock bajo: $e');
    }
  }

  // Métodos para Categorías
  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('userId', isEqualTo: _userId)
          .get();

      return snapshot.docs
          .map((doc) => Category.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _firestore.collection('categories').add({
        ...category.toMap(),
        'userId': _userId,
      });
    } catch (e) {
      throw Exception('Error al agregar categoría: $e');
    }
  }

  Future<void> updateCategory(String id, Category category) async {
    try {
      await _firestore.collection('categories').doc(id).update(category.toMap());
    } catch (e) {
      throw Exception('Error al actualizar categoría: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection('categories').doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar categoría: $e');
    }
  }

  Future<Category?> getCategoryById(String id) async {
    try {
      final doc = await _firestore.collection('categories').doc(id).get();
      if (doc.exists) {
        return Category.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener categoría: $e');
    }
  }

  // Métodos para Ventas
  Future<List<Sale>> getSales() async {
    try {
      final snapshot = await _firestore
          .collection('sales')
          .where('userId', isEqualTo: _userId)
          .get();

      final sales = snapshot.docs
          .map((doc) => Sale.fromMap(doc.data(), doc.id))
          .toList();
      
      // Ordenar en memoria
      sales.sort((a, b) => b.date.compareTo(a.date));
      return sales;
    } catch (e) {
      throw Exception('Error al obtener ventas: $e');
    }
  }

  Future<void> addSale(Sale sale) async {
    try {
      await _firestore.collection('sales').add({
        ...sale.toMap(),
        'userId': _userId,
      });
    } catch (e) {
      throw Exception('Error al agregar venta: $e');
    }
  }

  Future<void> deleteSale(String id) async {
    try {
      await _firestore.collection('sales').doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar venta: $e');
    }
  }

  // Métodos para Movimientos
  Future<List<Movement>> getMovements() async {
    try {
      final snapshot = await _firestore
          .collection('movements')
          .where('userId', isEqualTo: _userId)
          .get();

      final movements = snapshot.docs
          .map((doc) => Movement.fromMap(doc.data(), doc.id))
          .toList();
      
      // Ordenar en memoria
      movements.sort((a, b) => b.date.compareTo(a.date));
      return movements;
    } catch (e) {
      throw Exception('Error al obtener movimientos: $e');
    }
  }

  Future<void> addMovement(Movement movement) async {
    try {
      await _firestore.collection('movements').add({
        ...movement.toMap(),
        'userId': _userId,
      });
    } catch (e) {
      throw Exception('Error al agregar movimiento: $e');
    }
  }

  Future<void> deleteMovement(String id) async {
    try {
      await _firestore.collection('movements').doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar movimiento: $e');
    }
  }

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
    } catch (e) {
      throw Exception('Error al obtener movimientos por producto: $e');
    }
  }

  Future<List<Movement>> getMovementsByDateRange(DateTime startDate, DateTime endDate) async {
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
    } catch (e) {
      throw Exception('Error al obtener movimientos por rango de fechas: $e');
    }
  }

  Future<List<Movement>> getMovementsByType(MovementType type) async {
    try {
      final querySnapshot = await _firestore
          .collection('movements')
          .where('type', isEqualTo: type.toString())
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Movement.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener movimientos por tipo: $e');
    }
  }

  // Método para obtener datos del dashboard
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      // Obtener ventas
      final salesSnapshot = await _firestore
          .collection('sales')
          .where('userId', isEqualTo: _userId)
          .get();

      final allSales = salesSnapshot.docs
          .map((doc) => Sale.fromMap(doc.data(), doc.id))
          .toList();

      // Filtrar y ordenar ventas en memoria
      final sales = allSales
          .where((sale) => sale.date.isAfter(sevenDaysAgo))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      // Obtener productos con stock bajo
      final productsSnapshot = await _firestore
          .collection('products')
          .where('userId', isEqualTo: _userId)
          .get();

      final products = productsSnapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .where((product) => product.stock <= product.minStock)
          .toList();

      // Obtener movimientos recientes
      final movementsSnapshot = await _firestore
          .collection('movements')
          .where('userId', isEqualTo: _userId)
          .get();

      final allMovements = movementsSnapshot.docs
          .map((doc) => Movement.fromMap(doc.data(), doc.id))
          .toList();

      // Ordenar y limitar movimientos en memoria
      allMovements.sort((a, b) => b.date.compareTo(a.date));
      final movements = allMovements.take(5).toList();

      return {
        'sales': sales,
        'lowStockProducts': products,
        'recentMovements': movements,
      };
    } catch (e) {
      throw Exception('Error al obtener datos del dashboard: $e');
    }
  }
} 