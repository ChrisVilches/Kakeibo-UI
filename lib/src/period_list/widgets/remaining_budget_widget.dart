import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/format_util.dart';

class RemainingBudgetWidget extends StatelessWidget {
  final int? value;

  const RemainingBudgetWidget(this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (value == null) return const Text('');
    return Text(
      FormatUtil.formatNumberCurrency(value),
      style: const TextStyle(color: Colors.blue),
    );
  }
}
