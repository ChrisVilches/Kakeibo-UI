import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakeibo_ui/src/services/locator.dart';

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
}
