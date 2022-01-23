import 'package:flutter/material.dart';

class ConfigureReminderDialogWidget extends StatelessWidget {
  final Function onPressOk;

  const ConfigureReminderDialogWidget({Key? key, required this.onPressOk}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text("Configure"),
      onPressed: () {
        // Remove alert first.
        Navigator.of(context).pop();
        onPressOk();
      },
    );

    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.grey)),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    return AlertDialog(
      title: const Text("Please configure this period correctly"),
      content: const Text("It seems this period is missing some configurations. Configure now?"),
      actions: [cancelButton, okButton],
    );
  }
}
