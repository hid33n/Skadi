import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../viewmodels/product_viewmodel.dart';
import '../viewmodels/sale_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../models/category.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<ProductViewModel>().loadProducts();
    await context.read<SaleViewModel>().loadSales();
    await context.read<CategoryViewModel>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProductViewModel, SaleViewModel, CategoryViewModel>(
      builder: (context, productVM, saleVM, categoryVM, child) {
        if (productVM.isLoading || saleVM.isLoading || categoryVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Verificar si hay errores
        final errorMessages = <String>[];
        if (productVM.error != null) {
          errorMessages.add(productVM.error!);
        }
        if (saleVM.error != null) {
          errorMessages.add(saleVM.error!);
        }
        if (categoryVM.error != null) {
          errorMessages.add(categoryVM.error!);
        }

        if (errorMessages.isNotEmpty) {
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
                  errorMessages.first,
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

        // Verificar si hay datos
        if (productVM.products.isEmpty && saleVM.sales.isEmpty && categoryVM.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay datos para mostrar',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Cargar Datos'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Análisis',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadData,
                    tooltip: 'Actualizar datos',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSummaryCards(context, productVM, saleVM, categoryVM),
              const SizedBox(height: 24),
              if (saleVM.sales.isNotEmpty) ...[
                _buildSalesChart(context, saleVM),
                const SizedBox(height: 24),
                _buildTopProducts(context, saleVM),
                const SizedBox(height: 24),
              ],
              if (productVM.products.isNotEmpty && categoryVM.categories.isNotEmpty) ...[
                _buildCategoryDistribution(context, productVM, categoryVM),
                const SizedBox(height: 24),
              ],
              _buildStockAnalysis(context, productVM),
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
            Colors.blue,
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
            Colors.green,
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
            Colors.orange,
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
    Color color,
  ) {
    return Card(
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
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
                  Icons.trending_up,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Ventas de la Última Semana',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                  Icons.star,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Productos Más Vendidos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...sortedProducts.take(5).map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.value['name'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${entry.value['quantity']} uds',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '\$${entry.value['total'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
          .firstWhere((c) => c.id == product.categoryId, orElse: () => Category(
                id: 'unknown',
                name: 'Sin categoría',
                description: 'Producto sin categoría asignada',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ));
      categoryCounts[category.name] = (categoryCounts[category.name] ?? 0) + 1;
    }

    return Card(
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
                  Icons.pie_chart,
                  color: Colors.purple,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Distribución por Categoría',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...categoryCounts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${entry.value} productos',
                        style: TextStyle(
                          color: Colors.purple[700],
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildStockAnalysis(BuildContext context, ProductViewModel productVM) {
    final lowStockProducts = productVM.products.where((p) => p.stock <= p.minStock).toList();
    final outOfStockProducts = productVM.products.where((p) => p.stock <= 0).toList();

    return Card(
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
                  Icons.warning,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Análisis de Stock',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStockStat(
                    'Sin Stock',
                    outOfStockProducts.length.toString(),
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStockStat(
                    'Stock Bajo',
                    lowStockProducts.length.toString(),
                    Colors.orange,
                  ),
                ),
              ],
            ),
            if (lowStockProducts.isNotEmpty || outOfStockProducts.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Productos que requieren atención:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...lowStockProducts.take(3).map((product) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${product.name} (Stock: ${product.stock})',
                  style: const TextStyle(fontSize: 12),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStockStat(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 