import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../viewmodels/product_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/organization_viewmodel.dart';
import '../utils/error_handler.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/mobile_navigation.dart';
import 'home_screen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _maxStockController = TextEditingController();
  String? _selectedCategory;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final organizationViewModel = context.read<OrganizationViewModel>();
    final organizationId = organizationViewModel.currentOrganization?.id;
    
    if (organizationId != null) {
      await context.read<CategoryViewModel>().loadCategories(organizationId);
      setState(() {
        _categories = context.read<CategoryViewModel>().categories.map((e) => e.name).toList();
        if (_categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategory == null) {
      context.showError('Por favor seleccione una categoría');
      return;
    }

    final organizationViewModel = context.read<OrganizationViewModel>();
    final organizationId = organizationViewModel.currentOrganization?.id;
    
    if (organizationId == null) {
      context.showError('No se pudo obtener la información de la organización');
      return;
    }

    try {
      final now = DateTime.now();
      final category = context.read<CategoryViewModel>().categories.firstWhere(
            (c) => c.name == _selectedCategory,
          );

      final product = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        minStock: int.parse(_minStockController.text),
        maxStock: int.parse(_maxStockController.text),
        categoryId: category.id,
        organizationId: organizationId,
        createdAt: now,
        updatedAt: now,
      );

      final success = await context.read<ProductViewModel>().addProduct(product);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        context.showError(e);
      }
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
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Nuevo Producto',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildForm(),
                      ],
                    ),
                  ),
                ),
              ),
              MobileNavigation(
                selectedIndex: 1, // Índice de la pantalla de productos
                onDestinationSelected: (index) {
                  if (index != 1) { // Si no es la pantalla actual
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    } else if (isTablet) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Nuevo Producto'),
        ),
        body: _buildForm(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Nuevo Producto'),
        ),
        body: _buildForm(),
      );
    }
  }

  Widget _buildForm() {
    return Consumer<ProductViewModel>(
      builder: (context, productViewModel, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Producto *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La descripción es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio *',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El precio es requerido';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Ingresa un precio válido';
                    }
                    if (double.parse(value) <= 0) {
                      return 'El precio debe ser mayor a 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(
                          labelText: 'Stock Actual *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El stock es requerido';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Ingresa un número válido';
                          }
                          if (int.parse(value) < 0) {
                            return 'El stock no puede ser negativo';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _minStockController,
                        decoration: const InputDecoration(
                          labelText: 'Stock Mínimo *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El stock mínimo es requerido';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Ingresa un número válido';
                          }
                          if (int.parse(value) < 0) {
                            return 'El stock mínimo no puede ser negativo';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _maxStockController,
                        decoration: const InputDecoration(
                          labelText: 'Stock Máximo *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El stock máximo es requerido';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Ingresa un número válido';
                          }
                          if (int.parse(value) < 0) {
                            return 'El stock máximo no puede ser negativo';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría *',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona una categoría';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: productViewModel.isLoading ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: productViewModel.isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Guardar Producto',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 