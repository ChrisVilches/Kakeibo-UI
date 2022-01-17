import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/extra_padding_widget.dart';
import 'package:kakeibo_ui/src/enums/currency_symbol.dart';
import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({Key? key, required this.controller}) : super(key: key);

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    Widget themeDropdown = DropdownButton<ThemeMode>(
      // Read the selected themeMode from the controller
      value: controller.themeMode,
      // Call the updateThemeMode method any time the user selects a theme.
      onChanged: controller.updateThemeMode,
      items: const [
        DropdownMenuItem(
          value: ThemeMode.system,
          child: Text('System Theme'),
        ),
        DropdownMenuItem(
          value: ThemeMode.light,
          child: Text('Light Theme'),
        ),
        DropdownMenuItem(
          value: ThemeMode.dark,
          child: Text('Dark Theme'),
        )
      ],
    );

    Widget currencySymbolDropdown = DropdownButton<CurrencySymbol>(
      value: controller.currencySymbol,
      onChanged: controller.updateCurrencySymbol,
      items: const [
        DropdownMenuItem(
          value: CurrencySymbol.dollar,
          child: Text('\$'),
        ),
        DropdownMenuItem(
          value: CurrencySymbol.euro,
          child: Text('€'),
        ),
        DropdownMenuItem(
          value: CurrencySymbol.yen,
          child: Text('¥'),
        )
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ExtraPadding(
        // Glue the SettingsController to the theme selection DropdownButton.
        //
        // When a user selects a theme from the dropdown list, the
        // SettingsController is updated, which rebuilds the MaterialApp.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [themeDropdown, currencySymbolDropdown],
        ),
      ),
    );
  }
}
