import 'package:flutter/material.dart';

class Helpers {
  /// Closes all snackbars and creates a new one.
  static void simpleSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }
}
