import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/organization_viewmodel.dart';
import '../../models/category.dart';

class CategoryDistribution extends StatelessWidget {
  const CategoryDistribution({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProductViewModel, CategoryViewModel, OrganizationViewModel>(
      builder: (context, productVM, categoryVM, organizationVM, _) {
        if (productVM.isLoading || categoryVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productVM.error != null || categoryVM.error != null) {
          return Center(
            child: Text(
              'Error: ${productVM.error?.message ?? categoryVM.error?.message}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        // Agrupar productos por categoría
        final categoryCounts = <String, int>{};
        for (var product in productVM.products) {
          final category = categoryVM.categories
              .firstWhere(
                (c) => c.id == product.categoryId,
                orElse: () => Category(
                  id: 'default',
                  name: 'Sin categoría',
                  description: '',
                  organizationId: organizationVM.currentOrganization?.id ?? '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );
          categoryCounts[category.name] = (categoryCounts[category.name] ?? 0) + 1;
        }

        return ListView.builder(
          itemCount: categoryCounts.length,
          itemBuilder: (context, index) {
            final entry = categoryCounts.entries.elementAt(index);
            return ListTile(
              title: Text(entry.key),
              trailing: Text(
                '${entry.value} productos',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          },
        );
      },
    );
  }
} 