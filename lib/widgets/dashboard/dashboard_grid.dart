import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/organization_viewmodel.dart';
import '../../screens/home_screen.dart';
import '../../screens/add_sale_screen.dart';
import '../../screens/add_product_screen.dart';
import '../../screens/product_list_screen.dart';
import '../../screens/sales_screen.dart';
import '../../models/product.dart';
import '../../models/sale.dart';
import '../../models/category.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/error_widgets.dart';
import '../../utils/error_handler.dart';
import 'dashboard_card.dart';
import 'sales_chart.dart';
import 'category_distribution.dart';
import 'stock_trends.dart';
import 'quick_actions.dart';
import 'recent_activity.dart';
import 'stock_status.dart';

class DashboardGrid extends StatelessWidget {
  const DashboardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSalesSummary(context),
            const SizedBox(height: 16),
            _buildQuickActions(context),
            const SizedBox(height: 16),
            _buildSalesChart(context),
            const SizedBox(height: 16),
            _buildLowStockProducts(context),
            const SizedBox(height: 16),
            _buildTopSellingProducts(context),
            const SizedBox(height: 16),
            _buildCategoryDistribution(context),
            const SizedBox(height: 16),
            _buildStockTrends(context),
            const SizedBox(height: 16),
            _buildRecentActivity(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesSummary(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, dashboardVM, _) {
        return StateHandlerWidget(
          isLoading: dashboardVM.isLoading,
          error: dashboardVM.error,
          onRetry: () => dashboardVM.loadDashboardData(),
          child: _buildSalesSummaryContent(context, dashboardVM),
        );
      },
    );
  }

  Widget _buildSalesSummaryContent(BuildContext context, DashboardViewModel dashboardVM) {
    final dashboardData = dashboardVM.dashboardData;
    if (dashboardData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No hay datos disponibles')),
        ),
      );
    }

    final todaySales = _calculateTodaySales(dashboardData.sales);
    final weekSales = _calculateWeekSales(dashboardData.sales);
    final totalSales = dashboardData.totalRevenue;

    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resumen de Ventas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Icon(Icons.bar_chart, color: Theme.of(context).primaryColor),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Layout móvil - columnas apiladas
                  return Column(
                    children: [
                      _buildSalesMetric(
                        context,
                        'Hoy',
                        todaySales,
                        Icons.today,
                        Colors.blue,
                        currencyFormat,
                      ),
                      const SizedBox(height: 16),
                      _buildSalesMetric(
                        context,
                        'Semana',
                        weekSales,
                        Icons.calendar_view_week,
                        Colors.orange,
                        currencyFormat,
                      ),
                      const SizedBox(height: 16),
                      _buildSalesMetric(
                        context,
                        'Total',
                        totalSales,
                        Icons.calendar_month,
                        Colors.green,
                        currencyFormat,
                      ),
                    ],
                  );
                } else {
                  // Layout desktop/tablet - filas
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSalesMetric(
                        context,
                        'Hoy',
                        todaySales,
                        Icons.today,
                        Colors.blue,
                        currencyFormat,
                      ),
                      _buildSalesMetric(
                        context,
                        'Semana',
                        weekSales,
                        Icons.calendar_view_week,
                        Colors.orange,
                        currencyFormat,
                      ),
                      _buildSalesMetric(
                        context,
                        'Total',
                        totalSales,
                        Icons.calendar_month,
                        Colors.green,
                        currencyFormat,
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTodaySales(List<Sale> sales) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return sales
        .where((sale) => sale.date.isAfter(startOfDay) && sale.date.isBefore(endOfDay))
        .fold(0.0, (sum, sale) => sum + sale.amount);
  }

  double _calculateWeekSales(List<Sale> sales) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return sales
        .where((sale) => sale.date.isAfter(startOfWeekDay))
        .fold(0.0, (sum, sale) => sum + sale.amount);
  }

  Widget _buildSalesMetric(
    BuildContext context,
    String label,
    double value,
    IconData icon,
    Color color,
    NumberFormat currencyFormat,
  ) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 8),
        Text(
          currencyFormat.format(value),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Acciones Rápidas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Icon(Icons.flash_on, color: Theme.of(context).primaryColor),
              ],
            ),
            const SizedBox(height: 16),
            QuickActions(
              actions: [
                QuickAction(
                  title: 'Nueva Venta',
                  subtitle: 'Registrar una nueva venta',
                  icon: Icons.shopping_cart,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddSaleScreen(),
                      ),
                    );
                  },
                ),
                QuickAction(
                  title: 'Nuevo Producto',
                  subtitle: 'Agregar un nuevo producto',
                  icon: Icons.add_box,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddProductScreen(),
                      ),
                    );
                  },
                ),
                QuickAction(
                  title: 'Ver Inventario',
                  subtitle: 'Revisar el estado del inventario',
                  icon: Icons.inventory,
                  color: Colors.deepOrange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductListScreen(),
                      ),
                    );
                  },
                ),
                QuickAction(
                  title: 'Historial Ventas',
                  subtitle: 'Ver todas las ventas',
                  icon: Icons.history,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SalesScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ventas Recientes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Icon(Icons.show_chart, color: Theme.of(context).primaryColor),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(
              height: 200,
              child: SalesChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockProducts(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, dashboardVM, _) {
        return StateHandlerWidget(
          isLoading: dashboardVM.isLoading,
          error: dashboardVM.error,
          isEmpty: dashboardVM.products.isEmpty,
          onRetry: () => dashboardVM.loadProducts(),
          emptyMessage: 'No hay productos registrados',
          emptyTitle: 'Sin Productos',
          emptyIcon: Icons.inventory_2_outlined,
          emptyActionText: 'Agregar Producto',
          onEmptyAction: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddProductScreen(),
              ),
            );
          },
          child: _buildLowStockProductsContent(context, dashboardVM),
        );
      },
    );
  }

  Widget _buildLowStockProductsContent(BuildContext context, DashboardViewModel dashboardVM) {
    final lowStockProducts = dashboardVM.getLowStockProductsLocal();

    if (lowStockProducts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No hay productos con stock bajo',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Productos con Stock Bajo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Icon(Icons.warning, color: Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: lowStockProducts.length,
                itemBuilder: (context, index) {
                  final product = lowStockProducts[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade100,
                      child: Text(
                        product.name[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      'Stock: ${product.stock}',
                      style: TextStyle(
                        color: product.stock <= 5 ? Colors.red : Colors.orange,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Text(
                      currencyFormat.format(product.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingProducts(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, dashboardVM, _) {
        return StateHandlerWidget(
          isLoading: dashboardVM.isLoading,
          error: dashboardVM.error,
          isEmpty: dashboardVM.sales.isEmpty || dashboardVM.products.isEmpty,
          onRetry: () => dashboardVM.loadDashboardData(),
          emptyMessage: 'No hay datos de ventas disponibles',
          emptyTitle: 'Sin Datos',
          emptyIcon: Icons.analytics_outlined,
          child: _buildTopSellingProductsContent(context, dashboardVM),
        );
      },
    );
  }

  Widget _buildTopSellingProductsContent(BuildContext context, DashboardViewModel dashboardVM) {
    final topProducts = _getTopSellingProducts(dashboardVM.sales, dashboardVM.products);

    if (topProducts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No hay productos vendidos',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Productos Más Vendidos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Icon(Icons.trending_up, color: Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: topProducts.length,
                itemBuilder: (context, index) {
                  final product = topProducts[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        product.name[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      'Stock: ${product.stock}',
                      style: TextStyle(
                        color: product.stock <= 10 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Text(
                      currencyFormat.format(product.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Product> _getTopSellingProducts(List<Sale> sales, List<Product> products) {
    final Map<String, int> productSalesCount = {};
    
    for (var sale in sales) {
      productSalesCount[sale.productId] = (productSalesCount[sale.productId] ?? 0) + 1;
    }

    final sortedProductIds = productSalesCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topProducts = <Product>[];
    for (var entry in sortedProductIds.take(5)) {
      final product = products.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => Product(
          id: entry.key,
          name: 'Producto no encontrado',
          description: '',
          price: 0.0,
          stock: 0,
          minStock: 0,
          maxStock: 100,
          categoryId: '',
          organizationId: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      topProducts.add(product);
    }

    return topProducts;
  }

  Widget _buildCategoryDistribution(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Distribución por Categoría',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Icon(Icons.pie_chart, color: Theme.of(context).primaryColor),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(
              height: 200,
              child: CategoryDistribution(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockTrends(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tendencias de Stock',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Icon(Icons.trending_up, color: Theme.of(context).primaryColor),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(
              height: 200,
              child: StockTrends(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Actividad Reciente',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.history, color: Colors.blue),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: RecentActivity(),
            ),
          ],
        ),
      ),
    );
  }
} 