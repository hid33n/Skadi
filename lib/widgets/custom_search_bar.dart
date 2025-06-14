import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final String hint;
  final String? initialValue;
  final Function(String) onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final List<String>? suggestions;
  final bool showFilter;
  final List<String>? filters;
  final String? selectedFilter;
  final Function(String)? onFilterSelected;
  final bool autofocus;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Widget? leading;
  final Widget? trailing;

  const CustomSearchBar({
    super.key,
    this.hint = 'Buscar...',
    this.initialValue,
    required this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.suggestions,
    this.showFilter = false,
    this.filters,
    this.selectedFilter,
    this.onFilterSelected,
    this.autofocus = false,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.leading,
    this.trailing,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
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
      if (_isFocused && widget.suggestions != null) {
        _showSuggestions = true;
      }
    });
  }

  void _onChanged(String value) {
    widget.onChanged(value);
    if (widget.suggestions != null) {
      setState(() {
        _showSuggestions = value.isNotEmpty;
      });
    }
  }

  void _onSubmitted(String value) {
    setState(() {
      _showSuggestions = false;
    });
    widget.onSubmitted?.call(value);
  }

  void _onSuggestionSelected(String suggestion) {
    _controller.text = suggestion;
    _onChanged(suggestion);
    _onSubmitted(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          color: widget.backgroundColor ?? theme.cardColor,
          elevation: widget.elevation ?? 2,
          shape: widget.shape ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(8),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    autofocus: widget.autofocus,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: _onChanged,
                    onSubmitted: _onSubmitted,
                  ),
                ),
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      widget.onClear?.call();
                      _onChanged('');
                    },
                  ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: 8),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
        if (widget.showFilter && widget.filters != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.filters!
                    .map(
                      (filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: filter == widget.selectedFilter,
                          onSelected: (selected) {
                            widget.onFilterSelected?.call(filter);
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        if (_showSuggestions && widget.suggestions != null)
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: widget.suggestions!.length,
              itemBuilder: (context, index) {
                final suggestion = widget.suggestions![index];
                return ListTile(
                  title: Text(suggestion),
                  onTap: () => _onSuggestionSelected(suggestion),
                );
              },
            ),
          ),
      ],
    );
  }
} 