import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/decoration/padding_top_widget.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/period_list/widgets/day_detail_summary_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/expenses_management_widget.dart';
import 'day_detail_form_widget.dart';

class DayDetailWidget extends StatefulWidget {
  final int burndown;
  final int? remaining;
  final int? projection;
  final int? diff;
  final Period period;
  final Day day;

  const DayDetailWidget(
      {Key? key,
      required this.period,
      required this.day,
      required this.burndown,
      this.remaining,
      this.projection,
      this.diff})
      : super(key: key);

  @override
  DayDetailState createState() => DayDetailState();
}

class DayDetailState extends State<DayDetailWidget> {
  @override
  Widget build(BuildContext context) {
    final String title = "${widget.period.name} - ${DateUtil.formatDateSlash(widget.day.dayDate)}";

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: const TabBar(tabs: [
            Tab(
              text: "Summary",
              icon: Icon(Icons.summarize),
            ),
            Tab(
              text: "Expenses",
              icon: Icon(Icons.receipt_long),
            ),
          ]),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: TabBarView(
            children: [
              PaddingTop(
                child: Column(
                  children: [
                    DayDetailSummaryWidget(
                        day: widget.day,
                        remaining: widget.remaining,
                        burndown: widget.burndown,
                        projection: widget.projection,
                        diff: widget.diff),
                    DayDetailFormWidget(period: widget.period, day: widget.day)
                  ],
                ),
              ),
              ExpensesManagementWidget(day: widget.day, period: widget.period),
            ],
          ),
        ),
      ),
    );
  }
}
