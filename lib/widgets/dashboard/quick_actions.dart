import 'package:flutter/material.dart';
import '../../theme/animations.dart';
import '../../theme/responsive.dart';

class QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.color,
  });
}

class QuickActions extends StatelessWidget {
  final List<QuickAction> actions;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const QuickActions({
    Key? key,
    required this.actions,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppAnimations.combinedAnimation(
      child: Card(
        child: Padding(
          padding: Responsive.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Acciones Rápidas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (errorMessage != null)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                      if (onRetry != null)
                        TextButton(
                          onPressed: onRetry,
                          child: const Text('Reintentar'),
                        ),
                    ],
                  ),
                )
              else
                Responsive.responsiveBuilder(
                  context: context,
                  mobile: _buildMobileLayout(context),
                  tablet: _buildTabletLayout(context),
                  desktop: _buildDesktopLayout(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: actions.map((action) {
        return Column(
          children: [
            _buildActionItem(context, action),
            if (action != actions.last) const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: actions.map((action) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 64) / 2,
          child: _buildActionItem(context, action),
        );
      }).toList(),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: actions.map((action) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 96) / 3,
          child: _buildActionItem(context, action),
        );
      }).toList(),
    );
  }

  Widget _buildActionItem(BuildContext context, QuickAction action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (action.color ?? Theme.of(context).colorScheme.primary)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (action.color ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (action.color ?? Theme.of(context).colorScheme.primary)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  action.icon,
                  color: action.color ?? Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: action.color ??
                                Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 