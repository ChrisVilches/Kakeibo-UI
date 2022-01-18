import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakeibo_ui/src/enums/token_removal_cause.dart';
import 'package:kakeibo_ui/src/exceptions/incorrect_login_exception.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  String? _token;
  Function(TokenRemovalCause)? onTokenRemoved;

  String? get token {
    return _token;
  }

  Future<void> login(String email, String password) async {
    var endpoint = path.join(dotenv.env['API_URL']!, 'users', 'sign_in');

    final response = await http.post(Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user': {'email': email, 'password': password}
        }));

    if (response.statusCode == 200) {
      String? token = response.headers['authorization'];
      await _storeToken(token!);
    } else {
      throw IncorrectLoginException();
    }
  }

  Future<void> _storeToken(String token) async {
    _token = token;
    await serviceLocator
        .get<FlutterSecureStorage>()
        .write(key: 'jwtToken', value: token);
  }

  Future<void> removeToken(TokenRemovalCause cause) async {
    bool executeRemove = _token != null && onTokenRemoved != null;

    _token = null;

    if (executeRemove) {
      await serviceLocator.get<FlutterSecureStorage>().delete(key: 'jwtToken');
      onTokenRemoved!(cause);
    }
  }

  Future<void> loadStoredToken() async {
    _token =
        await serviceLocator.get<FlutterSecureStorage>().read(key: 'jwtToken');
  }

  /// Checks whether a token is stored or not (it does not check whether it's valid or not).
  bool hasToken() {
    return _token != null;
  }
}
