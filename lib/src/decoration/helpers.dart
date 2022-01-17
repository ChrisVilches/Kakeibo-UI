import 'package:flutter/material.dart';

class Helpers {
  /// Closes all snackbars and creates a new one.
  static void simpleSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  /// Closes all snackbars and creates a new one with a button.
  static void snackbarWithAction(
      BuildContext context, String msg, String actionLabel, Function callback) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      action: SnackBarAction(label: actionLabel, onPressed: () => callback()),
    ));
  }
}
