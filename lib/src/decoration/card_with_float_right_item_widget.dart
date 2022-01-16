import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/extra_padding_widget.dart';

class CardWithFloatRightItemWidget extends StatelessWidget {
  final Icon icon;
  final String label;
  final Widget rightWidget;

  const CardWithFloatRightItemWidget(
      {Key? key,
      required this.icon,
      required this.label,
      required this.rightWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExtraPadding(
        child: Row(
          children: <Widget>[
            icon,
            const SizedBox(width: 16),
            Text(label),
            const Spacer(),
            rightWidget,
          ],
        ),
      ),
    );
  }
}
