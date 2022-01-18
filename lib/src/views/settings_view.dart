import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/controllers/settings_controller.dart';
import 'package:kakeibo_ui/src/decoration/extra_padding_widget.dart';
import 'package:kakeibo_ui/src/enums/currency_symbol.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key, required this.controller}) : super(key: key);

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    Widget themeDropdown = DropdownButton<ThemeMode>(
      value: controller.themeMode,
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
      items: CurrencySymbol.values
          .map((v) => DropdownMenuItem(value: v, child: Text(v.symbol)))
          .toList(),
    );

    Widget logoutButton = ElevatedButton(
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
      onPressed: controller.logout,
      child: const Text("Logout"),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ExtraPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [themeDropdown, currencySymbolDropdown, logoutButton],
        ),
      ),
    );
  }
}
