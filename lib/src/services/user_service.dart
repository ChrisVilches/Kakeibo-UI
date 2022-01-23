import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kakeibo_ui/src/enums/token_removal_cause.dart';
import 'package:kakeibo_ui/src/exceptions/incorrect_login_exception.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  String? _token;
  Function(TokenRemovalCause, bool)? onTokenRemoved;

  String? get token {
    return _token;
  }

  Map<String, String> getHeaders() {
    Map<String, String> result = {};
    if (hasToken()) result['authorization'] = _token!;
    result['Content-Type'] = 'application/json';
    return result;
  }

  Future<void> login(String email, String password) async {
    final endpoint = path.join(dotenv.env['API_URL']!, 'users', 'sign_in');

    final response = await http.post(Uri.parse(endpoint),
        headers: getHeaders(),
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

  void errorHandler(Response response) {}

  Future<void> logout() async {
    final endpoint = path.join(dotenv.env['API_URL']!, 'users', 'sign_out');

    http.Response response = await http.delete(Uri.parse(endpoint), headers: getHeaders());

    if (response.statusCode != 200) {
      throw Exception('Error while logging out.');
    }

    // TODO: Issue on Github regarding splash screen (being skipped) and conflicting snackbars.
    removeToken(TokenRemovalCause.manualLogout);
  }

  Future<void> _storeToken(String token) async {
    _token = token;
    await serviceLocator.get<FlutterSecureStorage>().write(key: 'jwtToken', value: token);
  }

  Future<void> removeToken(TokenRemovalCause cause, {bool triggerSnackbar = true}) async {
    if (_token == null) return;

    _token = null;
    await serviceLocator.get<FlutterSecureStorage>().delete(key: 'jwtToken');
    onTokenRemoved?.call(cause, triggerSnackbar);
  }

  Future<void> loadStoredToken() async {
    _token = await serviceLocator.get<FlutterSecureStorage>().read(key: 'jwtToken');
  }

  /// Checks whether a token is stored or not (it does not check whether it's valid or not).
  bool hasToken() {
    return _token != null;
  }
}
