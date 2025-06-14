import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movement.dart';
import '../viewmodels/movement_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';

class MovementHistoryScreen extends StatefulWidget {
  const MovementHistoryScreen({super.key});

  @override
  State<MovementHistoryScreen> createState() => _MovementHistoryScreenState();
}

class _MovementHistoryScreenState extends State<MovementHistoryScreen> {
  String _searchQuery = '';
  MovementType? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final movementViewModel = context.read<MovementViewModel>();
    final productViewModel = context.read<ProductViewModel>();
    await Future.wait([
      movementViewModel.loadMovements(),
      productViewModel.loadProducts(),
    ]);
  }

  List<Movement> _getFilteredMovements(List<Movement> movements) {
    return movements.where((movement) {
      final matchesSearch = movement.productName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _selectedType == null || movement.type == _selectedType;
      final matchesDate = (_startDate == null || movement.date.isAfter(_startDate!)) &&
          (_endDate == null || movement.date.isBefore(_endDate!));
      return matchesSearch && matchesType && matchesDate;
    }).toList();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<MovementViewModel, ProductViewModel>(
        builder: (context, movementVM, productVM, child) {
          if (movementVM.isLoading || productVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (movementVM.error.isNotEmpty) {
            return Center(child: Text('Error: ${movementVM.error}'));
          }

          final movements = _getFilteredMovements(movementVM.movements);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre de producto...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SegmentedButton<MovementType?>(
                            segments: const [
                              ButtonSegment(
                                value: null,
                                label: Text('Todos'),
                              ),
                              ButtonSegment(
                                value: MovementType.entry,
                                label: Text('Entradas'),
                                icon: Icon(Icons.add),
                              ),
                              ButtonSegment(
                                value: MovementType.exit,
                                label: Text('Salidas'),
                                icon: Icon(Icons.remove),
                              ),
                            ],
                            selected: {_selectedType},
                            onSelectionChanged: (Set<MovementType?> selected) {
                              setState(() {
                                _selectedType = selected.first;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: _selectDateRange,
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            _startDate != null && _endDate != null
                                ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                : 'Seleccionar rango de fechas',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: movements.isEmpty
                    ? const Center(
                        child: Text('No se encontraron movimientos'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: movements.length,
                        itemBuilder: (context, index) {
                          final movement = movements[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: movement.type == MovementType.entry
                                    ? Colors.green[100]
                                    : Colors.red[100],
                                child: Icon(
                                  movement.type == MovementType.entry
                                      ? Icons.add
                                      : Icons.remove,
                                  color: movement.type == MovementType.entry
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              title: Text(
                                movement.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${movement.type == MovementType.entry ? "Entrada" : "Salida"} de ${movement.quantity} unidades',
                                  ),
                                  if (movement.note != null)
                                    Text(
                                      movement.note!,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Text(
                                movement.date.toString().split('.')[0],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
} 