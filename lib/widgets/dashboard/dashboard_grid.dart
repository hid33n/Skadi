import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../widgets/responsive_layout.dart';
import 'dashboard_card.dart';
import 'sales_chart.dart';
import 'category_distribution.dart';
import 'stock_trends.dart';
import 'quick_actions.dart';
import 'recent_activity.dart';
import 'stock_status.dart';
import 'sales_summary.dart';

class DashboardGrid extends StatelessWidget {
  const DashboardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildDashboardItems(context, isMobile: true),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final items = _buildDashboardItems(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height - 200,
      child: GridView.builder(
        padding: const EdgeInsets.all(24.0),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 600,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 1.5,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => items[index],
      ),
    );
  }

  List<Widget> _buildDashboardItems(BuildContext context, {bool isMobile = false}) {
    final dashboardVM = Provider.of<DashboardViewModel>(context, listen: false);

    return [
      SalesSummary(dashboardViewModel: dashboardVM),
      QuickActions(),
      DashboardCard(
        title: 'Actividad Reciente',
        child: RecentActivity(),
      ),
      DashboardCard(
        title: 'Ventas de la Semana',
        child: SalesChart(),
      ),
      DashboardCard(
        title: 'Productos con Bajo Stock',
        child: StockStatus(),
      ),
      DashboardCard(
        title: 'Distribución por Categoría',
        child: CategoryDistribution(),
      ),
    ];
  }
} 