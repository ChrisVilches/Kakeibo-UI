import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakeibo_ui/src/enums/currency_symbol.dart';
import 'package:kakeibo_ui/src/services/locator.dart';

class SettingsService {
  Future<ThemeMode> themeMode() async {
    String? themeValue = await serviceLocator.get<FlutterSecureStorage>().read(key: 'theme');

    if (themeValue == 'dark') return ThemeMode.dark;
    if (themeValue == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    await serviceLocator.get<FlutterSecureStorage>().write(key: 'theme', value: theme.name);
  }

  Future<CurrencySymbol> currencySymbol() async {
    String? symbol = await serviceLocator.get<FlutterSecureStorage>().read(key: 'currencySymbol');

    for (final CurrencySymbol sym in CurrencySymbol.values) {
      if (sym.toString() == symbol) return sym;
    }

    return CurrencySymbol.dollar;
  }

  Future<void> updateCurrencySymbol(CurrencySymbol symbol) async {
    await serviceLocator
        .get<FlutterSecureStorage>()
        .write(key: 'currencySymbol', value: symbol.toString());
  }
}
