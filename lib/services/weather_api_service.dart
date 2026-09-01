import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/place.dart';
import '../models/weather.dart';
import 'api_exception.dart';

/// All network access lives here. Screens never call `http` directly —
/// they go through this service and only ever need to handle one
/// exception type, [ApiException].
///
/// Uses Open-Meteo (https://open-meteo.com), which is free, requires no
/// API key, and is explicitly designed for exactly this kind of use.
class WeatherApiService {
  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 10);

  /// GET geocoding-api.open-meteo.com/v1/search – turns a place name the
  /// user typed into a list of candidate locations with coordinates.
  Future<List<Place>> searchPlaces(String query) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query,
      'count': '10',
      'language': 'en',
      'format': 'json',
    });

    final json = await _getJsonObject(uri);
    // The API omits the "results" key entirely when nothing matches,
    // rather than returning an empty array — handle both.
    final results = json['results'] as List<dynamic>?;
    if (results == null) return [];
    return results.map((e) => Place.fromGeocodingJson(e as Map<String, dynamic>)).toList();
  }

  /// GET api.open-meteo.com/v1/forecast – current conditions plus a
  /// 7-day daily forecast for a coordinate pair.
  Future<Weather> fetchWeather(double latitude, double longitude) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
      'daily': 'temperature_2m_max,temperature_2m_min,weather_code',
      'timezone': 'auto',
      'forecast_days': '7',
    });

    final json = await _getJsonObject(uri);
    return Weather.fromJson(json);
  }

  Future<Map<String, dynamic>> _getJsonObject(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
        throw ApiException('Received an unexpected response shape from the server.');
      }

      throw ApiException(
        'Server returned an error (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } on FormatException {
      throw ApiException('Received an unexpected response from the server.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Something went wrong: $e');
    }
  }

  void dispose() => _client.close();
}
