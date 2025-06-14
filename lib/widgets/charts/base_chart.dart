import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/animations.dart';
import '../../theme/responsive.dart';

class BaseChart extends StatelessWidget {
  final String title;
  final Widget chart;
  final List<Widget>? actions;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const BaseChart({
    Key? key,
    required this.title,
    required this.chart,
    this.actions,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (actions != null) ...actions!,
                ],
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
                SizedBox(
                  height: Responsive.getResponsiveHeight(context, 30),
                  child: chart,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final List<FlSpot> spots;
  final String? title;
  final Color? lineColor;
  final Color? belowLineColor;
  final bool showGrid;
  final bool showTitles;
  final bool showBorder;
  final double minY;
  final double maxY;

  const LineChartWidget({
    Key? key,
    required this.spots,
    this.title,
    this.lineColor,
    this.belowLineColor,
    this.showGrid = true,
    this.showTitles = true,
    this.showBorder = true,
    this.minY = 0,
    this.maxY = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: showGrid,
          drawVerticalLine: showGrid,
          horizontalInterval: (maxY - minY) / 5,
          verticalInterval: spots.length > 0 ? spots.length / 5 : 1,
        ),
        titlesData: FlTitlesData(
          show: showTitles,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: showTitles,
              reservedSize: 30,
              interval: spots.length > 0 ? spots.length / 5 : 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: showTitles,
              interval: (maxY - minY) / 5,
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: showBorder,
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        minX: 0,
        maxX: spots.length > 0 ? spots.length - 1 : 0,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor ?? Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: (belowLineColor ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final String? title;
  final Color? barColor;
  final bool showGrid;
  final bool showTitles;
  final bool showBorder;
  final double maxY;

  const BarChartWidget({
    Key? key,
    required this.barGroups,
    this.title,
    this.barColor,
    this.showGrid = true,
    this.showTitles = true,
    this.showBorder = true,
    this.maxY = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Theme.of(context).colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()}',
                TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: showTitles,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: showBorder,
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        gridData: FlGridData(
          show: showGrid,
          drawVerticalLine: showGrid,
          horizontalInterval: maxY / 5,
          verticalInterval: barGroups.length > 0 ? barGroups.length / 5 : 1,
        ),
        barGroups: barGroups,
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final String? title;
  final bool showTitles;
  final bool showBorder;
  final double centerSpaceRadius;

  const PieChartWidget({
    Key? key,
    required this.sections,
    this.title,
    this.showTitles = true,
    this.showBorder = true,
    this.centerSpaceRadius = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: centerSpaceRadius,
        sectionsSpace: 2,
        startDegreeOffset: -90,
        borderData: FlBorderData(
          show: showBorder,
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
    );
  }
} 