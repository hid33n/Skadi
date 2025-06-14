import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import 'dashboard_card.dart';
import 'sales_chart.dart';
import 'category_distribution.dart';
import 'stock_trends.dart';
import 'quick_actions.dart';

// Utilidad para detectar el tipo de pantalla
enum ScreenType { mobile, tablet, web }

ScreenType getScreenType(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width <= 400) {
    return ScreenType.mobile;
  } else if (width <= 800) {
    return ScreenType.tablet;
  } else {
    return ScreenType.web;
  }
}

class DashboardGrid extends StatelessWidget {
  const DashboardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final screenType = getScreenType(context);
    int crossAxisCount;
    double aspectRatio;
    switch (screenType) {
      case ScreenType.mobile:
        crossAxisCount = 1;
        aspectRatio = 1.8;
        break;
      case ScreenType.tablet:
        crossAxisCount = 2;
        aspectRatio = 1.5;
        break;
      case ScreenType.web:
        crossAxisCount = 4;
        aspectRatio = 1.5;
        break;
    }

    final items = [
      // Resumen de Ventas
      DashboardCard(
        title: 'Ventas del Período',
        icon: Icons.bar_chart,
        iconColor: Colors.blueAccent,
        child: Consumer<DashboardViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.error != null) {
              return Center(
                child: Text(
                  'Error: ${viewModel.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }
            // Responsive: columna en móvil, fila en tablet/web
            final isMobile = screenType == ScreenType.mobile;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.attach_money, color: Colors.green, size: 32),
                    const SizedBox(width: 8),
                    Text(
                      '\$${viewModel.monthSales.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Ventas del mes',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.blueGrey[700],
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                isMobile
                    ? Column(
                        children: [
                          _SalesTotalTile(
                            icon: Icons.today,
                            color: Colors.blue,
                            label: 'Hoy',
                            value: viewModel.todaySales,
                          ),
                          const SizedBox(height: 8),
                          _SalesTotalTile(
                            icon: Icons.calendar_view_week,
                            color: Colors.orange,
                            label: 'Semana',
                            value: viewModel.weekSales,
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: _SalesTotalTile(
                              icon: Icons.today,
                              color: Colors.blue,
                              label: 'Hoy',
                              value: viewModel.todaySales,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SalesTotalTile(
                              icon: Icons.calendar_view_week,
                              color: Colors.orange,
                              label: 'Semana',
                              value: viewModel.weekSales,
                            ),
                          ),
                        ],
                      ),
              ],
            );
          },
        ),
      ),
      // Gráfico de Ventas
      DashboardCard(
        title: 'Tendencia de Ventas',
        icon: Icons.show_chart,
        iconColor: Colors.purple,
        child: const SalesChart(),
      ),
      // Distribución por Categoría
      DashboardCard(
        title: 'Productos por Categoría',
        icon: Icons.pie_chart,
        iconColor: Colors.deepOrange,
        child: const CategoryDistribution(),
      ),
      // Tendencias de Stock
      DashboardCard(
        title: 'Tendencias de Stock',
        icon: Icons.trending_up,
        iconColor: Colors.teal,
        child: const StockTrends(),
      ),
      // Productos con Stock Bajo
      DashboardCard(
        title: 'Stock Bajo',
        icon: Icons.warning,
        iconColor: Colors.redAccent,
        child: Consumer<DashboardViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.error != null) {
              return Center(
                child: Text(
                  'Error: ${viewModel.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }
            final lowStockProducts = viewModel.lowStockProducts;
            if (lowStockProducts.isEmpty) {
              return const Center(
                child: Text('No hay productos con stock bajo'),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lowStockProducts.length,
              itemBuilder: (context, index) {
                final product = lowStockProducts[index];
                return ListTile(
                  leading: Icon(Icons.inventory_2, color: Colors.redAccent),
                  title: Text(product.name, overflow: TextOverflow.ellipsis),
                  subtitle: Text('Stock: ${product.stock}'),
                  trailing: Text(
                    'Mín: ${product.minStock}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      // Acciones Rápidas
      DashboardCard(
        title: 'Acciones Rápidas',
        icon: Icons.flash_on,
        iconColor: Colors.amber,
        child: QuickActions(
          actions: [
            QuickAction(
              title: 'Nueva Venta',
              subtitle: 'Registrar una nueva venta',
              icon: Icons.shopping_cart,
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, '/new-sale');
              },
            ),
            QuickAction(
              title: 'Nuevo Producto',
              subtitle: 'Agregar un nuevo producto',
              icon: Icons.add_box,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/new-product');
              },
            ),
            QuickAction(
              title: 'Nueva Categoría',
              subtitle: 'Crear una nueva categoría',
              icon: Icons.category,
              color: Colors.deepOrange,
              onTap: () {
                Navigator.pushNamed(context, '/new-category');
              },
            ),
          ],
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: aspectRatio,
      ),
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }
}

class _SalesTotalTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final double value;

  const _SalesTotalTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              '\$${value.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
} 