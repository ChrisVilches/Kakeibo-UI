import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakeibo_ui/src/decoration/helpers.dart';
import 'package:kakeibo_ui/src/enums/token_removal_cause.dart';
import 'package:kakeibo_ui/src/login_view.dart';
import 'package:kakeibo_ui/src/services/graphql_services.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:kakeibo_ui/src/services/user_service.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/services/settings_service.dart';

Future<void> main() async {
  await dotenv.load(fileName: kReleaseMode ? ".env.production" : ".env.development");
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  setUpLocator();

  await serviceLocator.get<UserService>().loadStoredToken();
  await serviceLocator<GraphQLServices>().initialize();
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  /**
   * TODO: This hook will execute even if the user opens the app after the token has expired, and this will make the splash screen get skipped.
   */
  serviceLocator.get<UserService>().onTokenRemoved = (TokenRemovalCause cause) async {
    print("Token removal (hook executed), cause: $cause");
    Helpers.simpleSnackbar(navigatorKey.currentContext!, cause.message);
    Navigator.of(navigatorKey.currentContext!).pushReplacementNamed(LoginView.routeName);
  };

  runApp(MyApp(settingsController: settingsController, navigatorKey: navigatorKey));
}
