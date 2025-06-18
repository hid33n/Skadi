import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/product_viewmodel.dart';
import 'dashboard_card.dart';

class StockStatus extends StatelessWidget {
  const StockStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, productVM, child) {
        if (productVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productVM.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 32,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 8),
                Text(
                  productVM.error!.message,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        if (productVM.error != null && productVM.errorMessage != null) {
          return Center(child: Text('Error: ${productVM.errorMessage}'));
        }

        final totalProducts = productVM.products.length;
        final lowStockProducts = productVM.products.where((p) => p.stock <= 10).length;
        final outOfStockProducts = productVM.products.where((p) => p.stock == 0).length;
        final totalStock = productVM.products.fold<int>(0, (sum, p) => sum + p.stock);

        return DashboardCard(
          title: 'Estado del Stock',
          child: Column(
            children: [
              _buildStatusItem(
                context,
                'Total de Productos',
                totalProducts.toString(),
                Icons.inventory_2,
                Colors.blue,
              ),
              const Divider(),
              _buildStatusItem(
                context,
                'Stock Total',
                totalStock.toString(),
                Icons.warehouse,
                Colors.green,
              ),
              const Divider(),
              _buildStatusItem(
                context,
                'Productos con Stock Bajo',
                lowStockProducts.toString(),
                Icons.warning,
                Colors.orange,
              ),
              const Divider(),
              _buildStatusItem(
                context,
                'Productos Sin Stock',
                outOfStockProducts.toString(),
                Icons.error,
                Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
} 