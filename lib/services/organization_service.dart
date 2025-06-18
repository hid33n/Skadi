import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/organization.dart';
import '../utils/error_handler.dart';

class OrganizationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crear una nueva organización
  Future<String> createOrganization(Organization organization) async {
    try {
      final docRef = await _firestore.collection('organizations').add(organization.toMap());
      return docRef.id;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener organización por ID
  Future<Organization?> getOrganization(String id) async {
    try {
      final doc = await _firestore.collection('organizations').doc(id).get();
      if (doc.exists) {
        return Organization.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Actualizar organización
  Future<void> updateOrganization(String id, Organization organization) async {
    try {
      await _firestore.collection('organizations').doc(id).update(organization.toMap());
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Eliminar organización
  Future<void> deleteOrganization(String id) async {
    try {
      await _firestore.collection('organizations').doc(id).delete();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener todas las organizaciones (solo para super admin)
  Future<List<Organization>> getAllOrganizations() async {
    try {
      final querySnapshot = await _firestore.collection('organizations').get();
      return querySnapshot.docs
          .map((doc) => Organization.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Verificar si una organización existe
  Future<bool> organizationExists(String id) async {
    try {
      final doc = await _firestore.collection('organizations').doc(id).get();
      return doc.exists;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener estadísticas de la organización
  Future<Map<String, dynamic>> getOrganizationStats(String organizationId) async {
    try {
      // Obtener conteo de usuarios
      final usersSnapshot = await _firestore
          .collection('users')
          .where('organizationId', isEqualTo: organizationId)
          .get();

      // Obtener conteo de productos
      final productsSnapshot = await _firestore
          .collection('products')
          .where('organizationId', isEqualTo: organizationId)
          .get();

      // Obtener conteo de ventas
      final salesSnapshot = await _firestore
          .collection('sales')
          .where('organizationId', isEqualTo: organizationId)
          .get();

      return {
        'totalUsers': usersSnapshot.docs.length,
        'totalProducts': productsSnapshot.docs.length,
        'totalSales': salesSnapshot.docs.length,
        'activeUsers': usersSnapshot.docs
            .where((doc) => doc.data()['isActive'] == true)
            .length,
      };
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }
} 