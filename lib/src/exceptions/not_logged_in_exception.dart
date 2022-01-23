import 'package:kakeibo_ui/src/enums/token_removal_cause.dart';

class NotLoggedInException implements Exception {
  @override
  String toString() {
    return TokenRemovalCause.unknown.message;
  }
}
