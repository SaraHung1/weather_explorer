import 'package:flutter/material.dart';

import '../models/place.dart';
import '../models/weather.dart';
import '../services/api_exception.dart';
import '../services/favorites_service.dart';
import '../services/weather_api_service.dart';
import '../utils/weather_code.dart';

class PlaceDetailScreen extends StatefulWidget {
  const PlaceDetailScreen({super.key, required this.place, required this.apiService});

  final Place place;
  final WeatherApiService apiService;

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  late Future<Weather> _weatherFuture;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _weatherFuture = widget.apiService.fetchWeather(widget.place.latitude, widget.place.longitude);
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final favorites = await _favoritesService.loadFavorites();
    if (!mounted) return;
    setState(() => _isFavorite = favorites.any((p) => p.id == widget.place.id));
  }

  Future<void> _togglePin() async {
    if (_isFavorite) {
      await _favoritesService.removeFavorite(widget.place.id);
    } else {
      await _favoritesService.addFavorite(widget.place);
    }
    if (!mounted) return;
    setState(() => _isFavorite = !_isFavorite);
  }

  Future<void> _refresh() async {
    setState(() {
      _weatherFuture = widget.apiService.fetchWeather(widget.place.latitude, widget.place.longitude);
    });
    await _weatherFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.name),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.push_pin : Icons.push_pin_outlined),
            tooltip: _isFavorite ? 'Unpin' : 'Pin',
            onPressed: _togglePin,
          ),
        ],
      ),
      body: FutureBuilder<Weather>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final message = snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Could not load weather.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _refresh, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }

          final weather = snapshot.data!;
          final info = describeWeatherCode(weather.weatherCode);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(widget.place.displayName, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Icon(info.icon, size: 72),
                      const SizedBox(height: 8),
                      Text('${weather.temperature.round()}°C', style: Theme.of(context).textTheme.displaySmall),
                      Text(info.description, style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MetricTile(icon: Icons.water_drop_outlined, label: 'Humidity', value: '${weather.humidity}%'),
                    _MetricTile(icon: Icons.air, label: 'Wind', value: '${weather.windSpeedKmh.round()} km/h'),
                  ],
                ),
                const SizedBox(height: 24),
                Text('7-day forecast', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...weather.daily.map((day) {
                  final dayInfo = describeWeatherCode(day.weatherCode);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(dayInfo.icon),
                    title: Text(_weekdayLabel(day.date)),
                    subtitle: Text(dayInfo.description),
                    trailing: Text('${day.maxTemp.round()}° / ${day.minTemp.round()}°'),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  String _weekdayLabel(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();
    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Today';
    }
    return weekdays[date.weekday - 1];
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
