import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:kakeibo_ui/src/enums/currency_symbol.dart';

class SettingsService {
  Future<ThemeMode> themeMode() async {
    String? themeValue =
        await serviceLocator.get<FlutterSecureStorage>().read(key: 'theme');

    if (themeValue == 'dark') {
      return ThemeMode.dark;
    } else if (themeValue == 'light') {
      return ThemeMode.light;
    }

    return ThemeMode.system;
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    String themeName = 'system';

    if (theme == ThemeMode.light) {
      themeName = 'light';
    } else if (theme == ThemeMode.dark) {
      themeName = 'dark';
    }

    await serviceLocator
        .get<FlutterSecureStorage>()
        .write(key: 'theme', value: themeName);
  }

  Future<CurrencySymbol> currencySymbol() async {
    String? symbol = await serviceLocator
        .get<FlutterSecureStorage>()
        .read(key: 'currencySymbol');

    for (final CurrencySymbol sym in CurrencySymbol.values) {
      if (sym.toString() == symbol) {
        return sym;
      }
    }

    return CurrencySymbol.dollar;
  }

  Future<void> updateCurrencySymbol(CurrencySymbol symbol) async {
    await serviceLocator
        .get<FlutterSecureStorage>()
        .write(key: 'currencySymbol', value: symbol.toString());
  }
}
