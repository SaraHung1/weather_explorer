/// Raised for anything location-permission or device-service related —
/// kept separate from [ApiException] since these aren't network failures
/// and usually need a different message and action (e.g. "open Settings"
/// rather than "retry").
class LocationException implements Exception {
  final String message;
  final bool shouldOpenSettings;

  LocationException(this.message, {this.shouldOpenSettings = false});

  @override
  String toString() => message;
}
