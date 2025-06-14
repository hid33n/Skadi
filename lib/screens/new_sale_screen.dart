import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sale.dart';
import '../viewmodels/sale_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import '../widgets/custom_snackbar.dart';
import '../services/auth_service.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  String _searchQuery = '';
  final _formKey = GlobalKey<FormState>();
  String? _selectedProductId;
  String? _selectedProductName;
  double? _selectedProductPrice;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final productViewModel = context.read<ProductViewModel>();
    await productViewModel.loadProducts();
  }

  void _selectProduct(String productId, String productName, double price) {
    setState(() {
      _selectedProductId = productId;
      _selectedProductName = productName;
      _selectedProductPrice = price;
      _quantity = 1;
    });
  }

  void _updateQuantity(int quantity) {
    if (quantity > 0) {
      setState(() {
        _quantity = quantity;
      });
    }
  }

  Future<void> _saveSale() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null) {
      CustomSnackBar.showError(
        context: context,
        message: 'Seleccione un producto',
      );
      return;
    }

    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId == null) {
        CustomSnackBar.showError(
          context: context,
          message: 'No hay usuario autenticado',
        );
        return;
      }

      final saleViewModel = context.read<SaleViewModel>();
      final sale = Sale(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        productId: _selectedProductId!,
        productName: _selectedProductName!,
        amount: _selectedProductPrice! * _quantity,
        quantity: _quantity,
        date: DateTime.now(),
        notes: null,
      );

      await saleViewModel.addSale(sale);
      if (mounted) {
        CustomSnackBar.showSuccess(
          context: context,
          message: 'Venta registrada correctamente',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(
          context: context,
          message: 'Error al guardar la venta: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Venta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSale,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
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
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar productos...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Consumer<ProductViewModel>(
                builder: (context, productVM, child) {
                  if (productVM.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (productVM.error != null && productVM.error!.isNotEmpty) {
                    return Center(child: Text('Error: ${productVM.error}'));
                  }

                  final filteredProducts = productVM.products.where((product) {
                    return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();

                  return Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(product.name),
                                subtitle: Text(
                                  'Stock: ${product.stock} | Precio: \$${product.price.toStringAsFixed(2)}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add_shopping_cart),
                                  onPressed: product.stock > 0
                                      ? () {
                                          _selectProduct(product.id, product.name, product.price);
                                        }
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const VerticalDivider(),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Expanded(
                              child: _selectedProductId == null
                                  ? const Center(
                                      child: Text('Seleccione un producto'),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Producto: $_selectedProductName',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Precio: \$${_selectedProductPrice!.toStringAsFixed(2)}',
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove),
                                                onPressed: () => _updateQuantity(_quantity - 1),
                                              ),
                                              Text(
                                                '$_quantity',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add),
                                                onPressed: () => _updateQuantity(_quantity + 1),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Total: \$${(_selectedProductPrice! * _quantity).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 