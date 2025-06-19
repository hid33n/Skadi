import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/category.dart' as app_category;
import '../models/sale.dart';
import '../models/movement.dart';
import '../models/organization.dart';
import '../models/user_profile.dart';
import '../utils/error_handler.dart';

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Referencias a las subcolecciones del usuario
  CollectionReference _getUserProductsRef(String userId) => 
      _firestore.collection('users').doc(userId).collection('data').doc('products').collection('items');
  
  CollectionReference _getUserCategoriesRef(String userId) => 
      _firestore.collection('users').doc(userId).collection('data').doc('categories').collection('items');
  
  CollectionReference _getUserSalesRef(String userId) => 
      _firestore.collection('users').doc(userId).collection('data').doc('sales').collection('items');
  
  CollectionReference _getUserMovementsRef(String userId) => 
      _firestore.collection('users').doc(userId).collection('data').doc('movements').collection('items');

  DocumentReference _getUserOrganizationRef(String userId) => 
      _firestore.collection('users').doc(userId).collection('profile').doc('organization');

  // Métodos para Productos
  Future<List<Product>> getProducts(String userId, String organizationId) async {
    try {
      final snapshot = await _getUserProductsRef(userId).get();
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((product) => product.organizationId == organizationId)
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<String> addProduct(String userId, Product product) async {
    try {
      final docRef = await _getUserProductsRef(userId).add(product.toMap());
      return docRef.id;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> updateProduct(String userId, String productId, Product product) async {
    try {
      await _getUserProductsRef(userId).doc(productId).update(product.toMap());
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> deleteProduct(String userId, String productId) async {
    try {
      await _getUserProductsRef(userId).doc(productId).delete();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  // Métodos para Categorías
  Future<List<app_category.Category>> getCategories(String userId, String organizationId) async {
    try {
      print('🔄 UserDataService: Cargando categorías desde Firebase');
      print('  - User ID: $userId');
      print('  - Organization ID: $organizationId');
      
      final snapshot = await _getUserCategoriesRef(userId).get();
      print('📊 UserDataService: Documentos encontrados en Firebase: ${snapshot.docs.length}');
      
      final allCategories = snapshot.docs
          .map((doc) => app_category.Category.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      print('📊 UserDataService: Todas las categorías: ${allCategories.length}');
      for (var category in allCategories) {
        print('  - ${category.name} (ID: ${category.id}, Org: ${category.organizationId})');
      }
      
      final filteredCategories = allCategories
          .where((category) => category.organizationId == organizationId)
          .toList();
      
      print('📊 UserDataService: Categorías filtradas por org: ${filteredCategories.length}');
      for (var category in filteredCategories) {
        print('  ✅ ${category.name} (ID: ${category.id})');
      }
      
      return filteredCategories;
    } catch (e, stackTrace) {
      print('❌ UserDataService: Error cargando categorías: $e');
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<String> addCategory(String userId, app_category.Category category) async {
    try {
      final docRef = await _getUserCategoriesRef(userId).add(category.toMap());
      return docRef.id;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> updateCategory(String userId, String categoryId, app_category.Category category) async {
    try {
      await _getUserCategoriesRef(userId).doc(categoryId).update(category.toMap());
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> deleteCategory(String userId, String categoryId) async {
    try {
      await _getUserCategoriesRef(userId).doc(categoryId).delete();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  // Métodos para Ventas
  Future<List<Sale>> getSales(String userId, String organizationId) async {
    try {
      final snapshot = await _getUserSalesRef(userId).get();
      return snapshot.docs
          .map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((sale) => sale.organizationId == organizationId)
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<String> addSale(String userId, Sale sale) async {
    try {
      final docRef = await _getUserSalesRef(userId).add(sale.toMap());
      return docRef.id;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> updateSale(String userId, String saleId, Sale sale) async {
    try {
      await _getUserSalesRef(userId).doc(saleId).update(sale.toMap());
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> deleteSale(String userId, String saleId) async {
    try {
      await _getUserSalesRef(userId).doc(saleId).delete();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  // Métodos para Movimientos
  Future<List<Movement>> getMovements(String userId, String organizationId) async {
    try {
      final snapshot = await _getUserMovementsRef(userId).get();
      return snapshot.docs
          .map((doc) => Movement.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((movement) => movement.organizationId == organizationId)
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<String> addMovement(String userId, Movement movement) async {
    try {
      final docRef = await _getUserMovementsRef(userId).add(movement.toMap());
      return docRef.id;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> updateMovement(String userId, String movementId, Movement movement) async {
    try {
      await _getUserMovementsRef(userId).doc(movementId).update(movement.toMap());
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> deleteMovement(String userId, String movementId) async {
    try {
      await _getUserMovementsRef(userId).doc(movementId).delete();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  // Métodos para Organización
  Future<Organization?> getOrganization(String userId) async {
    try {
      final doc = await _getUserOrganizationRef(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        String orgId = data['id'] as String? ?? '';
        
        // Si no tiene ID o tiene ID vacío, migrar la organización
        if (orgId.isEmpty || orgId == 'organization') {
          print('🔄 UserDataService: Migrando organización existente...');
          orgId = await _migrateExistingOrganization(userId, data);
        }
        
        print('✅ UserDataService: Organización encontrada - id: $orgId, name: ${data['name']}');
        return Organization.fromMap(data, orgId);
      }
      return null;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Migrar organización existente que no tiene ID único
  Future<String> _migrateExistingOrganization(String userId, Map<String, dynamic> data) async {
    final organizationName = data['name'] as String? ?? 'Organización';
    final uniqueId = await _generateUniqueOrganizationId(organizationName);
    
    // Actualizar el documento con el nuevo ID
    await _getUserOrganizationRef(userId).update({'id': uniqueId});
    
    // Migrar categorías existentes que usen el ID anterior
    await _migrateExistingCategories(userId, uniqueId);
    
    print('✅ UserDataService: Organización migrada con ID: $uniqueId');
    return uniqueId;
  }

  /// Migrar categorías existentes que usen el ID anterior de la organización
  Future<void> _migrateExistingCategories(String userId, String newOrganizationId) async {
    try {
      final categoriesRef = _getUserCategoriesRef(userId);
      final snapshot = await categoriesRef.get();
      
      int migratedCount = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final currentOrgId = data['organizationId'] as String? ?? '';
        
        // Si la categoría usa el ID anterior, actualizarla
        if (currentOrgId == 'organization' || currentOrgId.isEmpty) {
          await doc.reference.update({'organizationId': newOrganizationId});
          migratedCount++;
          print('🔄 UserDataService: Categoría migrada: ${data['name']} -> orgId: $newOrganizationId');
        }
      }
      
      if (migratedCount > 0) {
        print('✅ UserDataService: $migratedCount categorías migradas al nuevo ID de organización');
      }
    } catch (e, stackTrace) {
      print('⚠️ UserDataService: Error migrando categorías: $e');
      // No lanzar error para no interrumpir el flujo principal
    }
  }

  Future<String> createOrganization(String userId, Organization organization) async {
    try {
      // Generar ID único basado en el nombre de la organización
      final uniqueId = await _generateUniqueOrganizationId(organization.name);
      
      // Crear la organización con el ID único
      final organizationWithId = organization.copyWith(id: uniqueId);
      
      final docRef = _getUserOrganizationRef(userId);
      await docRef.set(organizationWithId.toMap());
      
      print('✅ UserDataService: Organización creada con ID único: $uniqueId');
      return uniqueId;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Generar ID único basado en el nombre de la organización
  Future<String> _generateUniqueOrganizationId(String organizationName) async {
    // Normalizar el nombre: minúsculas, sin espacios, solo letras y números
    String baseId = organizationName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .trim();
    
    // Si está vacío, usar 'org' como base
    if (baseId.isEmpty) {
      baseId = 'org';
    }
    
    // Limitar longitud a 20 caracteres
    if (baseId.length > 20) {
      baseId = baseId.substring(0, 20);
    }
    
    // Buscar si ya existe una organización con este ID base
    int counter = 1;
    String uniqueId = baseId;
    
    // Buscar en todas las organizaciones existentes
    final organizationsRef = _firestore.collection('users');
    final usersSnapshot = await organizationsRef.get();
    
    for (final userDoc in usersSnapshot.docs) {
      final orgDoc = await userDoc.reference.collection('profile').doc('organization').get();
      if (orgDoc.exists) {
        final data = orgDoc.data() as Map<String, dynamic>;
        final existingId = data['id'] as String? ?? '';
        if (existingId == uniqueId) {
          // ID ya existe, agregar número
          uniqueId = '${baseId}_$counter';
          counter++;
        }
      }
    }
    
    print('🆔 UserDataService: ID único generado: $uniqueId para organización: $organizationName');
    return uniqueId;
  }

  Future<void> updateOrganization(String userId, Organization organization) async {
    try {
      await _getUserOrganizationRef(userId).update(organization.toMap());
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  // Métodos de utilidad
  Future<void> initializeUserData(String userId) async {
    try {
      // Crear la estructura inicial de datos para el usuario
      final userDataRef = _firestore.collection('users').doc(userId).collection('data');
      
      await Future.wait([
        userDataRef.doc('products').set({'createdAt': FieldValue.serverTimestamp()}),
        userDataRef.doc('categories').set({'createdAt': FieldValue.serverTimestamp()}),
        userDataRef.doc('sales').set({'createdAt': FieldValue.serverTimestamp()}),
        userDataRef.doc('movements').set({'createdAt': FieldValue.serverTimestamp()}),
      ]);
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  // Métodos para manejo de usuarios de organización (placeholder para futuras implementaciones)
  Future<List<UserProfile>> getUsersByOrganization(String organizationId) async {
    try {
      // Por ahora retornamos una lista vacía
      // En el futuro, esto buscaría usuarios que compartan la misma organización
      return [];
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<Map<String, dynamic>> getOrganizationStats(String organizationId) async {
    try {
      // Por ahora retornamos estadísticas básicas
      return {
        'totalProducts': 0,
        'totalSales': 0,
        'totalRevenue': 0.0,
        'activeUsers': 0,
      };
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> inviteUser(String userId, String organizationId, UserRole role) async {
    try {
      // Placeholder para futura implementación de invitaciones
      // Por ahora solo registramos la acción
      await _firestore.collection('invitations').add({
        'userId': userId,
        'organizationId': organizationId,
        'role': role.name,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> activateUser(String userId) async {
    try {
      // Placeholder para futura implementación
      await _firestore.collection('users').doc(userId).update({
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  Future<void> suspendUser(String userId) async {
    try {
      // Placeholder para futura implementación
      await _firestore.collection('users').doc(userId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }
} 