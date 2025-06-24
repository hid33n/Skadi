import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import '../theme/theme_provider.dart';

class ThemeViewModel extends foundation.ChangeNotifier {
  final ThemeProvider _themeProvider;
  
  bool _isLoading = false;
  String? _error;

  ThemeViewModel(this._themeProvider);

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isDarkMode => _themeProvider.isDarkMode;

  Future<void> toggleTheme() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 ThemeViewModel: Cambiando tema');
      
      final newMode = _themeProvider.isDarkMode ? ThemeMode.light : ThemeMode.dark;
      await _themeProvider.setThemeMode(newMode);
      
      print('✅ ThemeViewModel: Tema cambiado exitosamente');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 ThemeViewModel: Estableciendo modo ${isDark ? 'oscuro' : 'claro'}');
      
      final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
      await _themeProvider.setThemeMode(newMode);
      
      print('✅ ThemeViewModel: Modo establecido exitosamente');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 