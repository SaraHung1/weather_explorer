import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/place.dart';
import '../services/api_exception.dart';
import '../services/favorites_service.dart';
import '../services/location_exception.dart';
import '../services/location_service.dart';
import '../services/weather_api_service.dart';
import '../widgets/favorite_place_card.dart';
import 'place_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherApiService _apiService = WeatherApiService();
  final FavoritesService _favoritesService = FavoritesService();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isLocating = false;

  List<Place> _favorites = [];
  bool _favoritesLoaded = false;

  List<Place>? _searchResults;
  bool _isSearching = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _favoritesService.loadFavorites();
    if (!mounted) return;
    setState(() {
      _favorites = favorites;
      _favoritesLoaded = true;
    });
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = null;
        _searchError = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query.trim()));
  }

  Future<void> _search(String query) async {
    setState(() {
      _isSearching = true;
      _searchError = null;
    });
    try {
      final results = await _apiService.searchPlaces(query);
      if (!mounted) return;
      setState(() => _searchResults = results);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _searchError = e.message);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  bool _isFavorite(Place place) => _favorites.any((p) => p.id == place.id);

  Future<void> _togglePin(Place place) async {
    final updated = _isFavorite(place)
        ? await _favoritesService.removeFavorite(place.id)
        : await _favoritesService.addFavorite(place);
    if (!mounted) return;
    setState(() => _favorites = updated);
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final place = await _locationService.getCurrentPlace();
      if (!mounted) return;
      await _openDetail(place);
    } on LocationException catch (e) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.message),
          action: e.shouldOpenSettings
              ? SnackBarAction(label: 'Open Settings', onPressed: Geolocator.openAppSettings)
              : null,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _openDetail(Place place) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place, apiService: _apiService)),
    );
    // Favourite status may have changed on the detail screen (pinned or
    // unpinned there); reload so the home list reflects it.
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final isShowingSearch = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Weather Pin')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search for a city…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: isShowingSearch
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: _isLocating ? null : _useCurrentLocation,
                  tooltip: 'Use my location',
                  icon: _isLocating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
          Expanded(child: isShowingSearch ? _buildSearchResults() : _buildFavorites()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchError != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_searchError!)));
    }
    final results = _searchResults ?? [];
    if (results.isEmpty) {
      return const Center(child: Text('No matching places found.'));
    }
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final place = results[index];
        final pinned = _isFavorite(place);
        return ListTile(
          title: Text(place.name),
          subtitle: Text(place.displayName),
          trailing: IconButton(
            icon: Icon(pinned ? Icons.push_pin : Icons.push_pin_outlined, color: pinned ? Colors.redAccent : null),
            tooltip: pinned ? 'Unpin' : 'Pin',
            onPressed: () => _togglePin(place),
          ),
          onTap: () => _openDetail(place),
        );
      },
    );
  }

  Widget _buildFavorites() {
    if (!_favoritesLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_favorites.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No pinned places yet. Search for a city above and tap the pin icon.', textAlign: TextAlign.center),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final place = _favorites[index];
          return FavoritePlaceCard(
            key: ValueKey(place.id),
            place: place,
            apiService: _apiService,
            onTap: () => _openDetail(place),
            onUnpin: () => _togglePin(place),
          );
        },
      ),
    );
  }
}
