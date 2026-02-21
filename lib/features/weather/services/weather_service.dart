import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

/// Service for fetching weather data from WeatherAPI.com
class WeatherService {
  static const String _baseUrl = 'https://api.weatherapi.com/v1/forecast.json';
  static const String _apiKey = 'a0773967d7e54905b1785644262102';

  WeatherService._();
  static final WeatherService instance = WeatherService._();

  /// Fetch weather data for a given district/location
  Future<WeatherData> getWeatherForecast(String location) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'key': _apiKey,
        'q': location,
        'days': '7',
        'alerts': 'yes',
        'aqi': 'no',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return WeatherData.fromJson(json);
      } else if (response.statusCode == 400) {
        final json = jsonDecode(response.body);
        throw WeatherException(json['error']['message'] ?? 'Invalid location');
      } else {
        throw WeatherException('Failed to fetch weather data');
      }
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw WeatherException('Network error. Please check your connection.');
    }
  }
}

/// Exception class for weather-related errors
class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);

  @override
  String toString() => message;
}

