import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/format_util.dart';

class SignedAmountWidget extends StatelessWidget {
  final int? value;

  const SignedAmountWidget(this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (value == null) return const Text('');

    Color color = value! >= 0 ? Colors.blue : Colors.red;
    String sign = value! >= 0 ? '+' : '-';

    return Text(
      '$sign${FormatUtil.formatNumberCurrency(value!.abs())}',
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}
