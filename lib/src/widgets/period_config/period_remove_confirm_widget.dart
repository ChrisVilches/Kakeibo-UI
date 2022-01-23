import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/models/extensions/period_queries.dart';
import 'package:kakeibo_ui/src/models/period.dart';

class PeriodRemoveConfirmWidget extends StatelessWidget {
  final Period period;
  final void Function(Period)? afterRemoveSuccess;

  const PeriodRemoveConfirmWidget({Key? key, required this.period, this.afterRemoveSuccess})
      : super(key: key);

  void _confirmHandler(BuildContext context) async {
    try {
      Period deletedPeriod = await period.destroy();
      afterRemoveSuccess?.call(deletedPeriod);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text('Delete'),
      style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.red)),
      onPressed: () => _confirmHandler(context),
    );

    Widget cancelButton = TextButton(
      child: const Text('Cancel'),
      style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.grey)),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    return AlertDialog(
      title: const Text('Delete period?'),
      content:
          const Text('Are you sure you want to remove this period? This action cannot be undone.'),
      actions: [okButton, cancelButton],
    );
  }
}
