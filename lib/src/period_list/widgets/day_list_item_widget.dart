import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/decoration/format_util.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/period_list/widgets/day_detail_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/diff_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/remaining_budget_widget.dart';

class DayListItemWidget extends StatelessWidget {
  Day day;
  Period period;
  int burndown;
  int? diff;
  int? remaining;
  int projection;

  DayListItemWidget(
      {required this.day,
      required this.period,
      required this.burndown,
      this.diff,
      this.remaining,
      required this.projection});

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(20),
            child: const Icon(Icons.view_day, color: Colors.pink, size: 24.0),
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
          // ProjectionWidget(projection(index)),
          DiffWidget(diff),
          // BurndownWidget(burndownBudget(index)),
          Text(
              "Expense: ${FormatUtil.formatNumberCurrency(day.totalExpense())}")
        ],
      ),
    );

    return InkWell(
      onTap: () {
        Navigator.push(
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
      },
      child: card,
    );
  }
}
