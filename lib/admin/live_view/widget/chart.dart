import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/widget/widgettext.dart';

class FlChartWidget extends StatelessWidget {
  final List<FlSpot> flSpots;
  final List<String> bottomTitles;
  const FlChartWidget(
      {super.key, required this.flSpots, required this.bottomTitles});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 300,
        padding: const EdgeInsets.only(top: 10, right: 10),
        child: LineChart(
          LineChartData(
            backgroundColor: primaryColor,
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (x, y) {
                    return WidgetText(text: bottomTitles[x.toInt()]);
                  },
                ),
              ),
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color(0xff37434d), width: 1),
            ),
            minX: 0,
            maxX: flSpots.length.toDouble() - 1,
            minY: 0,
            maxY: 100, // Adjust as per your data range
            lineBarsData: [
              LineChartBarData(
                barWidth: 4,
                spots: flSpots,
                isCurved: true,
                color: secondaryColor,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
