import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/format_util.dart';

class DayDetailWidget extends StatelessWidget {
  final int burndown;
  final int? remaining;
  final int? projection;
  final int? diff;

  const DayDetailWidget(
      {Key? key,
      required this.burndown,
      this.remaining,
      this.projection,
      this.diff})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Day")),
        body: Column(children: [
          Text(FormatUtil.formatNumberCurrency(remaining)),
          Text(
            FormatUtil.formatNumberCurrency(burndown),
            style: const TextStyle(color: Colors.grey),
          ),
          Text(FormatUtil.formatNumberCurrency(projection),
              style: const TextStyle(color: Colors.green)),
        ]));
  }
}
