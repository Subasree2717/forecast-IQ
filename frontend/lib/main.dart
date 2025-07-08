import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const WeatherApp());
}

// Simple TempHumidityChart widget implementation
class TempHumidityChart extends StatelessWidget {
  final List<Map<String, dynamic>> forecast;

  const TempHumidityChart({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final tempSpots = forecast.asMap().entries.map((entry) {
      int index = entry.key;
      double temp = (entry.value["predicted_tempmax"] ?? 0).toDouble();
      return FlSpot(index.toDouble(), temp);
    }).toList();

    final humiditySpots = forecast.asMap().entries.map((entry) {
      int index = entry.key;
      double humidity = (entry.value["predicted_humidity"] ?? 0).toDouble();
      return FlSpot(index.toDouble(), humidity);
    }).toList();

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
                  spots: tempSpots,
                  barWidth: 3,
                  color: Colors.orange,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  isCurved: true,
                  spots: humiditySpots,
                  barWidth: 3,
                  color: Colors.blue,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
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

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Forecast',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});
  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  Map<String, dynamic>? todayWeather;
  List<Map<String, dynamic>> weekForecast = [];
  bool loading = false;
  String error = "";
  String? city = "Fetching...";

  final String baseUrl = "http://localhost:5000"; // Replace with your LAN IP

  Future<void> fetchWeather() async {
    setState(() {
      loading = true;
      error = "";
    });

    try {
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double lat = pos.latitude;
      double lon = pos.longitude;

      final todayRes = await http.get(Uri.parse("$baseUrl/today?lat=$lat&lon=$lon"));
      final weekRes = await http.get(Uri.parse("$baseUrl/predict-week"));

      if (todayRes.statusCode == 200 && weekRes.statusCode == 200) {
        final todayJson = json.decode(todayRes.body);
        final weekJson = json.decode(weekRes.body) as List;

        setState(() {
          todayWeather = todayJson;
          city = todayJson["city"];
          weekForecast = weekJson.cast<Map<String, dynamic>>();
          loading = false;
        });
      } else {
        setState(() {
          error = "Failed to fetch weather data.";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error: $e";
        loading = false;
      });
    }
  }

  IconData getWeatherIcon(String? weather) {
    if (weather == null) return Icons.help_outline;
    switch (weather.toLowerCase()) {
      case "clear":
      case "sunny":
        return Icons.wb_sunny_rounded;
      case "clouds":
      case "cloudy":
        return Icons.cloud;
      case "rain":
      case "rainy":
        return Icons.umbrella;
      case "snow":
        return Icons.ac_unit;
      case "partly cloudy":
        return Icons.wb_cloudy;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  Widget buildLiveWeatherCard() {
    if (todayWeather == null) return const SizedBox();
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      color: Colors.white.withAlpha((255 * 0.85).toInt()),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            Text(
              "$city - Live Weather",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 12),
            Icon(
              getWeatherIcon(todayWeather!["weather"]),
              size: 60,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 12),
            Text(
              "${todayWeather!["temp"]}°C",
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.deepOrange),
            ),
            const SizedBox(height: 6),
            Text(
              "${todayWeather!["weather"]}",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text("Humidity: ${todayWeather!["humidity"]}%   Wind: ${todayWeather!["wind_speed"]} m/s")
          ],
        ),
      ),
    );
  }

  Widget buildWeekForecast() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center, // 🔥 Center column
    children: [
      const Text(
        "7-Day Forecast",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      const SizedBox(height: 12),
      Center( // 🔥 Wrap ListView in Center
        child: SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weekForecast.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final day = weekForecast[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  color: Colors.white.withAlpha((255 * 0.9).toInt()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatDate(day["date"]),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        const SizedBox(height: 6),
                        Icon(
                          getWeatherIcon(day["predicted_weather"]),
                          size: 28,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${day["predicted_tempmax"]}°C",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day["predicted_weather"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}

// Helper method to format date strings like "2024-06-08" to "Jun 08"
String _formatDate(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}";
  } catch (e) {
    return dateStr;
  }
}


  Widget buildTempLineChart() {
    final spots = weekForecast.asMap().entries.map((entry) {
      int index = entry.key;
      double temp = (entry.value["predicted_tempmax"] ?? 0).toDouble();
      return FlSpot(index.toDouble(), temp);
    }).toList();

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
                  belowBarData: BarAreaData(show: true, color: Colors.white.withAlpha((255 * 0.9).toInt())),
                  dotData: FlDotData(show: true),
                )
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < weekForecast.length) {
                        String date = weekForecast[index]["date"];
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  toolbarHeight: 70,
  title: AnimatedAlign(
    alignment: Alignment.topLeft, // ⬅️ Align to left top
    duration: Duration(milliseconds: 800),
    curve: Curves.easeOut,
    child: Row(
      children: const [
        Icon(Icons.cloud, color: Colors.white),
        SizedBox(width: 8),
        Text(
          "Weather Forecast",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    ),
  ),
),

        body: loading
            ? const Center(child: CircularProgressIndicator())
            : error.isNotEmpty
                ? Center(child: Text(error, style: const TextStyle(color: Colors.red, fontSize: 18)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.cloud, color: Colors.white),
                            label: const Text("Get Weather", style: TextStyle(color: Colors.white)),
                            onPressed: fetchWeather,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (todayWeather != null) buildLiveWeatherCard(),
                        if (weekForecast.isNotEmpty) ...[
                          TempHumidityChart(forecast: weekForecast),
                          const SizedBox(height: 12),
                          buildTempLineChart(),
                          const SizedBox(height: 16),
                          buildWeekForecast(),
                        ]
                      ],
                    ),
                  ),
      ),
    );
  }
}
