import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/format_util.dart';
import 'package:kakeibo_ui/src/enums/currency_symbol.dart';
import 'package:kakeibo_ui/src/enums/token_removal_cause.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:kakeibo_ui/src/services/settings_service.dart';
import 'package:kakeibo_ui/src/services/user_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;

  late ThemeMode _themeMode;
  late CurrencySymbol _currencySymbol;

  ThemeMode get themeMode => _themeMode;
  CurrencySymbol get currencySymbol => _currencySymbol;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _currencySymbol = await _settingsService.currencySymbol();

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
    await serviceLocator.get<UserService>().logout();
  }
}
