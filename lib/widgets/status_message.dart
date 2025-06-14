import 'package:flutter/material.dart';

enum StatusType {
  loading,
  error,
  empty,
  success,
}

class StatusMessage extends StatelessWidget {
  final StatusType type;
  final String message;
  final VoidCallback? onRetry;
  final Widget? customIcon;
  final Widget? customContent;

  const StatusMessage({
    super.key,
    required this.type,
    required this.message,
    this.onRetry,
    this.customIcon,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget icon = customIcon ?? _getDefaultIcon(theme);
    Widget content = customContent ?? _getDefaultContent(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
            content,
          ],
        ),
      ),
    );
  }

  Widget _getDefaultIcon(ThemeData theme) {
    switch (type) {
      case StatusType.loading:
        return const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(),
        );
      case StatusType.error:
        return Icon(
          Icons.error_outline,
          size: 48,
          color: theme.colorScheme.error,
        );
      case StatusType.empty:
        return Icon(
          Icons.inbox_outlined,
          size: 48,
          color: theme.colorScheme.primary,
        );
      case StatusType.success:
        return Icon(
          Icons.check_circle_outline,
          size: 48,
          color: theme.colorScheme.primary,
        );
    }
  }

  Widget _getDefaultContent(BuildContext context) {
    switch (type) {
      case StatusType.loading:
        return const SizedBox.shrink();
      case StatusType.error:
        return const SizedBox.shrink();
      case StatusType.empty:
        return const SizedBox.shrink();
      case StatusType.success:
        return const SizedBox.shrink();
    }
  }
} 