import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/responsive.dart';

class SalesSummary extends StatelessWidget {
  final double totalSales;
  final double averageSale;
  final int totalTransactions;
  final double growthRate;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const SalesSummary({
    super.key,
    required this.totalSales,
    required this.averageSale,
    required this.totalTransactions,
    required this.growthRate,
    required this.isLoading,
    this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen de Ventas',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Responsive.responsiveBuilder(
          context: context,
          mobile: _buildMobileLayout(context, currencyFormat),
          tablet: _buildTabletLayout(context, currencyFormat),
          desktop: _buildDesktopLayout(context, currencyFormat),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, NumberFormat currencyFormat) {
    return Column(
      children: [
        _buildSummaryCard(
          context,
          'Ventas Totales',
          currencyFormat.format(totalSales),
          Icons.attach_money,
          Colors.green,
        ),
        const SizedBox(height: 16),
        _buildSummaryCard(
          context,
          'Venta Promedio',
          currencyFormat.format(averageSale),
          Icons.analytics,
          Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildSummaryCard(
          context,
          'Transacciones',
          totalTransactions.toString(),
          Icons.receipt_long,
          Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildSummaryCard(
          context,
          'Crecimiento',
          '${growthRate.toStringAsFixed(1)}%',
          growthRate >= 0 ? Icons.trending_up : Icons.trending_down,
          growthRate >= 0 ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, NumberFormat currencyFormat) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Ventas Totales',
                currencyFormat.format(totalSales),
                Icons.attach_money,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Venta Promedio',
                currencyFormat.format(averageSale),
                Icons.analytics,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Transacciones',
                totalTransactions.toString(),
                Icons.receipt_long,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Crecimiento',
                '${growthRate.toStringAsFixed(1)}%',
                growthRate >= 0 ? Icons.trending_up : Icons.trending_down,
                growthRate >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, NumberFormat currencyFormat) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            'Ventas Totales',
            currencyFormat.format(totalSales),
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Venta Promedio',
            currencyFormat.format(averageSale),
            Icons.analytics,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Transacciones',
            totalTransactions.toString(),
            Icons.receipt_long,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Crecimiento',
            '${growthRate.toStringAsFixed(1)}%',
            growthRate >= 0 ? Icons.trending_up : Icons.trending_down,
            growthRate >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
} 