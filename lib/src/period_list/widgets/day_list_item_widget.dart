import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/card_with_float_right_item_widget.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/decoration/format_util.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/period_list/widgets/day_detail_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/memo_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/projection_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/signed_amount_widget.dart';

class DayListItemWidget extends StatelessWidget {
  final Day day;
  final Period period;
  final int burndown;
  final int? diff;
  final int? remaining;
  final int? projection;
  final Function dayDetailModalClosedCallback;

  const DayListItemWidget(
      {Key? key,
      required this.day,
      required this.period,
      required this.burndown,
      this.diff,
      this.remaining,
      this.projection,
      required this.dayDetailModalClosedCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var icon = Icon(Icons.check_rounded,
        color: day.budget == null ? Colors.grey : Colors.green, size: 20.0);

    List<Widget> columnChildren = [];
    int totalExpense = day.totalExpense();

    if (day.budget == null) {
      columnChildren.add(ProjectionWidget(projection));
    } else {
      columnChildren.add(Text(FormatUtil.formatNumberCurrency(day.budget),
          style: const TextStyle(fontWeight: FontWeight.bold)));
    }

    if (diff != null) {
      columnChildren.add(const SizedBox(height: 5));
      columnChildren.add(SignedAmountWidget(diff));
    }

    if (totalExpense > 0) {
      columnChildren.add(const SizedBox(height: 5));
      columnChildren.add(
        Text(
            "${day.expenses.length} expenses (${FormatUtil.formatNumberCurrency(day.totalExpense())})",
            style: const TextStyle(color: Colors.grey)),
      );
    }

    Widget card = CardWithFloatRightItemWidget(
        icon: icon,
        label: Column(
          children: [
            Text(DateUtil.formatDate(day.dayDate)),
            const SizedBox(height: 5),
            day.memo.isEmpty ? Container() : MemoWidget(day.memo),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        rightWidget: Column(
          children: columnChildren,
          crossAxisAlignment: CrossAxisAlignment.end,
        ));

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return DayDetailWidget(
                burndown: burndown,
                diff: diff,
                remaining: remaining,
                projection: projection,
                period: period,
                day: day,
              );
            },
            fullscreenDialog: true,
          ),
        );

        dayDetailModalClosedCallback();
      },
      child: card,
    );
  }
}
