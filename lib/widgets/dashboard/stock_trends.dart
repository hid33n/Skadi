import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/product_viewmodel.dart';

class StockTrends extends StatelessWidget {
  const StockTrends({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, viewModel, _) {
        final products = viewModel.products;
        final stockData = products.map((product) {
          return {
            'name': product.name,
            'current': product.stock,
            'min': product.minStock,
            'max': product.maxStock,
          };
        }).toList();

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: products.fold<double>(
              0,
              (max, product) => product.maxStock > max ? product.maxStock.toDouble() : max,
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (touchedSpot) => Theme.of(context).colorScheme.surface,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final product = stockData[groupIndex];
                  return BarTooltipItem(
                    '${product['name']}\n'
                    'Actual: ${product['current']}\n'
                    'Mín: ${product['min']}\n'
                    'Máx: ${product['max']}',
                    TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= stockData.length) return const Text('');
                    return RotatedBox(
                      quarterTurns: 1,
                      child: Text(
                        stockData[value.toInt()]['name'] as String,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: false),
            barGroups: stockData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data['current'] as double,
                    color: Theme.of(context).colorScheme.primary,
                    width: 20,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
                showingTooltipIndicators: [0],
              );
            }).toList(),
          ),
        );
      },
    );
  }
} 