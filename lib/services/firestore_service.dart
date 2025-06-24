import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/sale.dart';
import '../models/movement.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  FirestoreService(this._authService, [FirebaseFirestore? firestore]) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  String get _userId => _authService.currentUser?.uid ?? '';

  // Referencias a las subcolecciones - Cambiado de 'users' a 'pm'
  CollectionReference get _userProductsRef => 
      _firestore.collection('pm').doc(_userId).collection('products');
  
  CollectionReference get _userCategoriesRef => 
      _firestore.collection('pm').doc(_userId).collection('categories');
  
  CollectionReference get _userSalesRef => 
      _firestore.collection('pm').doc(_userId).collection('sales');
  
  CollectionReference get _userMovementsRef => 
      _firestore.collection('pm').doc(_userId).collection('movements');

  // Métodos para Productos
  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _userProductsRef.get();
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _userProductsRef.add(product.toMap());
    } catch (e) {
      throw Exception('Error al agregar producto: $e');
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    try {
      await _userProductsRef.doc(id).update(product.toMap());
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _userProductsRef.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }

  Future<List<Product>> getLowStockProducts() async {
    try {
      final snapshot = await _userProductsRef.get();
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((product) => product.stock <= product.minStock)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos con stock bajo: $e');
    }
  }

  // Métodos para Categorías
  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _userCategoriesRef.get();
      return snapshot.docs
          .map((doc) => Category.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _userCategoriesRef.add(category.toMap());
    } catch (e) {
      throw Exception('Error al agregar categoría: $e');
    }
  }

  Future<void> updateCategory(String id, Category category) async {
    try {
      await _userCategoriesRef.doc(id).update(category.toMap());
    } catch (e) {
      throw Exception('Error al actualizar categoría: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _userCategoriesRef.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar categoría: $e');
    }
  }

  Future<Category?> getCategoryById(String id) async {
    try {
      final doc = await _userCategoriesRef.doc(id).get();
      if (doc.exists) {
        return Category.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener categoría: $e');
    }
  }

  // Métodos para Ventas
  Future<List<Sale>> getSales() async {
    try {
      final snapshot = await _userSalesRef
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener ventas: $e');
    }
  }

  Future<void> addSale(Sale sale) async {
    try {
      await _userSalesRef.add(sale.toMap());
    } catch (e) {
      throw Exception('Error al agregar venta: $e');
    }
  }

  Future<void> deleteSale(String id) async {
    try {
      await _userSalesRef.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar venta: $e');
    }
  }

  // Métodos para Movimientos
  Future<List<Movement>> getMovements() async {
    try {
      final snapshot = await _userMovementsRef
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Movement.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener movimientos: $e');
    }
  }

  Future<void> addMovement(Movement movement) async {
    try {
      await _userMovementsRef.add(movement.toMap());
    } catch (e) {
      throw Exception('Error al agregar movimiento: $e');
    }
  }

  Future<void> deleteMovement(String id) async {
    try {
      await _userMovementsRef.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar movimiento: $e');
    }
  }

  // Métodos para el Dashboard
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final startOfWeek = startOfDay.subtract(Duration(days: startOfDay.weekday - 1));
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Obtener ventas del día
      final todaySales = await _userSalesRef
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .get();

      // Obtener ventas de la semana
      final weekSales = await _userSalesRef
          .where('date', isGreaterThanOrEqualTo: startOfWeek)
          .get();

      // Obtener ventas del mes
      final monthSales = await _userSalesRef
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .get();

      // Obtener productos con stock bajo
      final lowStockProducts = await getLowStockProducts();

      // Obtener todas las categorías
      final categories = await getCategories();

      // Obtener todos los productos
      final products = await getProducts();

      // Calcular totales
      double calculateTotal(List<QueryDocumentSnapshot> sales) {
        return sales.fold(0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          return sum + (data['amount'] as num? ?? 0);
        });
      }

      return {
        'todaySales': calculateTotal(todaySales.docs),
        'weekSales': calculateTotal(weekSales.docs),
        'monthSales': calculateTotal(monthSales.docs),
        'lowStockProducts': lowStockProducts ?? [],
        'categories': categories ?? [],
        'products': products ?? [],
      };
    } catch (e) {
      // En caso de error, devolver datos vacíos en lugar de null
      return {
        'todaySales': 0.0,
        'weekSales': 0.0,
        'monthSales': 0.0,
        'lowStockProducts': [],
        'categories': [],
        'products': [],
      };
    }
  }
} 