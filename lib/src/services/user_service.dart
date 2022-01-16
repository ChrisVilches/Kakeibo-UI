import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  Future<void> login(String email, String password) async {
    var endpoint = path.join(dotenv.env['API_URL']!, 'users', 'sign_in');

    final response = await http.post(Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user': {'email': email, 'password': password}
        }));

    if (response.statusCode == 200) {
      var token = response.headers['authorization'];

      await serviceLocator
          .get<FlutterSecureStorage>()
          .write(key: 'jwtToken', value: token);
    } else {
      throw Exception('Failed to login');
    }
  }
}
