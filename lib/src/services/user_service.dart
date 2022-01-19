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

  Future<void> logout() async {
    final endpoint = path.join(dotenv.env['API_URL']!, 'users', 'sign_out');

    // TODO: Too verbose
    http.delete(Uri.parse(endpoint), headers: getHeaders()).then((response) {
      if (response.statusCode != 200) {
        print("Some error happened when signing out");
      }
    }).catchError((error) {
      print("Some error happened when signing out: $error");
    });

    /**
     * TODO:
     * Working OK but here's one problem:
     * 
     * 1. Comment the "removeToken" line
     * 2. Login
     * 3. Press logout (nothing happens. Rails gets a request though)
     * 4. Restart app
     * 5. App will still have a token, but it's denied, so a "please login" message will happen.
     * 6. And the following exception will happen as well:
     * 
     * [ERROR:flutter/lib/ui/ui_dart_state.cc(209)] Unhandled Exception: Null check operator used on a null value
     * #0 PeriodQueries.fetchAll (package:kakeibo_ui/src/models/extensions/period_queries.dart:22:43)
     * 
     * Also I forgot about the hook in the main.dart file:
     * serviceLocator.get<UserService>().onTokenRemoved = (TokenRemovalCause cause)
     * 
     * Is this conflicting with the user error handling code in the gql_client.dart file?
     * 
     * One possible solution would be to keep that hook, and create a User Controller with ChangeNotifier
     * The "Future<void> logout() async { await serviceLocator.get<UserService>().logout(); }" in the
     * settings controller move it to that new user controller.
     * In the user controller, execute notifyListeners() when a token is added or removed.
     * Provide the home (or whole mainApp) with this controller, and that way the login/periodList
     * view will be selected accordingly each time the token is removed
     * 
     * Things to check: If I implemented the above, when the token is added and homepage is notified,
     * does the view change abruptly to period list? (note: I have to remove the "navigate to period list after login"
     * since the change happens automatically). If not, then it might be good to just notifyListeners
     * when the token is removed, not added.
     * 
     * Then the userService only contains HTTP services, and not so much token management stuff.
     * Although the token also has to be in the user service, because the controller doesn't have
     * direct access to data, whether it's in the remote or local database.
     * 
     * Another thing to test: In the global error handler I'm outputting the "Not logged in" text,
     * put the "plase log in" text is shown in the snackbar. This may be a conflict because two
     * snackbars are showing (one because of the global error handler, and another because of the
     * onRemoveToken hook). I need to decide how to show the correct text.
     * 
     * Anyway, the best way to test this is working for all cases without strange things.
     * 
     * Note that it mostly works OK already, but the error described at the top of this text
     * is when the token is denied (in the backend), and then I try to open the app normally
     * as if it had a token. Then it fails (it has incorrect error handling and flow of operations, redirection, etc).
     * Other than that, there's no problem.
     * 
     */

    removeToken(TokenRemovalCause.manualLogout);
  }

  Future<void> _storeToken(String token) async {
    _token = token;
    await serviceLocator.get<FlutterSecureStorage>().write(key: 'jwtToken', value: token);
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
    _token = await serviceLocator.get<FlutterSecureStorage>().read(key: 'jwtToken');
  }

  /// Checks whether a token is stored or not (it does not check whether it's valid or not).
  bool hasToken() {
    return _token != null;
  }
}
