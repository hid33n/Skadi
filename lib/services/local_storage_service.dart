import 'dart:convert';
import 'dart:html' as html;
import '../models/user_profile.dart';
import '../utils/error_handler.dart';

class LocalStorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _settingsKey = 'app_settings';
  static const String _themeKey = 'theme_mode';
  
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Inicializar el servicio
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Verificar que localStorage está disponible
      if (html.window.localStorage == null) {
        throw AppError.validation('localStorage no está disponible');
      }
      
      _isInitialized = true;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Guardar perfil de usuario
  Future<void> saveUserProfile(UserProfile profile) async {
    if (!_isInitialized) await initialize();
    
    try {
      final data = profile.toMap();
      html.window.localStorage[_userProfileKey] = jsonEncode(data);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Obtener perfil de usuario
  Future<UserProfile?> getUserProfile() async {
    if (!_isInitialized) await initialize();
    
    try {
      final data = html.window.localStorage[_userProfileKey];
      if (data != null) {
        final map = jsonDecode(data) as Map<String, dynamic>;
        final id = map['id'] as String;
        return UserProfile.fromMap(map, id);
      }
      return null;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Eliminar perfil de usuario
  Future<void> clearUserProfile() async {
    if (!_isInitialized) await initialize();
    
    try {
      html.window.localStorage.remove(_userProfileKey);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Guardar configuración
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    if (!_isInitialized) await initialize();
    
    try {
      html.window.localStorage[_settingsKey] = jsonEncode(settings);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Obtener configuración
  Future<Map<String, dynamic>> getSettings() async {
    if (!_isInitialized) await initialize();
    
    try {
      final data = html.window.localStorage[_settingsKey];
      if (data != null) {
        return Map<String, dynamic>.from(jsonDecode(data));
      }
      return {};
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Guardar modo de tema
  Future<void> saveThemeMode(String themeMode) async {
    if (!_isInitialized) await initialize();
    
    try {
      html.window.localStorage[_themeKey] = themeMode;
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Obtener modo de tema
  Future<String?> getThemeMode() async {
    if (!_isInitialized) await initialize();
    
    try {
      return html.window.localStorage[_themeKey];
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Limpiar todos los datos
  Future<void> clearAll() async {
    if (!_isInitialized) await initialize();
    
    try {
      html.window.localStorage.clear();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  /// Obtener estadísticas de almacenamiento
  Map<String, dynamic> getStorageStats() {
    return {
      'isInitialized': _isInitialized,
      'hasUserProfile': html.window.localStorage[_userProfileKey] != null,
      'hasSettings': html.window.localStorage[_settingsKey] != null,
      'hasTheme': html.window.localStorage[_themeKey] != null,
    };
  }
} 