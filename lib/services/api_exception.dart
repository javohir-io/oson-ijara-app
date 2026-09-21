/// A human-readable error surfaced from the backend (or from a network
/// failure), meant to be shown directly in a SnackBar/dialog.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
