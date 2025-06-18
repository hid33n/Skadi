import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Obtener el usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream de cambios en el estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Registro con email y contraseña
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      // Verificar si el nombre de usuario ya existe
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        throw 'El nombre de usuario ya está en uso';
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Crear perfil de usuario en Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user',
      });

      // Crear estructura inicial de datos del usuario
      final userDoc = _firestore.collection('users').doc(userCredential.user!.uid);
      
      // Crear subcolecciones vacías
      await Future.wait([
        userDoc.collection('products').doc('_placeholder').set({
          'createdAt': FieldValue.serverTimestamp(),
        }).then((_) => userDoc.collection('products').doc('_placeholder').delete()),
        
        userDoc.collection('categories').doc('_placeholder').set({
          'createdAt': FieldValue.serverTimestamp(),
        }).then((_) => userDoc.collection('categories').doc('_placeholder').delete()),
        
        userDoc.collection('sales').doc('_placeholder').set({
          'createdAt': FieldValue.serverTimestamp(),
        }).then((_) => userDoc.collection('sales').doc('_placeholder').delete()),
        
        userDoc.collection('movements').doc('_placeholder').set({
          'createdAt': FieldValue.serverTimestamp(),
        }).then((_) => userDoc.collection('movements').doc('_placeholder').delete()),
      ]);

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Inicio de sesión con email/username y contraseña
  Future<UserCredential> signInWithEmailOrUsername(
      String emailOrUsername, String password) async {
    try {
      // Si el input parece un email, intentar iniciar sesión directamente
      if (emailOrUsername.contains('@')) {
        return await _auth.signInWithEmailAndPassword(
          email: emailOrUsername,
          password: password,
        );
      }

      // Si no es un email, buscar el usuario por nombre de usuario
      final userQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: emailOrUsername)
          .get();

      if (userQuery.docs.isEmpty) {
        throw 'Usuario no encontrado';
      }

      final userEmail = userQuery.docs.first.get('email') as String;
      return await _auth.signInWithEmailAndPassword(
        email: userEmail,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar perfil de usuario
  Future<void> updateUserProfile(String username) async {
    try {
      // Verificar si el nuevo nombre de usuario ya existe
      if (username != currentUser?.displayName) {
        final usernameQuery = await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .get();

        if (usernameQuery.docs.isNotEmpty) {
          throw 'El nombre de usuario ya está en uso';
        }
      }

      await _firestore.collection('users').doc(currentUser!.uid).update({
        'username': username,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar organización del usuario
  Future<void> updateUserOrganization(String organizationId) async {
    try {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'organizationId': organizationId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Obtener perfil de usuario
  Future<DocumentSnapshot> getUserProfile() async {
    try {
      return await _firestore.collection('users').doc(currentUser!.uid).get();
    } catch (e) {
      rethrow;
    }
  }
} 