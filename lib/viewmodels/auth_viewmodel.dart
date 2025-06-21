import 'package:flutter/foundation.dart' as foundation;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/error_handler.dart';

class AuthViewModel extends foundation.ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthViewModel(this._authService, this._firestoreService);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 AuthViewModel: Iniciando sesión con email: $email');
      
      final userCredential = await _authService.signInWithEmailOrUsername(email, password);
      _currentUser = userCredential.user;
      
      if (_currentUser != null) {
        print('✅ AuthViewModel: Sesión iniciada exitosamente');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Credenciales inválidas';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String username) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 AuthViewModel: Registrando usuario: $email');
      
      final userCredential = await _authService.registerWithEmailAndPassword(email, password, username);
      _currentUser = userCredential.user;
      
      if (_currentUser != null) {
        print('✅ AuthViewModel: Usuario registrado exitosamente');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Error al crear el usuario';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔄 AuthViewModel: Cerrando sesión');
      
      await _authService.signOut();
      _currentUser = null;
      
      print('✅ AuthViewModel: Sesión cerrada exitosamente');
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCurrentUser() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 AuthViewModel: Cargando usuario actual');
      
      _currentUser = _authService.currentUser;
      
      if (_currentUser != null) {
        print('✅ AuthViewModel: Usuario cargado: ${_currentUser!.email}');
      } else {
        print('ℹ️ AuthViewModel: No hay usuario autenticado');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(String username) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 AuthViewModel: Actualizando perfil de usuario');
      
      await _authService.updateUserProfile(username);
      
      print('✅ AuthViewModel: Perfil actualizado exitosamente');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 AuthViewModel: Enviando email de restablecimiento a: $email');
      
      await _authService.resetPassword(email);
      
      print('✅ AuthViewModel: Email de restablecimiento enviado');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _error = AppError.fromException(e, stackTrace).message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
} 