import 'package:flutter/material.dart';
import '../theme/animations.dart';
import '../theme/responsive.dart';

class AdvancedSearch extends StatefulWidget {
  final Function(String) onSearch;
  final List<String>? filters;
  final Map<String, List<String>>? filterOptions;
  final String? initialQuery;
  final String hintText;
  final bool showFilters;

  const AdvancedSearch({
    Key? key,
    required this.onSearch,
    this.filters,
    this.filterOptions,
    this.initialQuery,
    this.hintText = 'Buscar...',
    this.showFilters = true,
  }) : super(key: key);

  @override
  State<AdvancedSearch> createState() => _AdvancedSearchState();
}

class _AdvancedSearchState extends State<AdvancedSearch> {
  late TextEditingController _controller;
  bool _showFilters = false;
  Map<String, String> _selectedFilters = {};

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    String searchQuery = query;
    if (_selectedFilters.isNotEmpty) {
      searchQuery += ' ' + _selectedFilters.values.join(' ');
    }
    widget.onSearch(searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppAnimations.combinedAnimation(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: widget.showFilters
                  ? IconButton(
                      icon: Icon(
                        _showFilters ? Icons.filter_list : Icons.filter_list_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _handleSearch,
          ),
        ),
        if (widget.showFilters && _showFilters && widget.filters != null)
          AppAnimations.combinedAnimation(
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.filters!.map((filter) {
                  return FilterChip(
                    label: Text(filter),
                    selected: _selectedFilters.containsKey(filter),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedFilters[filter] = filter;
                        } else {
                          _selectedFilters.remove(filter);
                        }
                      });
                      _handleSearch(_controller.text);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        if (widget.showFilters &&
            _showFilters &&
            widget.filterOptions != null &&
            _selectedFilters.isNotEmpty)
          AppAnimations.combinedAnimation(
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _selectedFilters.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (widget.filterOptions![entry.key] ?? [])
                            .map((option) {
                          return ChoiceChip(
                            label: Text(option),
                            selected: _selectedFilters[entry.key] == option,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedFilters[entry.key] = option;
                                } else {
                                  _selectedFilters.remove(entry.key);
                                }
                              });
                              _handleSearch(_controller.text);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
} 