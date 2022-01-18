import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/format_util.dart';
import 'package:kakeibo_ui/src/enums/currency_symbol.dart';
import 'package:kakeibo_ui/src/enums/token_removal_cause.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:kakeibo_ui/src/services/settings_service.dart';
import 'package:kakeibo_ui/src/services/user_service.dart';

// TODO: Learn how to use notifiers (notifyListeners).

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;

  late ThemeMode _themeMode;
  late CurrencySymbol _currencySymbol;

  ThemeMode get themeMode => _themeMode;
  CurrencySymbol get currencySymbol => _currencySymbol;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _currencySymbol = await _settingsService.currencySymbol();

    // Important! Inform listeners a change has occurred.
    notifyListeners();
    FormatUtil.setCurrency(_currencySymbol);
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updateCurrencySymbol(CurrencySymbol? newCurrencySymbol) async {
    if (newCurrencySymbol == null) return;
    if (newCurrencySymbol == _currencySymbol) return;
    _currencySymbol = newCurrencySymbol;
    FormatUtil.setCurrency(_currencySymbol);
    notifyListeners();
    await _settingsService.updateCurrencySymbol(newCurrencySymbol);
  }

  Future<void> logout() async {
    await serviceLocator.get<UserService>().removeToken(TokenRemovalCause.manualLogout);
  }
}
