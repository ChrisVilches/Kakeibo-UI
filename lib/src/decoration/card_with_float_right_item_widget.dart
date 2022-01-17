import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/extra_padding_widget.dart';

// TODO: Doesn't look perfect when the screen is small (e.g. text should use the pretty overflow).
class CardWithFloatRightItemWidget extends StatelessWidget {
  final Icon icon;
  final Widget label;
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
            label,
            const Spacer(),
            rightWidget,
          ],
        ),
      ),
    );
  }
}
