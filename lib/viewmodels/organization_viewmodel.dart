import 'package:flutter/foundation.dart';
import '../models/organization.dart';
import '../models/user_profile.dart';
import '../services/organization_service.dart';
import '../services/user_service.dart';
import '../utils/error_handler.dart';

class OrganizationViewModel extends ChangeNotifier {
  final OrganizationService _organizationService = OrganizationService();
  final UserService _userService = UserService();

  Organization? _currentOrganization;
  UserProfile? _currentUser;
  List<UserProfile> _organizationUsers = [];
  Map<String, dynamic> _organizationStats = {};
  bool _isLoading = false;
  AppError? _error;

  // Getters
  Organization? get currentOrganization => _currentOrganization;
  UserProfile? get currentUser => _currentUser;
  List<UserProfile> get organizationUsers => _organizationUsers;
  Map<String, dynamic> get organizationStats => _organizationStats;
  bool get isLoading => _isLoading;
  AppError? get error => _error;

  /// Cargar organización actual
  Future<void> loadOrganization(String organizationId) async {
    _setLoading(true);
    _clearError();

    try {
      _currentOrganization = await _organizationService.getOrganization(organizationId);
      if (_currentOrganization != null) {
        await _loadOrganizationStats(organizationId);
      }
    } catch (e) {
      _setError(AppError.fromException(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar usuario actual
  Future<void> loadCurrentUser(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _userService.getUser(userId);
    } catch (e) {
      _setError(AppError.fromException(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar usuarios de la organización
  Future<void> loadOrganizationUsers(String organizationId) async {
    _setLoading(true);
    _clearError();

    try {
      _organizationUsers = await _userService.getUsersByOrganization(organizationId);
    } catch (e) {
      _setError(AppError.fromException(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar estadísticas de la organización
  Future<void> _loadOrganizationStats(String organizationId) async {
    try {
      _organizationStats = await _organizationService.getOrganizationStats(organizationId);
    } catch (e) {
      _setError(AppError.fromException(e));
    }
  }

  /// Crear nueva organización
  Future<String?> createOrganization(Organization organization) async {
    _setLoading(true);
    _clearError();

    try {
      final organizationId = await _organizationService.createOrganization(organization);
      _currentOrganization = organization;
      return organizationId;
    } catch (e) {
      _setError(AppError.fromException(e));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar organización
  Future<bool> updateOrganization(Organization organization) async {
    _setLoading(true);
    _clearError();

    try {
      await _organizationService.updateOrganization(organization.id, organization);
      _currentOrganization = organization;
      return true;
    } catch (e) {
      _setError(AppError.fromException(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Invitar usuario a la organización
  Future<bool> inviteUser(String email, UserRole role) async {
    if (_currentOrganization == null || _currentUser == null) {
      _setError(AppError.validation('No se puede invitar usuarios sin organización'));
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _userService.inviteUser(
        email,
        _currentOrganization!.id,
        role,
        _currentUser!.id,
      );
      
      // Recargar usuarios de la organización
      await loadOrganizationUsers(_currentOrganization!.id);
      return true;
    } catch (e) {
      _setError(AppError.fromException(e));
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
      await _userService.activateUser(userId);
      
      // Actualizar usuario en la lista local
      final userIndex = _organizationUsers.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        _organizationUsers[userIndex] = _organizationUsers[userIndex].copyWith(
          status: UserStatus.active,
        );
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(AppError.fromException(e));
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
      await _userService.suspendUser(userId);
      
      // Actualizar usuario en la lista local
      final userIndex = _organizationUsers.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        _organizationUsers[userIndex] = _organizationUsers[userIndex].copyWith(
          status: UserStatus.suspended,
        );
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(AppError.fromException(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verificar permisos del usuario actual
  bool hasPermission(String permission) {
    return _currentUser?.hasPermission(permission) ?? false;
  }

  /// Verificar si el usuario actual puede gestionar usuarios
  bool canManageUsers() {
    return _currentUser?.canManageUsers() ?? false;
  }

  /// Verificar si el usuario actual puede gestionar productos
  bool canManageProducts() {
    return _currentUser?.canManageProducts() ?? false;
  }

  /// Verificar si el usuario actual puede ver reportes
  bool canViewReports() {
    return _currentUser?.canViewReports() ?? false;
  }

  /// Verificar si el usuario actual puede gestionar ventas
  bool canManageSales() {
    return _currentUser?.canManageSales() ?? false;
  }

  /// Limpiar datos
  void clear() {
    _currentOrganization = null;
    _currentUser = null;
    _organizationUsers.clear();
    _organizationStats.clear();
    _clearError();
    notifyListeners();
  }

  // Métodos privados para manejo de estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(AppError error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
} 