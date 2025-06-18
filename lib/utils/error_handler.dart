import 'package:flutter/material.dart';

/// Tipos de errores personalizados para la aplicación
enum ErrorType {
  network,
  authentication,
  validation,
  database,
  permission,
  unknown,
  timeout,
  server,
}

/// Clase para manejar errores de manera consistente
class AppError {
  final String message;
  final ErrorType type;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppError({
    required this.message,
    required this.type,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  /// Crear error desde una excepción
  factory AppError.fromException(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppError) return error;

    String message = 'Ha ocurrido un error inesperado';
    ErrorType type = ErrorType.unknown;

    if (error.toString().contains('network') || 
        error.toString().contains('connection') ||
        error.toString().contains('internet')) {
      type = ErrorType.network;
      message = 'Error de conexión. Verifica tu conexión a internet.';
    } else if (error.toString().contains('auth') || 
               error.toString().contains('login') ||
               error.toString().contains('unauthorized')) {
      type = ErrorType.authentication;
      message = 'Error de autenticación. Por favor, inicia sesión nuevamente.';
    } else if (error.toString().contains('permission') || 
               error.toString().contains('forbidden')) {
      type = ErrorType.permission;
      message = 'No tienes permisos para realizar esta acción.';
    } else if (error.toString().contains('timeout')) {
      type = ErrorType.timeout;
      message = 'La operación ha tardado demasiado. Inténtalo nuevamente.';
    } else if (error.toString().contains('server') || 
               error.toString().contains('500')) {
      type = ErrorType.server;
      message = 'Error del servidor. Inténtalo más tarde.';
    }

    return AppError(
      message: message,
      type: type,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Crear error de validación
  factory AppError.validation(String message) {
    return AppError(
      message: message,
      type: ErrorType.validation,
    );
  }

  /// Crear error de red
  factory AppError.network(String message) {
    return AppError(
      message: message,
      type: ErrorType.network,
    );
  }

  /// Crear error de autenticación
  factory AppError.authentication(String message) {
    return AppError(
      message: message,
      type: ErrorType.authentication,
    );
  }

  /// Crear error de permisos
  factory AppError.permission(String message) {
    return AppError(
      message: message,
      type: ErrorType.permission,
    );
  }

  @override
  String toString() => 'AppError($type): $message';
}

/// Clase para manejar errores de manera global
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// Manejar error y mostrar mensaje apropiado
  void handleError(BuildContext context, dynamic error, {VoidCallback? onRetry}) {
    final appError = AppError.fromException(error);
    
    switch (appError.type) {
      case ErrorType.authentication:
        _showAuthError(context, appError);
        break;
      case ErrorType.network:
        _showNetworkError(context, appError, onRetry);
        break;
      case ErrorType.validation:
        _showValidationError(context, appError);
        break;
      case ErrorType.permission:
        _showPermissionError(context, appError);
        break;
      case ErrorType.timeout:
        _showTimeoutError(context, appError, onRetry);
        break;
      case ErrorType.server:
        _showServerError(context, appError, onRetry);
        break;
      default:
        _showGenericError(context, appError, onRetry);
    }

    // Log del error para debugging
    _logError(appError);
  }

  void _showAuthError(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(error.message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Iniciar Sesión',
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
        ),
      ),
    );
  }

  void _showNetworkError(BuildContext context, AppError error, VoidCallback? onRetry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Error de Conexión'),
          ],
        ),
        content: Text(error.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Reintentar'),
            ),
        ],
      ),
    );
  }

  void _showValidationError(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(error.message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showPermissionError(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lock, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(error.message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showTimeoutError(BuildContext context, AppError error, VoidCallback? onRetry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.timer_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Tiempo Agotado'),
          ],
        ),
        content: Text(error.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Reintentar'),
            ),
        ],
      ),
    );
  }

  void _showServerError(BuildContext context, AppError error, VoidCallback? onRetry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error del Servidor'),
          ],
        ),
        content: Text(error.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Reintentar'),
            ),
        ],
      ),
    );
  }

  void _showGenericError(BuildContext context, AppError error, VoidCallback? onRetry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(error.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Reintentar'),
            ),
        ],
      ),
    );
  }

  void _logError(AppError error) {
    // En producción, esto se enviaría a un servicio de logging
    print('ERROR: ${error.toString()}');
    if (error.originalError != null) {
      print('Original error: ${error.originalError}');
    }
    if (error.stackTrace != null) {
      print('Stack trace: ${error.stackTrace}');
    }
  }
}

/// Extensión para facilitar el manejo de errores
extension ErrorHandlerExtension on BuildContext {
  void showError(dynamic error, {VoidCallback? onRetry}) {
    ErrorHandler().handleError(this, error, onRetry: onRetry);
  }
} 