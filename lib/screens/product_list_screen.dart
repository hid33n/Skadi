import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../viewmodels/product_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/skeleton_loading.dart';
import '../utils/error_handler.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  AppError? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar datos cuando las dependencias cambien (por ejemplo, cuando se vuelve a mostrar la pantalla)
    final productViewModel = context.read<ProductViewModel>();
    if (productViewModel.products.isEmpty && !_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    } else {
      // Inicializar _filteredProducts con los productos actuales sin setState
      _filteredProducts = productViewModel.products;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await context.read<ProductViewModel>().loadProducts();
      await context.read<CategoryViewModel>().loadCategories();
      
      if (mounted) {
        setState(() {
          _filteredProducts = context.read<ProductViewModel>().products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = AppError.fromException(e);
          _isLoading = false;
        });
        CustomSnackBar.showError(
          context: context,
          message: AppError.fromException(e).message,
        );
      }
    }
  }

  void _filterProducts(String query) {
    final products = context.read<ProductViewModel>().products;
    
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = products;
      } else {
        _filteredProducts = products.where((product) {
          final nameMatch = product.name.toLowerCase().contains(query.toLowerCase());
          final descriptionMatch = (product.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
          return nameMatch || descriptionMatch;
        }).toList();
      }
    });
  }

  Future<void> _handleMenuAction(String action, Product product) async {
    switch (action) {
      case 'edit':
        Navigator.pushNamed(
          context, 
          '/edit-product',
          arguments: {'product': product},
        );
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar Producto'),
            content: Text('¿Estás seguro de que deseas eliminar "${product.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          try {
            final success = await context.read<ProductViewModel>().deleteProduct(product.id);
            if (success) {
              _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Producto eliminado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
        break;
      case 'view':
        Navigator.pushNamed(
          context, 
          '/product-detail',
          arguments: {'product': product},
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;

    if (isMobile) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text(
                      'Productos',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final result = await Navigator.pushNamed(context, '/add-product');
                        // Si se creó un producto exitosamente, recargar los datos
                        if (result == true) {
                          _loadData();
                        }
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: _filterProducts,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<ProductViewModel>(
                  builder: (context, productVM, child) {
                    if (_isLoading || productVM.isLoading) {
                      return const ProductListSkeleton(itemCount: 8);
                    }

                    if (_error != null || productVM.error != null) {
                      final error = _error ?? productVM.error;
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              error?.toString() ?? 'Error desconocido',
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (_filteredProducts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No hay productos registrados'
                                  : 'No se encontraron productos',
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            if (_searchController.text.isEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.pushNamed(context, '/add-product');
                                  // Si se creó un producto exitosamente, recargar los datos
                                  if (result == true) {
                                    _loadData();
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Agregar Producto'),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  product.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(
                                          Theme.of(context).primaryColor.red,
                                          Theme.of(context).primaryColor.green,
                                          Theme.of(context).primaryColor.blue,
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: product.stock <= product.minStock
                                            ? Color.fromRGBO(255, 165, 0, 0.1)
                                            : product.stock <= 0
                                                ? Color.fromRGBO(255, 0, 0, 0.1)
                                                : Color.fromRGBO(0, 255, 0, 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Stock: ${product.stock}',
                                        style: TextStyle(
                                          color: product.stock <= product.minStock
                                              ? Colors.orange
                                              : product.stock <= 0
                                                  ? Colors.red
                                                  : Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) => _handleMenuAction(value, product),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Row(
                                    children: [
                                      Icon(Icons.visibility, size: 20),
                                      SizedBox(width: 8),
                                      Text('Ver'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 20),
                                      SizedBox(width: 8),
                                      Text('Eliminar'),
                                    ],
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
              ),
            ],
          ),
        ),
      );
    } else if (isTablet) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Productos'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.pushNamed(context, '/add-product');
                // Si se creó un producto exitosamente, recargar los datos
                if (result == true) {
                  _loadData();
                }
              },
            ),
          ],
        ),
        body: _buildTabletLayout(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Productos'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.pushNamed(context, '/add-product');
                // Si se creó un producto exitosamente, recargar los datos
                if (result == true) {
                  _loadData();
                }
              },
            ),
          ],
        ),
        body: _buildDesktopLayout(),
      );
    }
  }

  Widget _buildTabletLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _filterProducts,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/add-product');
                  // Si se creó un producto exitosamente, recargar los datos
                  if (result == true) {
                    _loadData();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Producto'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: _filterProducts,
                ),
              ),
              const SizedBox(width: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/add-product');
                  // Si se creó un producto exitosamente, recargar los datos
                  if (result == true) {
                    _loadData();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Producto'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return Consumer<ProductViewModel>(
      builder: (context, productVM, child) {
        if (_isLoading || productVM.isLoading) {
          return const ProductGridSkeleton(itemCount: 8);
        }

        if (_error != null || productVM.error != null) {
          final error = _error ?? productVM.error;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  error?.toString() ?? 'Error desconocido',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (_filteredProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isEmpty
                      ? 'No hay productos registrados'
                      : 'No se encontraron productos',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                if (_searchController.text.isEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(context, '/add-product');
                      // Si se creó un producto exitosamente, recargar los datos
                      if (result == true) {
                        _loadData();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Producto'),
                  ),
                ],
              ],
            ),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _filteredProducts.length,
          itemBuilder: (context, index) {
            final product = _filteredProducts[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) => _handleMenuAction(value, product),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, size: 20),
                                  SizedBox(width: 8),
                                  Text('Ver'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20),
                                  SizedBox(width: 8),
                                  Text('Eliminar'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(
                              Theme.of(context).primaryColor.red,
                              Theme.of(context).primaryColor.green,
                              Theme.of(context).primaryColor.blue,
                              0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: product.stock <= product.minStock
                                ? Color.fromRGBO(255, 165, 0, 0.1)
                                : product.stock <= 0
                                    ? Color.fromRGBO(255, 0, 0, 0.1)
                                    : Color.fromRGBO(0, 255, 0, 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Stock: ${product.stock}',
                            style: TextStyle(
                              color: product.stock <= product.minStock
                                  ? Colors.orange
                                  : product.stock <= 0
                                      ? Colors.red
                                      : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
} 