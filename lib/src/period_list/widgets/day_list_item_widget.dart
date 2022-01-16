import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/decoration/format_util.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/period_list/widgets/day_detail_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/signed_amount_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/remaining_budget_widget.dart';

class DayListItemWidget extends StatelessWidget {
  final Day day;
  final Period period;
  final int burndown;
  final int? diff;
  final int? remaining;
  final int projection;
  final Function dayDetailModalClosedCallback;

  const DayListItemWidget(
      {Key? key,
      required this.day,
      required this.period,
      required this.burndown,
      this.diff,
      this.remaining,
      required this.dayDetailModalClosedCallback,
      required this.projection})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var icon = Icon(Icons.check_rounded,
        color: day.budget == null ? Colors.grey : Colors.green, size: 20.0);

    Widget card = Card(
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(20),
            child: icon,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(children: [
              Text(DateUtil.formatDate(day.dayDate)),
              Text(day.memo, style: const TextStyle(color: Colors.grey)),
            ]),
          ),
          Text(FormatUtil.formatNumberCurrency(day.budget)),
          RemainingBudgetWidget(remaining),
          SignedAmountWidget(diff),
          Text(
              "Expense: ${FormatUtil.formatNumberCurrency(day.totalExpense())}")
        ],
      ),
    );

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
