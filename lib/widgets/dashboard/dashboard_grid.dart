import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../screens/home_screen.dart';
import '../../screens/add_sale_screen.dart';
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;

    if (isMobile) {
      return _buildMobileLayout(context);
    } else if (isTablet) {
      return _buildTabletLayout(context);
    } else {
      return _buildDesktopLayout(context);
    }
  }

  Widget _buildMobileLayout(BuildContext context) {
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
            _buildCategoryDistribution(context),
            const SizedBox(height: 16),
            _buildStockTrends(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildSalesSummary(context),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildQuickActions(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildSalesChart(context),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCategoryDistribution(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStockTrends(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildSalesSummary(context),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildQuickActions(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildSalesChart(context),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildCategoryDistribution(context),
                      const SizedBox(height: 16),
                      _buildStockTrends(context),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesSummary(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSalesMetric(
                      context,
                      'Hoy',
                      viewModel.todaySales,
                      Icons.today,
                      Colors.blue,
                    ),
                    _buildSalesMetric(
                      context,
                      'Semana',
                      viewModel.weekSales,
                      Icons.calendar_view_week,
                      Colors.orange,
                    ),
                    _buildSalesMetric(
                      context,
                      'Mes',
                      viewModel.monthSales,
                      Icons.calendar_month,
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSalesMetric(
    BuildContext context,
    String label,
    double value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 8),
        Text(
          '\$${value.toStringAsFixed(2)}',
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
                    Navigator.pushReplacement(
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
                    Navigator.pushNamed(context, '/add-product');
                  },
                ),
                QuickAction(
                  title: 'Nueva Categoría',
                  subtitle: 'Crear una nueva categoría',
                  icon: Icons.category,
                  color: Colors.deepOrange,
                  onTap: () {
                    final provider = HomeScreenProvider.of(context);
                    if (provider != null) {
                      provider.navigateToIndex(2); // Índice de la pantalla de categorías
                    }
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
} 