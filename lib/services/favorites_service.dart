import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/place.dart';

/// Persists the user's pinned locations to on-device storage so they
/// survive an app restart. Screens never touch SharedPreferences
/// directly — everything goes through here, mirroring the same
/// "single point of contact" pattern used for network access.
class FavoritesService {
  static const String _storageKey = 'pinned_places';

  Future<List<Place>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => Place.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveFavorites(List<Place> places) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(places.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<List<Place>> addFavorite(Place place) async {
    final current = await loadFavorites();
    if (current.any((p) => p.id == place.id)) return current;
    final updated = [...current, place];
    await saveFavorites(updated);
    return updated;
  }

  Future<List<Place>> removeFavorite(int placeId) async {
    final current = await loadFavorites();
    final updated = current.where((p) => p.id != placeId).toList();
    await saveFavorites(updated);
    return updated;
  }
}
