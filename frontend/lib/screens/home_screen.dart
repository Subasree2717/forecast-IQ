import 'package:flutter/material.dart';
import '../services/weather_api.dart';
import '../models/weather_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<WeatherData>> forecast;

  @override
  void initState() {
    super.initState();
    forecast = WeatherAPI.getForecast(); // Fetch 7-day forecast
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
          title: const Text("7-Day Weather Forecast"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: FutureBuilder<List<WeatherData>>(
          future: forecast,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No forecast data available."));
            }

            final data = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final day = data[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: Icon(
                      _getWeatherIcon(day.weather),
                      size: 40,
                      color: Colors.indigoAccent,
                    ),
                    title: Text(
                      day.date,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      day.weather,
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: Text(
                      "${day.tempMax}°C",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String weather) {
    switch (weather.toLowerCase()) {
      case "sunny":
        return Icons.wb_sunny;
      case "cloudy":
      case "overcast":
        return Icons.cloud;
      case "rain":
      case "rainy":
        return Icons.umbrella;
      case "snow":
        return Icons.ac_unit;
      case "partly-cloudy-day":
      case "partly cloudy":
        return Icons.wb_cloudy;
      default:
        return Icons.wb_sunny;
    }
  }
}
