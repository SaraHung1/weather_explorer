import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/place.dart';
import 'location_exception.dart';

/// Wraps the device's GPS (via `geolocator`) and reverse geocoding (via
/// `geocoding`) into a single call that returns a [Place], mirroring the
/// existing Open-Meteo forward-geocoding search results — so the rest of
/// the app (favorites, the detail screen) doesn't need to know whether a
/// place came from a search or from the device's current location.
class LocationService {
  /// Resolves the device's current GPS position into a [Place], handling
  /// every permission/service state explicitly so callers only ever need
  /// to catch [LocationException].
  Future<Place> getCurrentPlace() async {
    final position = await _getCurrentPosition();

    List<Placemark> placemarks;
    try {
      placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    } catch (_) {
      throw LocationException('Could not determine an address for your location.');
    }

    if (placemarks.isEmpty) {
      throw LocationException('Could not determine an address for your location.');
    }

    final mark = placemarks.first;
    final name = mark.locality?.isNotEmpty == true
        ? mark.locality!
        : (mark.subAdministrativeArea?.isNotEmpty == true ? mark.subAdministrativeArea! : 'Current location');

    return Place(
      id: _syntheticId(position.latitude, position.longitude),
      name: name,
      admin1: mark.administrativeArea,
      country: mark.country ?? '',
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Location services are turned off on this device.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Location permission was denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'Location permission is permanently denied. Enable it in Settings to use this feature.',
        shouldOpenSettings: true,
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
    } catch (_) {
      throw LocationException('Could not get your current location. Please try again.');
    }
  }

  /// Real Open-Meteo geocoding ids are positive; a negative id derived
  /// from rounded coordinates guarantees no collision with those, while
  /// staying stable so pinning the same spot twice reuses one entry.
  int _syntheticId(double lat, double lon) {
    final key = '${lat.toStringAsFixed(3)}_${lon.toStringAsFixed(3)}';
    return -(key.hashCode.abs());
  }
}
