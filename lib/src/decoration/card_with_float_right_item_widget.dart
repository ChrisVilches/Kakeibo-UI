import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/extra_padding_widget.dart';

class CardWithFloatRightItemWidget extends StatelessWidget {
  final Icon icon;
  final Widget label;
  final Widget rightWidget;

  const CardWithFloatRightItemWidget(
      {Key? key, required this.icon, required this.label, required this.rightWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExtraPadding(
        child: Row(
          children: <Widget>[
            Padding(
              child: SizedBox(
                width: 20,
                child: icon,
              ),
              padding: const EdgeInsets.only(right: 20),
            ),
            Expanded(
              flex: 1,
              child: label,
            ),
            SizedBox(
              width: 120,
              child: Container(
                child: rightWidget,
                alignment: Alignment.centerRight,
              ),
            )
          ],
        ),
      ),
    );
  }
}
