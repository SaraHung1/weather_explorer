class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;

  DailyForecast({required this.date, required this.maxTemp, required this.minTemp, required this.weatherCode});
}

class Weather {
  final double temperature;
  final int humidity;
  final double windSpeedKmh;
  final int weatherCode;
  final List<DailyForecast> daily;

  Weather({
    required this.temperature,
    required this.humidity,
    required this.windSpeedKmh,
    required this.weatherCode,
    required this.daily,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final daily = json['daily'] as Map<String, dynamic>? ?? {};

    final dates = (daily['time'] as List<dynamic>? ?? []).cast<String>();
    final maxTemps = (daily['temperature_2m_max'] as List<dynamic>? ?? []).cast<num>();
    final minTemps = (daily['temperature_2m_min'] as List<dynamic>? ?? []).cast<num>();
    final codes = (daily['weather_code'] as List<dynamic>? ?? []).cast<num>();

    final forecasts = <DailyForecast>[];
    for (var i = 0; i < dates.length; i++) {
      forecasts.add(DailyForecast(
        date: DateTime.tryParse(dates[i]) ?? DateTime.now(),
        maxTemp: i < maxTemps.length ? maxTemps[i].toDouble() : 0,
        minTemp: i < minTemps.length ? minTemps[i].toDouble() : 0,
        weatherCode: i < codes.length ? codes[i].toInt() : 0,
      ));
    }

    return Weather(
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
      humidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      windSpeedKmh: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      daily: forecasts,
    );
  }
}
