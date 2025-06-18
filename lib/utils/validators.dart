import '../utils/error_handler.dart';

/// Clase para manejar validaciones de formularios
class FormValidators {
  /// Validar que el campo no esté vacío
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }

  /// Validar email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El email es requerido';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    
    return null;
  }

  /// Validar contraseña
  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    return null;
  }

  /// Validar confirmación de contraseña
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirma tu contraseña';
    }
    
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }

  /// Validar número
  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    
    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'Este campo'} debe ser un número válido';
    }
    
    return null;
  }

  /// Validar número positivo
  static String? positiveNumber(String? value, {String? fieldName}) {
    final numberError = number(value, fieldName: fieldName);
    if (numberError != null) return numberError;
    
    final numValue = double.parse(value!);
    if (numValue <= 0) {
      return '${fieldName ?? 'Este campo'} debe ser mayor a 0';
    }
    
    return null;
  }

  /// Validar precio
  static String? price(String? value) {
    return positiveNumber(value, fieldName: 'El precio');
  }

  /// Validar stock
  static String? stock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El stock es requerido';
    }
    
    final numValue = int.tryParse(value);
    if (numValue == null) {
      return 'El stock debe ser un número entero';
    }
    
    if (numValue < 0) {
      return 'El stock no puede ser negativo';
    }
    
    return null;
  }

  /// Validar longitud mínima
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    
    if (value.length < minLength) {
      return '${fieldName ?? 'Este campo'} debe tener al menos $minLength caracteres';
    }
    
    return null;
  }

  /// Validar longitud máxima
  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Campo vacío es válido para maxLength
    }
    
    if (value.length > maxLength) {
      return '${fieldName ?? 'Este campo'} no puede tener más de $maxLength caracteres';
    }
    
    return null;
  }

  /// Validar nombre de producto
  static String? productName(String? value) {
    final requiredError = required(value, fieldName: 'El nombre del producto');
    if (requiredError != null) return requiredError;
    
    final minLengthError = minLength(value, 2, fieldName: 'El nombre del producto');
    if (minLengthError != null) return minLengthError;
    
    final maxLengthError = maxLength(value, 100, fieldName: 'El nombre del producto');
    if (maxLengthError != null) return maxLengthError;
    
    return null;
  }

  /// Validar descripción
  static String? description(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Descripción es opcional
    }
    
    final maxLengthError = maxLength(value, 500, fieldName: 'La descripción');
    if (maxLengthError != null) return maxLengthError;
    
    return null;
  }

  /// Validar nombre de categoría
  static String? categoryName(String? value) {
    final requiredError = required(value, fieldName: 'El nombre de la categoría');
    if (requiredError != null) return requiredError;
    
    final minLengthError = minLength(value, 2, fieldName: 'El nombre de la categoría');
    if (minLengthError != null) return minLengthError;
    
    final maxLengthError = maxLength(value, 50, fieldName: 'El nombre de la categoría');
    if (maxLengthError != null) return maxLengthError;
    
    return null;
  }

  /// Validar cantidad de venta
  static String? saleQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La cantidad es requerida';
    }
    
    final numValue = int.tryParse(value);
    if (numValue == null) {
      return 'La cantidad debe ser un número entero';
    }
    
    if (numValue <= 0) {
      return 'La cantidad debe ser mayor a 0';
    }
    
    return null;
  }

  /// Validar teléfono
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Teléfono es opcional
    }
    
    // Validar formato básico de teléfono
    final phoneRegex = RegExp(r'^[\+]?[0-9\s\-\(\)]{7,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Ingresa un número de teléfono válido';
    }
    
    return null;
  }

  /// Validar código postal
  static String? postalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Código postal es opcional
    }
    
    final postalRegex = RegExp(r'^[0-9]{4,6}$');
    if (!postalRegex.hasMatch(value)) {
      return 'Ingresa un código postal válido';
    }
    
    return null;
  }

  /// Validar múltiples validadores
  static String? validateMultiple(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }

  /// Validar que al menos un campo esté lleno
  static String? atLeastOne(List<String?> values, List<String> fieldNames) {
    bool hasValue = false;
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        hasValue = true;
        break;
      }
    }
    
    if (!hasValue) {
      return 'Al menos uno de estos campos debe estar lleno: ${fieldNames.join(', ')}';
    }
    
    return null;
  }
}

/// Clase para manejar validaciones de formularios con estado
class FormValidator {
  final Map<String, String?> _errors = {};
  final Map<String, bool> _touched = {};

  /// Validar un campo específico
  String? validateField(String fieldName, String? value, String? Function(String?) validator) {
    final error = validator(value);
    _errors[fieldName] = error;
    return error;
  }

  /// Marcar campo como tocado
  void touchField(String fieldName) {
    _touched[fieldName] = true;
  }

  /// Verificar si un campo tiene error
  bool hasError(String fieldName) {
    return _errors[fieldName] != null && _touched[fieldName] == true;
  }

  /// Obtener error de un campo
  String? getError(String fieldName) {
    return hasError(fieldName) ? _errors[fieldName] : null;
  }

  /// Verificar si el formulario es válido
  bool get isValid => _errors.values.every((error) => error == null);

  /// Limpiar errores
  void clearErrors() {
    _errors.clear();
    _touched.clear();
  }

  /// Obtener todos los errores
  Map<String, String?> get errors => Map.unmodifiable(_errors);

  /// Verificar si hay errores
  bool get hasErrors => _errors.values.any((error) => error != null);
} 