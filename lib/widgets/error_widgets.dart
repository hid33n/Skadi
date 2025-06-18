import 'package:flutter/material.dart';
import '../utils/error_handler.dart';

/// Widget para mostrar estado de error con opción de reintentar
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;
  final String? retryText;
  final String? backText;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onRetry,
    this.onBack,
    this.retryText,
    this.backText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (onRetry != null || onBack != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onBack != null) ...[
                    OutlinedButton(
                      onPressed: onBack,
                      child: Text(backText ?? 'Volver'),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (onRetry != null)
                    ElevatedButton(
                      onPressed: onRetry,
                      child: Text(retryText ?? 'Reintentar'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar estado de carga
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final double? size;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size ?? 48,
              height: size ?? 48,
              child: const CircularProgressIndicator(),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar estado vacío
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText ?? 'Agregar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget para manejar estados de carga, error y vacío
class StateHandlerWidget extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final bool isEmpty;
  final Widget child;
  final String? loadingMessage;
  final String? emptyMessage;
  final String? emptyTitle;
  final IconData? emptyIcon;
  final VoidCallback? onRetry;
  final VoidCallback? onEmptyAction;
  final String? emptyActionText;

  const StateHandlerWidget({
    super.key,
    required this.isLoading,
    this.error,
    this.isEmpty = false,
    required this.child,
    this.loadingMessage,
    this.emptyMessage,
    this.emptyTitle,
    this.emptyIcon,
    this.onRetry,
    this.onEmptyAction,
    this.emptyActionText,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingStateWidget(message: loadingMessage);
    }

    if (error != null) {
      return ErrorStateWidget(
        message: error!,
        onRetry: onRetry,
      );
    }

    if (isEmpty) {
      return EmptyStateWidget(
        message: emptyMessage ?? 'No hay datos disponibles',
        title: emptyTitle,
        icon: emptyIcon,
        onAction: onEmptyAction,
        actionText: emptyActionText,
      );
    }

    return child;
  }
}

/// Widget para mostrar errores de red específicamente
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: 'Error de Conexión',
      message: message ?? 'No se pudo conectar al servidor. Verifica tu conexión a internet.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      retryText: 'Reintentar',
    );
  }
}

/// Widget para mostrar errores de autenticación
class AuthErrorWidget extends StatelessWidget {
  final VoidCallback? onLogin;

  const AuthErrorWidget({
    super.key,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: 'Error de Autenticación',
      message: 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
      icon: Icons.lock_outline,
      onRetry: onLogin,
      retryText: 'Iniciar Sesión',
    );
  }
}

/// Widget para mostrar errores de permisos
class PermissionErrorWidget extends StatelessWidget {
  final String? message;

  const PermissionErrorWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: 'Sin Permisos',
      message: message ?? 'No tienes permisos para realizar esta acción.',
      icon: Icons.block,
    );
  }
} 