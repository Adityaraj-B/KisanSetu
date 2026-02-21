import 'package:flutter/material.dart';
import '../../features/weather/models/weather_model.dart';
import '../../features/weather/services/weather_service.dart';

/// WeatherProvider - Manages weather state shared across the app
class WeatherProvider extends ChangeNotifier {
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;
  String? _lastLocation;

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get lastLocation => _lastLocation;

  bool get hasData => _weatherData != null;

  /// Current temperature in Celsius
  double? get currentTemp => _weatherData?.current.tempC;

  /// Current weather condition text
  String? get conditionText => _weatherData?.current.condition.text;

  /// Current humidity
  int? get humidity => _weatherData?.current.humidity;

  /// Current wind speed
  double? get windKph => _weatherData?.current.windKph;

  /// Current precipitation
  double? get precipMm => _weatherData?.current.precipMm;

  /// Is daytime
  bool get isDay => (_weatherData?.current.isDay ?? 1) == 1;

  /// Location name
  String? get locationName => _weatherData?.location.name;

  /// Fetch weather for a given location (skips if same location already loaded)
  Future<void> fetchWeather(String location, {bool forceRefresh = false}) async {
    if (location.trim().isEmpty) return;

    // Skip if already loading the same location
    if (_isLoading) return;

    // Skip if already have data for the same location (unless forced)
    if (!forceRefresh &&
        _weatherData != null &&
        _lastLocation?.toLowerCase() == location.trim().toLowerCase()) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await WeatherService.instance.getWeatherForecast(location.trim());
      _weatherData = data;
      _lastLocation = location.trim();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a weather emoji based on current condition code
  String get weatherEmoji {
    if (_weatherData == null) return '🌤️';
    final code = _weatherData!.current.condition.code;
    final isDay = (_weatherData!.current.isDay == 1);

    // Sunny/Clear
    if (code == 1000) return isDay ? '☀️' : '🌙';
    // Partly cloudy
    if (code == 1003) return isDay ? '⛅' : '🌤️';
    // Cloudy / Overcast
    if (code == 1006 || code == 1009) return '☁️';
    // Fog / Mist
    if (code >= 1030 && code <= 1072) return '🌫️';
    // Light drizzle
    if (code >= 1150 && code <= 1153) return '🌦️';
    // Rain
    if (code >= 1180 && code <= 1201) return '🌧️';
    // Heavy rain
    if (code >= 1240 && code <= 1246) return '⛈️';
    // Snow
    if (code >= 1210 && code <= 1237) return '❄️';
    // Sleet
    if (code >= 1249 && code <= 1264) return '🌨️';
    // Thunder
    if (code >= 1273 && code <= 1282) return '⛈️';
    return '🌤️';
  }

  /// Get gradient colors based on weather condition
  List<Color> get weatherGradient {
    if (_weatherData == null) {
      return [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
    }
    final code = _weatherData!.current.condition.code;
    final isDay = (_weatherData!.current.isDay == 1);

    if (code == 1000) {
      return isDay
          ? [const Color(0xFFFF8F00), const Color(0xFFFFCA28)]
          : [const Color(0xFF1A237E), const Color(0xFF283593)];
    }
    if (code == 1003 || code == 1006) {
      return [const Color(0xFF455A64), const Color(0xFF78909C)];
    }
    if (code >= 1030 && code <= 1072) {
      return [const Color(0xFF546E7A), const Color(0xFF90A4AE)];
    }
    if (code >= 1180 && code <= 1246) {
      return [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
    }
    if (code >= 1210 && code <= 1264) {
      return [const Color(0xFF37474F), const Color(0xFF607D8B)];
    }
    if (code >= 1273) {
      return [const Color(0xFF4A148C), const Color(0xFF7B1FA2)];
    }
    return [const Color(0xFF1976D2), const Color(0xFF42A5F5)];
  }
}


