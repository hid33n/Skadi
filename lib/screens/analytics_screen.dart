import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../viewmodels/product_viewmodel.dart';
import '../viewmodels/sale_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProductViewModel, SaleViewModel, CategoryViewModel>(
      builder: (context, productVM, saleVM, categoryVM, child) {
        if (productVM.isLoading || saleVM.isLoading || categoryVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Análisis',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildSummaryCards(context, productVM, saleVM, categoryVM),
              const SizedBox(height: 24),
              _buildSalesChart(context, saleVM),
              const SizedBox(height: 24),
              _buildTopProducts(context, saleVM),
              const SizedBox(height: 24),
              _buildCategoryDistribution(context, productVM, categoryVM),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    ProductViewModel productVM,
    SaleViewModel saleVM,
    CategoryViewModel categoryVM,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Productos',
            productVM.products.length.toString(),
            '${productVM.products.where((p) => p.stock <= p.minStock).length} bajo stock',
            Icons.inventory_2,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Total Ventas',
            saleVM.sales.length.toString(),
            '\$${saleVM.sales.fold<double>(0, (sum, sale) => sum + sale.amount).toStringAsFixed(2)}',
            Icons.shopping_cart,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Categorías',
            categoryVM.categories.length.toString(),
            '${productVM.products.length} productos',
            Icons.category,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart(BuildContext context, SaleViewModel saleVM) {
    final dailySales = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final daySales = saleVM.sales.where((s) {
        final saleDate = s.date;
        return saleDate.year == date.year &&
            saleDate.month == date.month &&
            saleDate.day == date.day;
      }).toList();

      dailySales.add({
        'date': date,
        'total': daySales.fold<double>(
          0,
          (sum, sale) => sum + sale.amount,
        ),
      });
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ventas de la Última Semana',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                          return Text(
                            DateFormat('dd/MM').format(date),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailySales.map((entry) {
                        return FlSpot(
                          entry['date'].millisecondsSinceEpoch.toDouble(),
                          entry['total'],
                        );
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
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

  Widget _buildTopProducts(BuildContext context, SaleViewModel saleVM) {
    final productSales = <String, Map<String, dynamic>>{};
    
    for (var sale in saleVM.sales) {
      if (!productSales.containsKey(sale.productId)) {
        productSales[sale.productId] = {
          'name': sale.productName,
          'quantity': 0,
          'total': 0.0,
        };
      }
      
      productSales[sale.productId]!['quantity'] += sale.quantity;
      productSales[sale.productId]!['total'] += sale.amount;
    }

    final sortedProducts = productSales.entries.toList()
      ..sort((a, b) => b.value['total'].compareTo(a.value['total']));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Productos Más Vendidos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedProducts.take(5).map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(entry.value['name']),
                    ),
                    Text(
                      '${entry.value['quantity']} unidades',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '\$${entry.value['total'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistribution(
    BuildContext context,
    ProductViewModel productVM,
    CategoryViewModel categoryVM,
  ) {
    final categoryCounts = <String, int>{};
    for (var product in productVM.products) {
      final category = categoryVM.categories
          .firstWhere((c) => c.id == product.categoryId);
      categoryCounts[category.name] = (categoryCounts[category.name] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribución por Categoría',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...categoryCounts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(entry.key),
                    ),
                    Text(
                      '${entry.value} productos',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
} 