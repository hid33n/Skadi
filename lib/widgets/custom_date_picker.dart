import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime) onDateSelected;
  final String? label;
  final String? hint;
  final bool enabled;
  final bool isRequired;
  final String? errorText;
  final bool showError;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool showTime;
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay)? onTimeSelected;

  const CustomDatePicker({
    super.key,
    this.selectedDate,
    this.firstDate,
    this.lastDate,
    required this.onDateSelected,
    this.label,
    this.hint,
    this.enabled = true,
    this.isRequired = false,
    this.errorText,
    this.showError = true,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.padding,
    this.width,
    this.height,
    this.showTime = false,
    this.selectedTime,
    this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: enabled ? () => _selectDate(context) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: width,
            height: height,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor ?? theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: showError && errorText != null
                    ? theme.colorScheme.error
                    : theme.dividerColor,
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: iconColor ?? theme.iconTheme.color,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? showTime && selectedTime != null
                            ? '${dateFormat.format(selectedDate!)} ${timeFormat.format(DateTime(2000, 1, 1, selectedTime!.hour, selectedTime!.minute))}'
                            : dateFormat.format(selectedDate!)
                        : hint ?? 'Seleccionar fecha',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: selectedDate != null
                          ? theme.textTheme.bodyMedium?.color
                          : theme.hintColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: theme.iconTheme.color,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showError && errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final firstDate = this.firstDate ?? DateTime(2000);
    final lastDate = this.lastDate ?? DateTime(now.year + 10);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (showTime) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: theme.colorScheme.primary,
                  onPrimary: theme.colorScheme.onPrimary,
                  surface: theme.colorScheme.surface,
                  onSurface: theme.colorScheme.onSurface,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedTime != null) {
          onDateSelected(pickedDate);
          onTimeSelected?.call(pickedTime);
        }
      } else {
        onDateSelected(pickedDate);
      }
    }
  }
} 