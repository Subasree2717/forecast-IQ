import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TempLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> forecast;

  const TempLineChart({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final spots = forecast.asMap().entries.map(
      (entry) {
        int index = entry.key;
        double temp = (entry.value["predicted_tempmax"] ?? 0).toDouble();
        return FlSpot(index.toDouble(), temp);
      },
    ).toList();

    return SizedBox(
      height: 220,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  spots: spots,
                  barWidth: 3,
                  color: Colors.orange,
                  belowBarData: BarAreaData(show: true, color: Colors.white.withAlpha((255 * 0.85).toInt())),
                  dotData: FlDotData(show: true),
                )
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < forecast.length) {
                        String date = forecast[index]["date"];
                        return Text(date.substring(5), style: const TextStyle(fontSize: 10));
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
            ),
          ),
        ),
      ),
    );
  }
}
