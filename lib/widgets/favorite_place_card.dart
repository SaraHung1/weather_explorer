import 'package:flutter/material.dart';

import '../models/place.dart';
import '../models/weather.dart';
import '../services/weather_api_service.dart';
import '../utils/weather_code.dart';

class FavoritePlaceCard extends StatefulWidget {
  const FavoritePlaceCard({
    super.key,
    required this.place,
    required this.apiService,
    required this.onTap,
    required this.onUnpin,
  });

  final Place place;
  final WeatherApiService apiService;
  final VoidCallback onTap;
  final VoidCallback onUnpin;

  @override
  State<FavoritePlaceCard> createState() => _FavoritePlaceCardState();
}

class _FavoritePlaceCardState extends State<FavoritePlaceCard> {
  late final Future<Weather> _weatherFuture;

  @override
  void initState() {
    super.initState();
    // Fetched exactly once per card, not on every rebuild — the result
    // is reused for both the icon and the temperature below.
    _weatherFuture = widget.apiService.fetchWeather(widget.place.latitude, widget.place.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: widget.onTap,
        title: Text(widget.place.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(widget.place.displayName),
        leading: FutureBuilder<Weather>(
          future: _weatherFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2));
            }
            if (snapshot.hasError) {
              return const Icon(Icons.cloud_off, color: Colors.grey);
            }
            final info = describeWeatherCode(snapshot.data!.weatherCode);
            return Icon(info.icon, size: 28);
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<Weather>(
              future: _weatherFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox(width: 44);
                return Text('${snapshot.data!.temperature.round()}°', style: Theme.of(context).textTheme.titleMedium);
              },
            ),
            IconButton(
              icon: const Icon(Icons.push_pin, color: Colors.redAccent),
              tooltip: 'Unpin',
              onPressed: widget.onUnpin,
            ),
          ],
        ),
      ),
    );
  }
}
