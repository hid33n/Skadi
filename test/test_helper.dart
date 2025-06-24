import 'package:firebase_core/firebase_core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock/models/movement.dart';
import 'package:stock/models/product.dart';
import 'package:stock/models/sale.dart';
import 'package:stock/models/category.dart';
import 'package:stock/services/firestore_service.dart';
import 'package:stock/services/auth_service.dart';

Future<void> setupFirebaseForTesting() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

// Configurar Firebase para usar el emulador en pruebas
Future<void> setupFirebaseEmulator() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Configurar Firestore para usar el emulador
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}

class MockAuthService extends Mock implements AuthService {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> get authStateChanges => Stream.value(_currentUser);

  @override
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String username) async {
    if (email.isEmpty) {
      throw 'El email es requerido';
    }
    if (password.isEmpty) {
      throw 'La contraseña es requerida';
    }
    if (username.isEmpty) {
      throw 'El nombre de usuario es requerido';
    }
    if (password.length < 6) {
      throw 'La contraseña debe tener al menos 6 caracteres';
    }
    if (username.length < 3) {
      throw 'El nombre de usuario debe tener al menos 3 caracteres';
    }
    if (!email.contains('@')) {
      throw 'El formato del email no es válido';
    }

    // Simular un usuario creado exitosamente
    return MockUserCredential();
  }

  @override
  Future<UserCredential> signInWithEmailOrUsername(
      String emailOrUsername, String password) async {
    if (emailOrUsername.isEmpty) {
      throw 'El email o nombre de usuario es requerido';
    }
    if (password.isEmpty) {
      throw 'La contraseña es requerida';
    }
    // Si contiene @, debe ser un email válido
    if (emailOrUsername.contains('@') && !emailOrUsername.contains('.')) {
      throw 'El formato del email no es válido';
    }

    // Simular un inicio de sesión exitoso
    return MockUserCredential();
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      throw 'El email es requerido';
    }
    if (!email.contains('@')) {
      throw 'El formato del email no es válido';
    }
  }

  @override
  Future<void> updateUserProfile(String username) async {
    // Simular actualización de perfil
  }
}

class MockUserCredential extends Mock implements UserCredential {
  @override
  User? get user => MockUser();
}

class MockUser extends Mock implements User {
  @override
  String get email => 'test@example.com';
  
  @override
  String get uid => 'test-uid';
}

class MockFirestoreService extends Mock implements FirestoreService {
  final List<Movement> _movements = [];
  final List<Product> _products = [];
  final List<Sale> _sales = [];
  final List<Category> _categories = [];

  @override
  Future<List<Movement>> getMovements() async {
    return List.from(_movements);
  }

  @override
  Future<void> addMovement(Movement movement) async {
    if (movement.quantity <= 0) {
      throw Exception('La cantidad debe ser mayor a cero');
    }
    _movements.add(movement);
  }

  @override
  Future<void> deleteMovement(String id) async {
    final index = _movements.indexWhere((m) => m.id == id);
    if (index == -1) {
      throw Exception('Movimiento no encontrado');
    }
    _movements.removeAt(index);
  }

  @override
  Future<List<Movement>> getMovementsByProduct(String productId) async {
    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Producto no encontrado'),
    );
    return _movements.where((m) => m.productId == product.id).toList();
  }

  @override
  Future<List<Movement>> getMovementsByDateRange(DateTime startDate, DateTime endDate) async {
    if (endDate.isBefore(startDate)) {
      throw Exception('La fecha final debe ser posterior a la fecha inicial');
    }
    return _movements.where((m) => 
      m.date.isAfter(startDate) && m.date.isBefore(endDate)
    ).toList();
  }

  @override
  Future<List<Movement>> getMovementsByType(MovementType type) async {
    return _movements.where((m) => m.type == type).toList();
  }

  @override
  Future<List<Product>> getProducts() async {
    return List.from(_products);
  }

  @override
  Future<void> addProduct(Product product) async {
    if (product.name.isEmpty) {
      throw Exception('El nombre del producto no puede estar vacío');
    }
    if (product.price < 0) {
      throw Exception('El precio no puede ser negativo');
    }
    if (product.stock < 0) {
      throw Exception('El stock no puede ser negativo');
    }
    _products.add(product);
  }

  @override
  Future<void> updateProduct(String id, Product product) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw Exception('Producto no encontrado');
    }
    if (product.name.isEmpty) {
      throw Exception('El nombre del producto no puede estar vacío');
    }
    if (product.price < 0) {
      throw Exception('El precio no puede ser negativo');
    }
    if (product.stock < 0) {
      throw Exception('El stock no puede ser negativo');
    }
    _products[index] = product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw Exception('Producto no encontrado');
    }
    _products.removeAt(index);
  }

  @override
  Future<List<Product>> getLowStockProducts() async {
    return _products.where((p) => p.stock <= p.minStock).toList();
  }

  @override
  Future<List<Sale>> getSales() async {
    return List.from(_sales);
  }

  @override
  Future<void> addSale(Sale sale) async {
    if (sale.quantity <= 0) {
      throw Exception('La cantidad debe ser mayor a cero');
    }
    if (sale.amount < 0) {
      throw Exception('El monto no puede ser negativo');
    }
    _sales.add(sale);
  }

  @override
  Future<List<Sale>> getSalesByDateRange(DateTime startDate, DateTime endDate) async {
    if (endDate.isBefore(startDate)) {
      throw Exception('La fecha final debe ser posterior a la fecha inicial');
    }
    return _sales.where((s) => 
      s.date.isAfter(startDate) && s.date.isBefore(endDate)
    ).toList();
  }

  @override
  Future<List<Sale>> getSalesByProduct(String productId) async {
    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Producto no encontrado'),
    );
    return _sales.where((s) => s.productId == product.id).toList();
  }

  @override
  Future<List<Category>> getCategories() async {
    return List.from(_categories);
  }

  @override
  Future<void> addCategory(Category category) async {
    if (category.name.isEmpty) {
      throw Exception('El nombre de la categoría no puede estar vacío');
    }
    _categories.add(category);
  }

  @override
  Future<void> updateCategory(String id, Category category) async {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) {
      throw Exception('Categoría no encontrada');
    }
    if (category.name.isEmpty) {
      throw Exception('El nombre de la categoría no puede estar vacío');
    }
    _categories[index] = category;
  }

  @override
  Future<void> deleteCategory(String id) async {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) {
      throw Exception('Categoría no encontrada');
    }
    _categories.removeAt(index);
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Método helper para agregar datos de prueba
  void addTestData() {
    // Agregar categorías de prueba
    _categories.addAll([
      Category(
        id: '1',
        name: 'Electrónicos',
        description: 'Productos electrónicos',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Category(
        id: '2',
        name: 'Ropa',
        description: 'Ropa y accesorios',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);

    // Agregar productos de prueba
    _products.addAll([
      Product(
        id: '1',
        name: 'Smartphone',
        description: 'Smartphone de última generación',
        price: 999.99,
        stock: 5,
        minStock: 10,
        maxStock: 20,
        categoryId: '1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '2',
        name: 'Camiseta',
        description: 'Camiseta de algodón',
        price: 29.99,
        stock: 20,
        minStock: 5,
        maxStock: 50,
        categoryId: '2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);

    // Agregar movimientos de prueba
    _movements.addAll([
      Movement(
        id: '1',
        productId: '1',
        productName: 'Smartphone',
        type: MovementType.entry,
        quantity: 10,
        date: DateTime.now(),
        note: 'Initial stock',
      ),
      Movement(
        id: '2',
        productId: '2',
        productName: 'Camiseta',
        type: MovementType.exit,
        quantity: 5,
        date: DateTime.now(),
        note: 'Sale',
      ),
    ]);

    // Agregar ventas de prueba
    _sales.addAll([
      Sale(
        id: '1',
        productId: '1',
        productName: 'Smartphone',
        quantity: 1,
        amount: 999.99,
        date: DateTime.now(),
        notes: 'Venta al contado',
        userId: 'test-user-1',
      ),
      Sale(
        id: '2',
        productId: '2',
        productName: 'Camiseta',
        quantity: 2,
        amount: 59.98,
        date: DateTime.now(),
        notes: 'Venta con descuento',
        userId: 'test-user-2',
      ),
    ]);
  }

  // Método helper para limpiar datos de prueba
  void clearTestData() {
    _movements.clear();
    _products.clear();
    _sales.clear();
    _categories.clear();
  }
} 