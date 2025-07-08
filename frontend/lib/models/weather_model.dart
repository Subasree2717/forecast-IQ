// weather_model.dart
class WeatherData {
  final String date;
  final String weather;
  final int tempMax;

  WeatherData({required this.date, required this.weather, required this.tempMax});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      date: json['date'],
      weather: json['predicted_weather'],
      tempMax: json['predicted_tempmax'],
    );
  }
}
