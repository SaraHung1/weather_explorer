/// A searchable place, as returned by Open-Meteo's geocoding API. Also
/// doubles as the shape we persist to disk for pinned favourites, via
/// [toJson]/[fromJson].
class Place {
  final int id;
  final String name;
  final String? admin1;
  final String country;
  final double latitude;
  final double longitude;

  Place({
    required this.id,
    required this.name,
    required this.admin1,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  /// A short, human-friendly label, e.g. "Portland, Oregon, United States"
  /// or "Paris, France" when there's no admin region to disambiguate.
  String get displayName {
    final parts = [name, if (admin1 != null && admin1!.isNotEmpty && admin1 != name) admin1, country];
    return parts.join(', ');
  }

  factory Place.fromGeocodingJson(Map<String, dynamic> json) {
    return Place(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      admin1: json['admin1'] as String?,
      country: json['country'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'admin1': admin1,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        admin1: json['admin1'] as String?,
        country: json['country'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
}
