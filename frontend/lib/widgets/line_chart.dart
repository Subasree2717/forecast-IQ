import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TempHumidityChart extends StatelessWidget {
  final List<Map<String, dynamic>> forecast;

  const TempHumidityChart({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> tempSpots = [];
    List<FlSpot> humiditySpots = [];

    for (int i = 0; i < forecast.length; i++) {
      tempSpots.add(FlSpot(i.toDouble(), forecast[i]["predicted_tempmax"].toDouble()));
      humiditySpots.add(FlSpot(i.toDouble(), forecast[i]["humidity"].toDouble()));
    }

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final day = forecast[value.toInt()]["date"].substring(5); // MM-DD
                  return Text(day, style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: tempSpots,
              isCurved: true,
              color: Colors.deepOrange,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: humiditySpots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
