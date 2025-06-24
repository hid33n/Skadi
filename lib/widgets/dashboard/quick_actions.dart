import 'package:flutter/material.dart';
import 'dashboard_card.dart';
import 'barcode_quick_action.dart';
import '../../theme/responsive.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Acciones Rápidas',
      icon: Icons.flash_on,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return Column(
              children: [
                if (Responsive.isMobile(context))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: BarcodeQuickAction(),
                  ),
                _buildActionRow(context, [
                  _buildActionButton(
                    context,
                    'Nueva Venta',
                    Icons.add_shopping_cart,
                    Colors.green,
                    () => Navigator.pushNamed(context, '/add-sale'),
                  ),
                  _buildActionButton(
                    context,
                    'Nuevo Producto',
                    Icons.add_box,
                    Colors.blue,
                    () => Navigator.pushNamed(context, '/add-product'),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildActionRow(context, [
                  _buildActionButton(
                    context,
                    'Ver Productos',
                    Icons.inventory,
                    Colors.orange,
                    () => Navigator.pushNamed(context, '/products'),
                  ),
                  _buildActionButton(
                    context,
                    'Ver Ventas',
                    Icons.receipt_long,
                    Colors.purple,
                    () => Navigator.pushNamed(context, '/sales'),
                  ),
                ]),
              ],
            );
          }
          
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                context,
                'Nueva Venta',
                Icons.add_shopping_cart,
                Colors.green,
                () => Navigator.pushNamed(context, '/add-sale'),
              ),
              _buildActionButton(
                context,
                'Nuevo Producto',
                Icons.add_box,
                Colors.blue,
                () => Navigator.pushNamed(context, '/add-product'),
              ),
              _buildActionButton(
                context,
                'Ver Productos',
                Icons.inventory,
                Colors.orange,
                () => Navigator.pushNamed(context, '/products'),
              ),
              _buildActionButton(
                context,
                'Ver Ventas',
                Icons.receipt_long,
                Colors.purple,
                () => Navigator.pushNamed(context, '/sales'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, List<Widget> actions) {
    return Row(
      children: actions.map((action) {
        final isLast = action == actions.last;
        return Expanded(
          child: Row(
            children: [
              Expanded(child: action),
              if (!isLast) const SizedBox(width: 16),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 