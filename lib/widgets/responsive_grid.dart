import 'package:flutter/material.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry padding;
  final int? maxCrossAxisExtent;
  final double childAspectRatio;
  final double? maxWidth;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.maxCrossAxisExtent,
    this.childAspectRatio = 1.0,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isWideScreen = width > 1200;
        final isMediumScreen = width > 800;
        final isSmallScreen = width > 600;

        int crossAxisCount;
        if (isWideScreen) {
          crossAxisCount = 4;
        } else if (isMediumScreen) {
          crossAxisCount = 3;
        } else if (isSmallScreen) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return Container(
          constraints: maxWidth != null
              ? BoxConstraints(maxWidth: maxWidth!)
              : null,
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: runSpacing,
            padding: padding,
            childAspectRatio: childAspectRatio,
            children: children,
          ),
        );
      },
    );
  }
} 