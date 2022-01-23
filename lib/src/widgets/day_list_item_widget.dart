import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/controllers/navigation_controller.dart';
import 'package:kakeibo_ui/src/decoration/card_with_float_right_item_widget.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/decoration/format_util.dart';
import 'package:kakeibo_ui/src/models/day_data.dart';
import 'package:kakeibo_ui/src/widgets/misc/projection_widget.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/widgets/misc/memo_widget.dart';
import 'package:kakeibo_ui/src/widgets/misc/signed_amount_widget.dart';
import 'package:kakeibo_ui/src/widgets/scaffolds/day_detail_scaffold.dart';
import 'package:provider/provider.dart';

class DayListItemWidget extends StatelessWidget {
  final Function dayDetailModalClosedCallback;
  final Day day;

  const DayListItemWidget({Key? key, required this.day, required this.dayDetailModalClosedCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationController>(context);
    DayData dayData = nav.dayDataForDay(day);

    var icon = Icon(Icons.check_rounded,
        color: day.budget == null ? Colors.grey : Colors.green, size: 20.0);

    final columnChildren = <Widget>[];
    int totalExpense = day.totalExpense();

    if (day.budget == null) {
      columnChildren.add(ProjectionWidget(dayData.projection));
    } else {
      columnChildren.add(Text(FormatUtil.formatNumberCurrency(day.budget),
          style: const TextStyle(fontWeight: FontWeight.bold)));
    }

    if (dayData.diff != null) {
      columnChildren.add(const SizedBox(height: 5));
      columnChildren.add(SignedAmountWidget(dayData.diff));
    }

    if (totalExpense > 0) {
      columnChildren.add(const SizedBox(height: 5));

      // TODO: Add icon Icon(Icons.receipt_long, size: 15, color: Colors.grey) to the left.
      columnChildren.add(
        Text(
          FormatUtil.formatNumberCurrency(-day.totalExpense()),
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    Widget card = CardWithFloatRightItemWidget(
      icon: icon,
      label: Column(
        children: <Widget>[
          Text(DateUtil.formatDate(day.dayDate)),
          const SizedBox(height: 5),
          day.memo.isEmpty ? Container() : MemoWidget(day.memo),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      rightWidget: Column(
        children: columnChildren,
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );

    return InkWell(
      onTap: () async {
        Provider.of<NavigationController>(context, listen: false).setCurrentDay(day);

        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) {
                  return const DayDetailScaffold();
                },
                fullscreenDialog: true,
              ),
            )
            .then((_) => dayDetailModalClosedCallback);
      },
      child: card,
    );
  }
}
