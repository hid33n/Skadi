import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sale.dart';
import '../../viewmodels/sale_viewmodel.dart';
import 'dashboard_card.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SaleViewModel>(
      builder: (context, saleVM, child) {
        if (saleVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (saleVM.error != null && saleVM.error!.isNotEmpty) {
          return Center(child: Text('Error: ${saleVM.error}'));
        }

        final recentSales = saleVM.sales.take(5).toList();

        if (recentSales.isEmpty) {
          return const DashboardCard(
            title: 'Actividad Reciente',
            child: Center(
              child: Text(
                'No hay actividad reciente',
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        return DashboardCard(
          title: 'Actividad Reciente',
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentSales.length,
            itemBuilder: (context, index) {
              final sale = recentSales[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Icon(
                    Icons.shopping_cart,
                    color: Colors.green.shade900,
                  ),
                ),
                title: Text(
                  sale.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${sale.quantity} unidades - ${sale.formattedDate}',
                ),
                trailing: Text(
                  sale.formattedTotal,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
} 