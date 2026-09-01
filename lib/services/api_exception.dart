/// A single, friendly exception type for anything that can go wrong
/// while talking to the network. UI code only ever needs to catch this.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
