class SignatureExpiredException implements Exception {
  @override
  String toString() {
    return "Session has expired";
  }
}
