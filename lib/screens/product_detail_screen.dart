import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/movement.dart';
import '../models/category.dart';
import '../viewmodels/product_viewmodel.dart';
import '../viewmodels/movement_viewmodel.dart';
import '../services/firestore_service.dart';
import 'edit_product_screen.dart';
import '../widgets/custom_snackbar.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoading = false;
  String? _categoryName;
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();
  MovementType _selectedType = MovementType.entry;

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadCategory() async {
    try {
      final category = await context.read<FirestoreService>().getCategoryById(widget.product.categoryId);
      if (mounted) {
        setState(() {
          _categoryName = category?.name ?? 'Sin categoría';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categoryName = 'Error al cargar categoría';
        });
      }
    }
  }

  Future<void> _addMovement() async {
    if (_quantityController.text.isEmpty) {
      CustomSnackBar.showError(
        context: context,
        message: 'Por favor ingresa una cantidad',
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      CustomSnackBar.showError(
        context: context,
        message: 'La cantidad debe ser un número positivo',
      );
      return;
    }

    if (_selectedType == MovementType.exit && quantity > widget.product.stock) {
      CustomSnackBar.showError(
        context: context,
        message: 'No hay suficiente stock disponible',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final movement = Movement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: widget.product.id,
        productName: widget.product.name,
        quantity: quantity,
        type: _selectedType,
        date: DateTime.now(),
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      await context.read<MovementViewModel>().addMovement(movement);
      await context.read<ProductViewModel>().loadProducts();

      if (mounted) {
        CustomSnackBar.showSuccess(
          context: context,
          message: 'Movimiento registrado correctamente',
        );
        _quantityController.clear();
        _noteController.clear();
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(
          context: context,
          message: 'Error al registrar movimiento: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProductScreen(
                    product: widget.product,
                  ),
                ),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Producto',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Nombre', widget.product.name),
                    _buildInfoRow('Descripción', widget.product.description),
                    _buildInfoRow('Categoría', _categoryName ?? 'Cargando...'),
                    _buildInfoRow(
                      'Precio',
                      '\$${widget.product.price.toStringAsFixed(2)}',
                    ),
                    _buildInfoRow(
                      'Stock Actual',
                      '${widget.product.stock} unidades',
                    ),
                    _buildInfoRow(
                      'Stock Mínimo',
                      '${widget.product.minStock} unidades',
                    ),
                    _buildInfoRow(
                      'Stock Máximo',
                      '${widget.product.maxStock} unidades',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registrar Movimiento',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<MovementType>(
                      segments: const [
                        ButtonSegment(
                          value: MovementType.entry,
                          label: Text('Entrada'),
                          icon: Icon(Icons.add),
                        ),
                        ButtonSegment(
                          value: MovementType.exit,
                          label: Text('Salida'),
                          icon: Icon(Icons.remove),
                        ),
                      ],
                      selected: {_selectedType},
                      onSelectionChanged: (Set<MovementType> selected) {
                        setState(() {
                          _selectedType = selected.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Nota (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addMovement,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Registrar Movimiento'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Últimos Movimientos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Consumer<MovementViewModel>(
                      builder: (context, movementVM, child) {
                        if (movementVM.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final movements = movementVM.getMovementsByProduct(widget.product.id);
                        if (movements.isEmpty) {
                          return const Center(
                            child: Text('No hay movimientos registrados'),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: movements.length,
                          itemBuilder: (context, index) {
                            final movement = movements[index];
                            return ListTile(
                              leading: Icon(
                                movement.type == MovementType.entry
                                    ? Icons.add_circle_outline
                                    : Icons.remove_circle_outline,
                                color: movement.type == MovementType.entry
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: Text(
                                '${movement.type == MovementType.entry ? "Entrada" : "Salida"} de ${movement.quantity} unidades',
                              ),
                              subtitle: Text(
                                movement.note ?? 'Sin nota',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Text(
                                movement.date.toString().split('.')[0],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
} 