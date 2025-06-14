import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String? message;
  final List<Widget>? actions;
  final Widget? content;
  final bool showCloseButton;
  final Color? backgroundColor;
  final double? maxWidth;
  final double? maxHeight;
  final EdgeInsetsGeometry? contentPadding;
  final bool barrierDismissible;
  final VoidCallback? onDismissed;

  const CustomDialog({
    super.key,
    required this.title,
    this.message,
    this.actions,
    this.content,
    this.showCloseButton = true,
    this.backgroundColor,
    this.maxWidth,
    this.maxHeight,
    this.contentPadding,
    this.barrierDismissible = true,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: backgroundColor ?? theme.dialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 400,
          maxHeight: maxHeight ?? 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  if (showCloseButton)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onDismissed?.call();
                      },
                    ),
                ],
              ),
            ),
            if (message != null || content != null)
              Flexible(
                child: SingleChildScrollView(
                  padding: contentPadding ?? const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (message != null)
                        Text(
                          message!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      if (content != null) ...[
                        if (message != null) const SizedBox(height: 16),
                        content!,
                      ],
                    ],
                  ),
                ),
              ),
            if (actions != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!
                      .map((action) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: action,
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    List<Widget>? actions,
    Widget? content,
    bool showCloseButton = true,
    Color? backgroundColor,
    double? maxWidth,
    double? maxHeight,
    EdgeInsetsGeometry? contentPadding,
    bool barrierDismissible = true,
    VoidCallback? onDismissed,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        actions: actions,
        content: content,
        showCloseButton: showCloseButton,
        backgroundColor: backgroundColor,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        contentPadding: contentPadding,
        onDismissed: onDismissed,
      ),
    );
  }

  static Future<bool> showConfirmation({
    required BuildContext context,
    required String title,
    String? message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color? confirmColor,
    Color? cancelColor,
    bool barrierDismissible = true,
  }) async {
    final result = await show<bool>(
      context: context,
      title: title,
      message: message,
      barrierDismissible: barrierDismissible,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: TextStyle(color: cancelColor),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
          ),
          child: Text(confirmText),
        ),
      ],
    );
    return result ?? false;
  }

  static Future<void> showAlert({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'Aceptar',
    Color? buttonColor,
    bool barrierDismissible = true,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      barrierDismissible: barrierDismissible,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
          ),
          child: Text(buttonText),
        ),
      ],
    );
  }
} 