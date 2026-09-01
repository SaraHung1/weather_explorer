import 'package:flutter/material.dart';

class WeatherInfo {
  final String description;
  final IconData icon;

  const WeatherInfo(this.description, this.icon);
}

/// Open-Meteo reports conditions as WMO weather interpretation codes
/// (the same table used by most national weather services), not a
/// free-text description — this is the standard mapping.
WeatherInfo describeWeatherCode(int code) {
  switch (code) {
    case 0:
      return const WeatherInfo('Clear sky', Icons.wb_sunny);
    case 1:
      return const WeatherInfo('Mainly clear', Icons.wb_sunny_outlined);
    case 2:
      return const WeatherInfo('Partly cloudy', Icons.cloud_queue);
    case 3:
      return const WeatherInfo('Overcast', Icons.cloud);
    case 45:
    case 48:
      return const WeatherInfo('Fog', Icons.foggy);
    case 51:
    case 53:
    case 55:
      return const WeatherInfo('Drizzle', Icons.grain);
    case 56:
    case 57:
      return const WeatherInfo('Freezing drizzle', Icons.grain);
    case 61:
    case 63:
    case 65:
      return const WeatherInfo('Rain', Icons.water_drop);
    case 66:
    case 67:
      return const WeatherInfo('Freezing rain', Icons.water_drop);
    case 71:
    case 73:
    case 75:
    case 77:
      return const WeatherInfo('Snow', Icons.ac_unit);
    case 80:
    case 81:
    case 82:
      return const WeatherInfo('Rain showers', Icons.water_drop);
    case 85:
    case 86:
      return const WeatherInfo('Snow showers', Icons.ac_unit);
    case 95:
      return const WeatherInfo('Thunderstorm', Icons.thunderstorm);
    case 96:
    case 99:
      return const WeatherInfo('Thunderstorm with hail', Icons.thunderstorm);
    default:
      return const WeatherInfo('Unknown', Icons.help_outline);
  }
}
