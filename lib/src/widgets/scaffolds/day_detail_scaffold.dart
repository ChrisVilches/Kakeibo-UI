import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/controllers/navigation_controller.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/decoration/padding_top_widget.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/widgets/day_detail/expenses_tab/expenses_management_widget.dart';
import 'package:kakeibo_ui/src/widgets/day_detail/summary_tab/day_detail_form_widget.dart';
import 'package:kakeibo_ui/src/widgets/day_detail/summary_tab/day_detail_summary_widget.dart';
import 'package:provider/provider.dart';

class DayDetailScaffold extends StatelessWidget {
  const DayDetailScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Period period = Provider.of<NavigationController>(context).currentPeriod!;
    Day day = Provider.of<NavigationController>(context).currentDay!;

    final String title = "${period.name} - ${DateUtil.formatDateSlash(day.dayDate)}";

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
              SingleChildScrollView(
                child: PaddingTop(
                  child: Column(
                    children: [
                      const DayDetailSummaryWidget(),
                      DayDetailFormWidget(period: period, day: day)
                    ],
                  ),
                ),
              ),
              // TODO: Scrollable part should be the list only, but it's OK this way (decent).
              const SingleChildScrollView(child: ExpensesManagementWidget()),
            ],
          ),
        ),
      ),
    );
  }
}
