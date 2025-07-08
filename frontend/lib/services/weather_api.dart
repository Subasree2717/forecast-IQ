// weather_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherAPI {
  static const baseUrl = 'http://localhost:5000'; // replace with IP if needed

  static Future<List<WeatherData>> getForecast() async {
    final res = await http.get(Uri.parse('$baseUrl/predict-week'));
    if (res.statusCode == 200) {
      final List jsonData = json.decode(res.body);
      return jsonData.map((e) => WeatherData.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load weather");
    }
  }
}
