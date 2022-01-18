class IncorrectLoginException implements Exception {
  @override
  String toString() {
    return "The username or password you entered is incorrect";
  }
}
