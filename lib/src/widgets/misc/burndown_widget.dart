import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/format_util.dart';

class BurndownWidget extends StatelessWidget {
  final int value;

  const BurndownWidget(this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      FormatUtil.formatNumberCurrency(value),
      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
    );
  }
}
