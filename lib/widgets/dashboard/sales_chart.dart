import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/sale_viewmodel.dart';

class SalesChart extends StatelessWidget {
  const SalesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SaleViewModel>(
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

        final sales = viewModel.sales;
        if (sales.isEmpty) {
          return const Center(
            child: Text('No hay datos de ventas disponibles'),
          );
        }

        // Agrupar ventas por día (últimos 7 días)
        final now = DateTime.now();
        final salesByDay = <String, double>{};
        
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.day}/${date.month}';
          salesByDay[dateKey] = 0.0;
        }

        // Sumar ventas por día
        for (final sale in sales) {
          final saleDate = sale.date;
          if (saleDate.isAfter(now.subtract(const Duration(days: 7)))) {
            final dateKey = '${saleDate.day}/${saleDate.month}';
            salesByDay[dateKey] = (salesByDay[dateKey] ?? 0.0) + sale.amount;
          }
        }

        final salesData = salesByDay.values.toList();
        final dates = salesByDay.keys.toList();
        
        return LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${value.toInt()}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= dates.length) return const Text('');
                    return Text(
                      dates[value.toInt()],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: salesData.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value);
                }).toList(),
                isCurved: true,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
            minY: 0,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => Theme.of(context).colorScheme.surface,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final index = spot.x.toInt();
                    if (index >= salesData.length) return null;
                    return LineTooltipItem(
                      '\$${salesData[index].toStringAsFixed(2)}',
                      TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        );
      },
    );
  }
} 