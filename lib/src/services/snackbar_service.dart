import 'package:flutter/material.dart';

class SnackbarService {
  final GlobalKey<NavigatorState> _navigatorKey;

  const SnackbarService(GlobalKey<NavigatorState> navigatorKey) : _navigatorKey = navigatorKey;

  /// Closes all snackbars and creates a new one.
  void simpleSnackbar(String msg) {
    ScaffoldMessenger.of(_navigatorKey.currentContext!).clearSnackBars();
    ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  /// Closes all snackbars and creates a new one with a button.
  void snackbarWithAction(String msg, String actionLabel, Function callback) {
    ScaffoldMessenger.of(_navigatorKey.currentContext!).clearSnackBars();
    ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(SnackBar(
      content: Text(msg),
      action: SnackBarAction(label: actionLabel, onPressed: () => callback()),
    ));
  }
}
