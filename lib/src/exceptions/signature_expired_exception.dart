import 'package:kakeibo_ui/src/enums/token_removal_cause.dart';

class SignatureExpiredException implements Exception {
  @override
  String toString() {
    return TokenRemovalCause.sessionExpired.message;
  }
}
