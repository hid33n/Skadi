import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/sale.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import 'dashboard_card.dart';

class SalesSummary extends StatelessWidget {
  final DashboardViewModel dashboardViewModel;

  const SalesSummary({super.key, required this.dashboardViewModel});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, dashboardVM, _) {
        if (dashboardVM.isLoading) {
          return const _SalesSummarySkeleton();
        }

        if (dashboardVM.error != null) {
          return DashboardCard(
            title: 'Resumen de Ventas',
            child: Center(child: Text(dashboardVM.error!)),
          );
        }

        final sales = dashboardVM.dashboardData?.sales ?? [];
        final totalRevenue = dashboardVM.dashboardData?.totalRevenue ?? 0.0;
        
        return _SalesSummaryContent(
          sales: sales,
          totalRevenue: totalRevenue,
        );
      },
    );
  }
}

class _SalesSummaryContent extends StatelessWidget {
  final List<Sale> sales;
  final double totalRevenue;

  const _SalesSummaryContent({
    required this.sales,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final todaySales = _calculateTodaySales(sales);
    final weekSales = _calculateWeekSales(sales);
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return DashboardCard(
      title: 'Resumen de Ventas',
      icon: Icons.bar_chart,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return Column(
              children: [
                _buildSalesMetric(context, 'Hoy', todaySales, currencyFormat, Colors.blue),
                const SizedBox(height: 16),
                _buildSalesMetric(context, 'Semana', weekSales, currencyFormat, Colors.orange),
                const SizedBox(height: 16),
                _buildSalesMetric(context, 'Total', totalRevenue, currencyFormat, Colors.green),
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSalesMetric(context, 'Hoy', todaySales, currencyFormat, Colors.blue),
              _buildSalesMetric(context, 'Semana', weekSales, currencyFormat, Colors.orange),
              _buildSalesMetric(context, 'Total', totalRevenue, currencyFormat, Colors.green),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSalesMetric(BuildContext context, String title, double value, NumberFormat format, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Text(
          format.format(value),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  double _calculateTodaySales(List<Sale> sales) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return sales
        .where((s) => s.date.isAfter(today))
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double _calculateWeekSales(List<Sale> sales) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return sales
        .where((s) => s.date.isAfter(startOfWeek))
        .fold(0.0, (sum, item) => sum + item.amount);
  }
}

class _SalesSummarySkeleton extends StatelessWidget {
  const _SalesSummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Resumen de Ventas',
      child: LayoutBuilder(
        builder: (context, constraints) {
           if (constraints.maxWidth < 600) {
            return Column(
              children: List.generate(3, (index) => const _MetricSkeleton(isMobile: true)),
            );
           }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(3, (index) => const _MetricSkeleton()),
          );
        },
      ),
    );
  }
}

class _MetricSkeleton extends StatelessWidget {
  final bool isMobile;
  const _MetricSkeleton({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final skeleton = Column(
      children: [
        Container(width: 80, height: 18, color: Colors.grey[800]),
        const SizedBox(height: 8),
        Container(width: 120, height: 24, color: Colors.grey[700]),
      ],
    );

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: skeleton,
      );
    }
    return skeleton;
  }
} 