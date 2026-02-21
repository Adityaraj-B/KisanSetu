import 'dart:ui' show Color;

/// Weather data models for WeatherAPI.com responses
class WeatherData {
  final Location location;
  final CurrentWeather current;
  final Forecast forecast;
  final List<Alert> alerts;

  WeatherData({
    required this.location,
    required this.current,
    required this.forecast,
    required this.alerts,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final alertsData = json['alerts']?['alert'] as List<dynamic>? ?? [];
    return WeatherData(
      location: Location.fromJson(json['location']),
      current: CurrentWeather.fromJson(json['current']),
      forecast: Forecast.fromJson(json['forecast']),
      alerts: alertsData.map((a) => Alert.fromJson(a)).toList(),
    );
  }
}

class Location {
  final String name;
  final String region;
  final String country;
  final String localtime;

  Location({
    required this.name,
    required this.region,
    required this.country,
    required this.localtime,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] ?? '',
      region: json['region'] ?? '',
      country: json['country'] ?? '',
      localtime: json['localtime'] ?? '',
    );
  }
}

class CurrentWeather {
  final double tempC;
  final double feelsLikeC;
  final int humidity;
  final double windKph;
  final String windDir;
  final double precipMm;
  final int cloud;
  final double uv;
  final WeatherCondition condition;
  final int isDay;

  CurrentWeather({
    required this.tempC,
    required this.feelsLikeC,
    required this.humidity,
    required this.windKph,
    required this.windDir,
    required this.precipMm,
    required this.cloud,
    required this.uv,
    required this.condition,
    required this.isDay,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      tempC: (json['temp_c'] ?? 0).toDouble(),
      feelsLikeC: (json['feelslike_c'] ?? 0).toDouble(),
      humidity: json['humidity'] ?? 0,
      windKph: (json['wind_kph'] ?? 0).toDouble(),
      windDir: json['wind_dir'] ?? '',
      precipMm: (json['precip_mm'] ?? 0).toDouble(),
      cloud: json['cloud'] ?? 0,
      uv: (json['uv'] ?? 0).toDouble(),
      condition: WeatherCondition.fromJson(json['condition'] ?? {}),
      isDay: json['is_day'] ?? 1,
    );
  }
}

class WeatherCondition {
  final String text;
  final String icon;
  final int code;

  WeatherCondition({
    required this.text,
    required this.icon,
    required this.code,
  });

  factory WeatherCondition.fromJson(Map<String, dynamic> json) {
    return WeatherCondition(
      text: json['text'] ?? '',
      icon: json['icon'] ?? '',
      code: json['code'] ?? 0,
    );
  }

  /// Get the full icon URL with https
  String get iconUrl => icon.startsWith('//') ? 'https:$icon' : icon;
}

class Forecast {
  final List<ForecastDay> forecastDays;

  Forecast({required this.forecastDays});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    final days = json['forecastday'] as List<dynamic>? ?? [];
    return Forecast(
      forecastDays: days.map((d) => ForecastDay.fromJson(d)).toList(),
    );
  }
}

class ForecastDay {
  final String date;
  final DayForecast day;
  final Astro astro;
  final List<HourForecast> hours;

  ForecastDay({
    required this.date,
    required this.day,
    required this.astro,
    required this.hours,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    final hoursList = json['hour'] as List<dynamic>? ?? [];
    return ForecastDay(
      date: json['date'] ?? '',
      day: DayForecast.fromJson(json['day'] ?? {}),
      astro: Astro.fromJson(json['astro'] ?? {}),
      hours: hoursList.map((h) => HourForecast.fromJson(h)).toList(),
    );
  }

  /// Get DateTime from date string
  DateTime get dateTime => DateTime.parse(date);
}

class DayForecast {
  final double maxTempC;
  final double minTempC;
  final double avgTempC;
  final double totalPrecipMm;
  final double maxWindKph;
  final double avgHumidity;
  final int dailyChanceOfRain;
  final WeatherCondition condition;
  final double uv;

  DayForecast({
    required this.maxTempC,
    required this.minTempC,
    required this.avgTempC,
    required this.totalPrecipMm,
    required this.maxWindKph,
    required this.avgHumidity,
    required this.dailyChanceOfRain,
    required this.condition,
    required this.uv,
  });

  factory DayForecast.fromJson(Map<String, dynamic> json) {
    return DayForecast(
      maxTempC: (json['maxtemp_c'] ?? 0).toDouble(),
      minTempC: (json['mintemp_c'] ?? 0).toDouble(),
      avgTempC: (json['avgtemp_c'] ?? 0).toDouble(),
      totalPrecipMm: (json['totalprecip_mm'] ?? 0).toDouble(),
      maxWindKph: (json['maxwind_kph'] ?? 0).toDouble(),
      avgHumidity: (json['avghumidity'] ?? 0).toDouble(),
      dailyChanceOfRain: json['daily_chance_of_rain'] ?? 0,
      condition: WeatherCondition.fromJson(json['condition'] ?? {}),
      uv: (json['uv'] ?? 0).toDouble(),
    );
  }
}

class Astro {
  final String sunrise;
  final String sunset;

  Astro({
    required this.sunrise,
    required this.sunset,
  });

  factory Astro.fromJson(Map<String, dynamic> json) {
    return Astro(
      sunrise: json['sunrise'] ?? '',
      sunset: json['sunset'] ?? '',
    );
  }
}

class HourForecast {
  final String time;
  final double tempC;
  final int humidity;
  final double windKph;
  final double precipMm;
  final int chanceOfRain;
  final WeatherCondition condition;

  HourForecast({
    required this.time,
    required this.tempC,
    required this.humidity,
    required this.windKph,
    required this.precipMm,
    required this.chanceOfRain,
    required this.condition,
  });

  factory HourForecast.fromJson(Map<String, dynamic> json) {
    return HourForecast(
      time: json['time'] ?? '',
      tempC: (json['temp_c'] ?? 0).toDouble(),
      humidity: json['humidity'] ?? 0,
      windKph: (json['wind_kph'] ?? 0).toDouble(),
      precipMm: (json['precip_mm'] ?? 0).toDouble(),
      chanceOfRain: json['chance_of_rain'] ?? 0,
      condition: WeatherCondition.fromJson(json['condition'] ?? {}),
    );
  }

  /// Get hour as DateTime
  DateTime get dateTime => DateTime.parse(time);
}

class Alert {
  final String headline;
  final String msgtype;
  final String severity;
  final String urgency;
  final String areas;
  final String event;
  final String effective;
  final String expires;
  final String desc;
  final String instruction;

  Alert({
    required this.headline,
    required this.msgtype,
    required this.severity,
    required this.urgency,
    required this.areas,
    required this.event,
    required this.effective,
    required this.expires,
    required this.desc,
    required this.instruction,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      headline: json['headline'] ?? '',
      msgtype: json['msgtype'] ?? '',
      severity: json['severity'] ?? '',
      urgency: json['urgency'] ?? '',
      areas: json['areas'] ?? '',
      event: json['event'] ?? '',
      effective: json['effective'] ?? '',
      expires: json['expires'] ?? '',
      desc: json['desc'] ?? '',
      instruction: json['instruction'] ?? '',
    );
  }

  /// Get severity color for UI
  Color get severityColor {
    switch (severity.toLowerCase()) {
      case 'extreme':
        return const Color(0xFFD32F2F);
      case 'severe':
        return const Color(0xFFFF5722);
      case 'moderate':
        return const Color(0xFFFF9800);
      case 'minor':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}



