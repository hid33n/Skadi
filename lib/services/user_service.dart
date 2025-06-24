import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../utils/error_handler.dart';

class UserService {
  final FirebaseFirestore _firestore;

  UserService([FirebaseFirestore? firestore]) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Crear un nuevo usuario
  Future<String> createUser(UserProfile user) async {
    try {
      final docRef = await _firestore.collection('pm').add(user.toMap());
      return docRef.id;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener usuario por ID
  Future<UserProfile?> getUser(String id) async {
    try {
      final doc = await _firestore.collection('pm').doc(id).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener usuario por email
  Future<UserProfile?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('pm')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return UserProfile.fromMap(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      }
      return null;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Actualizar usuario
  Future<void> updateUser(String id, UserProfile user) async {
    try {
      await _firestore.collection('pm').doc(id).update(user.toMap());
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Eliminar usuario
  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection('pm').doc(id).delete();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener todos los usuarios
  Future<List<UserProfile>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection('pm')
          .get();
      
      return querySnapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Activar usuario
  Future<void> activateUser(String userId) async {
    try {
      await _firestore.collection('pm').doc(userId).update({
        'isActive': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Suspender usuario
  Future<void> suspendUser(String userId) async {
    try {
      await _firestore.collection('pm').doc(userId).update({
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Actualizar último login
  Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore.collection('pm').doc(userId).update({
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Verificar permisos de usuario
  Future<bool> hasPermission(String userId, String permission) async {
    try {
      final user = await getUser(userId);
      if (user == null) return false;
      
      // Verificar si el usuario tiene el permiso específico
      return user.permissions.contains(permission) || 
             user.role == UserRole.owner || 
             user.role == UserRole.admin;
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }

  /// Obtener estadísticas de usuarios
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final users = await getAllUsers();
      
      return {
        'total': users.length,
        'active': users.where((u) => u.isActive).length,
        'inactive': users.where((u) => !u.isActive).length,
        'owners': users.where((u) => u.role == UserRole.owner).length,
        'admins': users.where((u) => u.role == UserRole.admin).length,
        'managers': users.where((u) => u.role == UserRole.manager).length,
        'employees': users.where((u) => u.role == UserRole.employee).length,
        'viewers': users.where((u) => u.role == UserRole.viewer).length,
      };
    } catch (e, stackTrace) {
      throw AppError.fromException(e, stackTrace);
    }
  }
} 