class HttpRequestException implements Exception {
  final String _message;

  HttpRequestException(this._message);

  @override
  String toString() {
    return _message;
  }
}
