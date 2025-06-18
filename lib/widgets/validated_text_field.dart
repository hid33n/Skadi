import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/validators.dart';

/// Campo de texto con validaciones integradas
class ValidatedTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? helperText;
  final String? errorText;
  final bool showErrorIcon;
  final EdgeInsetsGeometry? contentPadding;

  const ValidatedTextField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onEditingComplete,
    this.focusNode,
    this.autofocus = false,
    this.helperText,
    this.errorText,
    this.showErrorIcon = true,
    this.contentPadding,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _errorText;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    
    _focusNode.addListener(_onFocusChange);
    
    if (widget.initialValue != null) {
      _validateField(widget.initialValue!);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _validateField(String value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null && _errorText!.isNotEmpty;
    final isFocused = _isFocused;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          autofocus: widget.autofocus,
          onTap: widget.onTap,
          onChanged: (value) {
            _validateField(value);
            widget.onChanged?.call(value);
          },
          onEditingComplete: widget.onEditingComplete,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: hasError ? _errorText : null,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(hasError),
            contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError 
                  ? Theme.of(context).colorScheme.error
                  : isFocused 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError 
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError 
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: widget.enabled 
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.surface.withOpacity(0.5),
          ),
        ),
        if (hasError && widget.showErrorIcon) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _errorText!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon(bool hasError) {
    if (hasError && widget.showErrorIcon) {
      return Icon(
        Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      );
    }
    return widget.suffixIcon;
  }
}

/// Campo de texto para email
class EmailTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;

  const EmailTextField({
    super.key,
    this.label = 'Email',
    this.hint,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValidatedTextField(
      label: label,
      hint: hint ?? 'ejemplo@correo.com',
      initialValue: initialValue,
      controller: controller,
      validator: FormValidators.email,
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
      focusNode: focusNode,
      autofocus: autofocus,
      prefixIcon: const Icon(Icons.email_outlined),
    );
  }
}

/// Campo de texto para contraseña
class PasswordTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;

  const PasswordTextField({
    super.key,
    this.label = 'Contraseña',
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return ValidatedTextField(
      label: widget.label,
      hint: widget.hint ?? 'Ingresa tu contraseña',
      initialValue: widget.initialValue,
      controller: widget.controller,
      validator: widget.validator ?? FormValidators.password,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      prefixIcon: const Icon(Icons.lock_outlined),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}

/// Campo de texto para números
class NumberTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool allowDecimals;

  const NumberTextField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
    this.allowDecimals = true,
  });

  @override
  Widget build(BuildContext context) {
    return ValidatedTextField(
      label: label,
      hint: hint,
      initialValue: initialValue,
      controller: controller,
      validator: validator,
      keyboardType: allowDecimals 
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.number,
      onChanged: onChanged,
      focusNode: focusNode,
      autofocus: autofocus,
      inputFormatters: allowDecimals 
        ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
        : [FilteringTextInputFormatter.digitsOnly],
    );
  }
}

/// Campo de texto para precio
class PriceTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;

  const PriceTextField({
    super.key,
    this.label = 'Precio',
    this.hint,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValidatedTextField(
      label: label,
      hint: hint ?? '0.00',
      initialValue: initialValue,
      controller: controller,
      validator: FormValidators.price,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      focusNode: focusNode,
      autofocus: autofocus,
      prefixIcon: const Icon(Icons.attach_money),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
    );
  }
} 