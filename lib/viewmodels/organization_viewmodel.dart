import 'package:flutter/foundation.dart';
import '../models/organization.dart';
import '../models/user_profile.dart';
import '../services/sync_service.dart';
import '../services/auth_service.dart';
import '../services/user_data_service.dart';
import '../utils/error_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizationViewModel extends ChangeNotifier {
  final SyncService _syncService = SyncService();
  final AuthService _authService = AuthService();
  final UserDataService _userDataService = UserDataService();

  UserProfile? _currentUser;
  Organization? _currentOrganization;
  List<UserProfile> _organizationUsers = [];
  Map<String, dynamic> _organizationStats = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  UserProfile? get currentUser => _currentUser;
  Organization? get currentOrganization => _currentOrganization;
  List<UserProfile> get organizationUsers => _organizationUsers;
  Map<String, dynamic> get organizationStats => _organizationStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Cargar el usuario actual
  Future<void> loadCurrentUser(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      // Obtener el perfil del usuario desde AuthService
      final userDoc = await _authService.getUserProfile();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        
        // Crear un UserProfile con los datos disponibles
        _currentUser = UserProfile(
          id: userId,
          email: userData['email'] as String? ?? '',
          firstName: userData['username'] as String? ?? 'Usuario',
          lastName: '',
          role: UserRole.owner, // Por defecto owner para usuarios nuevos
          organizationId: userData['organizationId'] as String? ?? '',
          createdAt: (userData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (userData['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isActive: userData['isActive'] as bool? ?? true,
        );
        
        // Si el usuario tiene organizationId, cargar la organización
        if (_currentUser!.organizationId.isNotEmpty) {
          await loadOrganization(_currentUser!.organizationId);
        }
        
        notifyListeners();
      } else {
        _setError('Perfil de usuario no encontrado');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar usuario y organización en una sola operación
  Future<void> loadUserAndOrganization(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      // Cargar usuario desde AuthService
      await loadCurrentUser(userId);
      
      if (_currentUser == null) {
        _setError('No se pudo cargar el usuario');
        return;
      }
      
      // Intentar cargar organización desde cache local primero
      Organization? organization = await _syncService.getOrganization();
      
      // Si no hay organización en cache, intentar cargarla desde servidor
      if (organization == null) {
        try {
          print('Intentando cargar organización desde servidor para usuario: $userId');
          organization = await _userDataService.getOrganization(userId);
          
          if (organization != null) {
            print('Organización encontrada en servidor: ${organization.name}');
            // Guardar en cache local
            await _syncService.saveOrganization(organization);
          } else {
            print('No se encontró organización en servidor');
          }
        } catch (e) {
          print('Error cargando organización desde servidor: $e');
          // Continuar sin organización
        }
      } else {
        print('Organización encontrada en cache local: ${organization.name}');
      }
      
      // Asignar la organización si se encontró
      if (organization != null) {
        _currentOrganization = organization;
        
        // Actualizar el usuario con el organizationId si no lo tiene
        if (_currentUser!.organizationId.isEmpty) {
          final updatedUser = _currentUser!.copyWith(organizationId: organization.id);
          await _syncService.saveUserProfile(updatedUser);
          _currentUser = updatedUser;
        }
      }
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar la organización del usuario
  Future<void> loadOrganization(String organizationId) async {
    if (_currentUser == null) {
      _setError('Usuario no cargado');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      // Usar SyncService que maneja cache local y sincronización
      final organization = await _syncService.getOrganization();
      _currentOrganization = organization;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar usuarios de la organización
  Future<void> loadOrganizationUsers(String organizationId) async {
    _setLoading(true);
    _clearError();

    try {
      // Por ahora, los usuarios se cargan desde el servicio original
      // En el futuro se podría implementar cache local para usuarios
      // _organizationUsers = await _syncService.getUsersByOrganization(organizationId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar estadísticas de la organización
  Future<void> _loadOrganizationStats(String organizationId) async {
    try {
      // Calcular estadísticas locales
      _organizationStats = {
        'totalUsers': _organizationUsers.length,
        'activeUsers': _organizationUsers.where((u) => u.isActive).length,
        'organizationName': _currentOrganization?.name ?? 'Sin nombre',
        'createdAt': _currentOrganization?.createdAt?.toIso8601String(),
      };
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Crear una nueva organización
  Future<String?> createOrganization(Organization organization) async {
    if (_currentUser == null) {
      _setError('Usuario no cargado');
      return null;
    }

    _setLoading(true);
    _clearError();

    try {
      // Crear organización en el servidor usando UserDataService
      final organizationId = await _userDataService.createOrganization(_currentUser!.id, organization);
      
      // Actualizar la organización con el ID generado
      final createdOrganization = organization.copyWith(id: organizationId);
      
      // Guardar organización localmente usando SyncService
      await _syncService.saveOrganization(createdOrganization);
      
      // Actualizar el usuario con el organizationId
      final updatedUser = _currentUser!.copyWith(organizationId: organizationId);
      
      // Guardar usuario actualizado localmente
      await _syncService.saveUserProfile(updatedUser);
      
      // Actualizar usuario en Firestore
      await _authService.updateUserOrganization(organizationId);
      
      _currentUser = updatedUser;
      _currentOrganization = createdOrganization;
      
      notifyListeners();
      return organizationId;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar la organización
  Future<void> updateOrganization(Organization organization) async {
    if (_currentUser == null) {
      _setError('Usuario no cargado');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      // Usar SyncService que maneja cache local y sincronización
      await _syncService.saveOrganization(organization);
      _currentOrganization = organization;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Invitar usuario a la organización
  Future<bool> inviteUser(String email, UserRole role) async {
    if (_currentOrganization == null || _currentUser == null) {
      _setError('No se puede invitar usuarios sin organización');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      // TODO: Implementar en SyncService
      // await _syncService.inviteUser(
      //   _currentUser!.id,
      //   _currentOrganization!.id,
      //   role,
      // );
      
      // Recargar usuarios de la organización
      await loadOrganizationUsers(_currentOrganization!.id);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Activar usuario
  Future<bool> activateUser(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Implementar en SyncService
      // await _syncService.activateUser(userId);
      
      // Actualizar usuario en la lista local
      final userIndex = _organizationUsers.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        _organizationUsers[userIndex] = _organizationUsers[userIndex].copyWith(isActive: true);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Suspender usuario
  Future<bool> suspendUser(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Implementar en SyncService
      // await _syncService.suspendUser(userId);
      
      // Actualizar usuario en la lista local
      final userIndex = _organizationUsers.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        _organizationUsers[userIndex] = _organizationUsers[userIndex].copyWith(isActive: false);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verificar permisos del usuario actual
  bool hasPermission(String permission) {
    if (_currentUser == null) return false;
    return _currentUser!.permissions.contains(permission) || 
           _currentUser!.role == UserRole.owner || 
           _currentUser!.role == UserRole.admin;
  }

  /// Verificar si el usuario actual puede gestionar usuarios
  bool canManageUsers() {
    if (_currentUser == null) return false;
    return _currentUser!.role == UserRole.owner || 
           _currentUser!.role == UserRole.admin ||
           _currentUser!.permissions.contains('manage_users');
  }

  /// Verificar si el usuario actual puede gestionar productos
  bool canManageProducts() {
    if (_currentUser == null) return false;
    return _currentUser!.role == UserRole.owner || 
           _currentUser!.role == UserRole.admin ||
           _currentUser!.role == UserRole.manager ||
           _currentUser!.permissions.contains('manage_products');
  }

  /// Verificar si el usuario actual puede ver reportes
  bool canViewReports() {
    if (_currentUser == null) return false;
    return _currentUser!.role == UserRole.owner || 
           _currentUser!.role == UserRole.admin ||
           _currentUser!.role == UserRole.manager ||
           _currentUser!.permissions.contains('view_reports');
  }

  /// Verificar si el usuario actual puede gestionar ventas
  bool canManageSales() {
    if (_currentUser == null) return false;
    return _currentUser!.role == UserRole.owner || 
           _currentUser!.role == UserRole.admin ||
           _currentUser!.role == UserRole.manager ||
           _currentUser!.permissions.contains('manage_sales');
  }

  /// Limpiar datos
  void clearData() {
    _currentUser = null;
    _currentOrganization = null;
    _organizationUsers.clear();
    _organizationStats.clear();
    _clearError();
    notifyListeners();
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
} 