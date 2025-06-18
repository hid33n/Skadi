import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/movement.dart';
import '../models/category.dart';
import '../viewmodels/product_viewmodel.dart';
import '../viewmodels/movement_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/organization_viewmodel.dart';
import '../services/firestore_service.dart';
import '../utils/error_handler.dart';
import 'edit_product_screen.dart';

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
    final organizationViewModel = context.read<OrganizationViewModel>();
    final organizationId = organizationViewModel.currentOrganization?.id;
    
    if (organizationId != null) {
      try {
        final categoryViewModel = context.read<CategoryViewModel>();
        await categoryViewModel.loadCategories(organizationId);
        
        final category = categoryViewModel.categories.firstWhere(
          (c) => c.id == widget.product.categoryId,
          orElse: () => Category(
            id: '',
            name: 'Sin categoría',
            description: 'Categoría no encontrada',
            organizationId: organizationId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        
        if (mounted) {
          setState(() {
            _categoryName = category.name;
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
  }

  Future<void> _addMovement() async {
    if (_quantityController.text.isEmpty) {
      context.showError('Por favor ingresa una cantidad');
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      context.showError('La cantidad debe ser un número positivo');
      return;
    }

    if (_selectedType == MovementType.exit && quantity > widget.product.stock) {
      context.showError('No hay suficiente stock disponible');
      return;
    }

    final organizationViewModel = context.read<OrganizationViewModel>();
    final organizationId = organizationViewModel.currentOrganization?.id;
    
    if (organizationId == null) {
      context.showError('No se pudo obtener la información de la organización');
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
        organizationId: organizationId,
      );

      await context.read<MovementViewModel>().addMovement(movement);
      await context.read<ProductViewModel>().loadProducts(organizationId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Movimiento registrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _quantityController.clear();
        _noteController.clear();
      }
    } catch (e) {
      if (mounted) {
        context.showError(e);
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
            tooltip: 'Editar producto',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Información del Producto',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Nombre', widget.product.name),
                    _buildInfoRow('Descripción', widget.product.description),
                    _buildInfoRow('Categoría', _categoryName ?? 'Cargando...'),
                    _buildInfoRow(
                      'Precio',
                      '\$${widget.product.price.toStringAsFixed(2)}',
                    ),
                    _buildStockInfo(),
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
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.swap_horiz,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Registrar Movimiento',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                        labelText: 'Cantidad *',
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
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _addMovement,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.add),
                        label: Text(_isLoading ? 'Registrando...' : 'Registrar Movimiento'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: Colors.purple,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Últimos Movimientos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Consumer<MovementViewModel>(
                      builder: (context, movementVM, child) {
                        if (movementVM.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (movementVM.error != null && movementVM.error!.isNotEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red[300],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  movementVM.error!,
                                  style: const TextStyle(fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        final movements = movementVM.getMovementsByProduct(widget.product.id);
                        if (movements.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'No hay movimientos registrados',
                                  style: TextStyle(fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: movements.length,
                          itemBuilder: (context, index) {
                            final movement = movements[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: movement.type == MovementType.entry
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    movement.type == MovementType.entry
                                        ? Icons.add_circle_outline
                                        : Icons.remove_circle_outline,
                                    color: movement.type == MovementType.entry
                                        ? Colors.green
                                        : Colors.red,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  '${movement.type == MovementType.entry ? "Entrada" : "Salida"} de ${movement.quantity} unidades',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (movement.note != null && movement.note!.isNotEmpty)
                                      Text(
                                        movement.note!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    Text(
                                      _formatDate(movement.date),
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
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
      padding: const EdgeInsets.only(bottom: 12.0),
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
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockInfo() {
    Color stockColor;
    IconData stockIcon;
    
    if (widget.product.stock <= 0) {
      stockColor = Colors.red;
      stockIcon = Icons.error_outline;
    } else if (widget.product.stock <= widget.product.minStock) {
      stockColor = Colors.orange;
      stockIcon = Icons.warning_outlined;
    } else {
      stockColor = Colors.green;
      stockIcon = Icons.check_circle_outline;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              'Stock Actual',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(
                  stockIcon,
                  color: stockColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.product.stock} unidades',
                  style: TextStyle(
                    fontSize: 16,
                    color: stockColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Ahora mismo';
    }
  }
} 