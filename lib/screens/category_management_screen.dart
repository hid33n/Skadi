import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../viewmodels/category_viewmodel.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/mobile_navigation.dart';
import 'home_screen.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isAddingCategory = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    if (_formKey.currentState!.validate()) {
      try {
        final category = Category(
          id: '',
          name: _nameController.text,
          description: _descriptionController.text,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await context.read<CategoryViewModel>().addCategory(category);
        _nameController.clear();
        _descriptionController.clear();
        setState(() {
          _isAddingCategory = false;
        });
        if (mounted) {
          CustomSnackBar.showSuccess(
            context: context,
            message: 'Categoría agregada correctamente',
          );
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.showError(
            context: context,
            message: 'Error al agregar categoría: $e',
          );
        }
      }
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Categoría'),
        content: Text('¿Estás seguro de eliminar "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<CategoryViewModel>().deleteCategory(category.id);
        if (mounted) {
          CustomSnackBar.showSuccess(
            context: context,
            message: 'Categoría eliminada correctamente',
          );
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.showError(
            context: context,
            message: 'Error al eliminar categoría: $e',
          );
        }
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Categorías',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(_isAddingCategory ? Icons.close : Icons.add),
                        onPressed: () {
                          setState(() {
                            _isAddingCategory = !_isAddingCategory;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_isAddingCategory) ...[
                    const SizedBox(height: 16),
                    _buildAddCategoryForm(),
                  ],
                  const SizedBox(height: 24),
                  Consumer<CategoryViewModel>(
                    builder: (context, categoryVM, child) {
                      if (categoryVM.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (categoryVM.error != null && categoryVM.error!.isNotEmpty) {
                        return Center(child: Text('Error: ${categoryVM.error}'));
                      }

                      if (categoryVM.categories.isEmpty) {
                        return const Center(
                          child: Text(
                            'No hay categorías disponibles',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categoryVM.categories.length,
                        itemBuilder: (context, index) {
                          final category = categoryVM.categories[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                category.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                category.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCategory(category),
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
        ),
      );
    } else if (isTablet) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Categorías'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _isAddingCategory = !_isAddingCategory;
                });
              },
            ),
          ],
        ),
        body: _buildTabletLayout(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Categorías'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _isAddingCategory = !_isAddingCategory;
                });
              },
            ),
          ],
        ),
        body: _buildDesktopLayout(),
      );
    }
  }

  Widget _buildAddCategoryForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addCategory,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Agregar Categoría'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isAddingCategory) ...[
            Expanded(
              flex: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildAddCategoryForm(),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: Consumer<CategoryViewModel>(
              builder: (context, categoryVM, child) {
                if (categoryVM.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (categoryVM.error != null && categoryVM.error!.isNotEmpty) {
                  return Center(child: Text('Error: ${categoryVM.error}'));
                }

                if (categoryVM.categories.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay categorías disponibles',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: categoryVM.categories.length,
                  itemBuilder: (context, index) {
                    final category = categoryVM.categories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(category.name),
                        subtitle: Text(category.description),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCategory(category),
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
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isAddingCategory) ...[
            Expanded(
              flex: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildAddCategoryForm(),
                ),
              ),
            ),
            const SizedBox(width: 24),
          ],
          Expanded(
            flex: 2,
            child: Consumer<CategoryViewModel>(
              builder: (context, categoryVM, child) {
                if (categoryVM.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (categoryVM.error != null && categoryVM.error!.isNotEmpty) {
                  return Center(child: Text('Error: ${categoryVM.error}'));
                }

                if (categoryVM.categories.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay categorías disponibles',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: categoryVM.categories.length,
                  itemBuilder: (context, index) {
                    final category = categoryVM.categories[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteCategory(category),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey),
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
    );
  }
} 