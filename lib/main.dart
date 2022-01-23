import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakeibo_ui/src/services/snackbar_service.dart';
import 'package:kakeibo_ui/src/enums/token_removal_cause.dart';
import 'package:kakeibo_ui/src/services/gql_client.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:kakeibo_ui/src/services/user_service.dart';
import 'package:kakeibo_ui/src/views/login_view.dart';
import 'src/app.dart';
import 'src/controllers/settings_controller.dart';
import 'src/services/settings_service.dart';

Future<void> main() async {
  await dotenv.load(fileName: kReleaseMode ? ".env.production" : ".env.development");
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  setUpLocator(navigatorKey);

  await serviceLocator.get<UserService>().loadStoredToken();
  await serviceLocator<GQLClient>().initialize();
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  // TODO: This hook will execute even if the user opens the app after the token has expired,
  //       and this will make the splash screen get skipped.
  // Logout could happen from any screen, therefore it's necessary to have a mechanism
  // to catch the logout globally.
  // TODO: However, logging out from other views is untested.
  serviceLocator.get<UserService>().onTokenRemoved =
      (TokenRemovalCause cause, bool triggerSnackbar) async {
    debugPrint(
        "(main.dart) onTokenRemoved executed. Snackbar message: ${cause.message}. Trigger snackbar: $triggerSnackbar");

    if (triggerSnackbar) {
      SnackbarService.simpleSnackbar(navigatorKey.currentContext!, cause.message);
    }

    Navigator.of(navigatorKey.currentContext!).pushReplacementNamed(LoginView.routeName);
  };

  runApp(MyApp(settingsController: settingsController, navigatorKey: navigatorKey));
}
