import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/card_with_float_right_item_widget.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/decoration/extra_padding_widget.dart';
import 'package:kakeibo_ui/src/decoration/form_validators.dart';
import 'package:kakeibo_ui/src/decoration/format_util.dart';
import 'package:kakeibo_ui/src/decoration/padding_bottom_widget.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/period_list/widgets/burndown_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/signed_amount_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/expenses_management_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/projection_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/remaining_budget_widget.dart';
import 'package:kakeibo_ui/src/services/graphql_services.dart';
import 'package:kakeibo_ui/src/services/locator.dart';

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
  final _budgetFormKey = GlobalKey<FormState>();
  String _selectedBudget = "";
  String _selectedMemo = "";

  @override
  void initState() {
    super.initState();
    _selectedBudget =
        widget.day.budget == null ? "" : widget.day.budget.toString();
    _selectedMemo = widget.day.memo;
  }

  void _executeSetDayBudget() async {
    await serviceLocator.get<GraphQLServices>().upsertDay(
        widget.period, widget.day, int.parse(_selectedBudget), _selectedMemo);

    // TODO: Use the custom helper I created?
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Updated'),
    ));
  }

  void _submitForm() {
    if (_budgetFormKey.currentState!.validate()) {
      _executeSetDayBudget();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget budgetInput = TextFormField(
        initialValue: _selectedBudget,
        onChanged: (text) => {
              setState(() {
                _selectedBudget = text;
              })
            },
        validator: FormValidators.amountValidator,
        decoration: const InputDecoration(
            labelText: 'Amount remaining in your account'));

    Widget memoInput = TextFormField(
        initialValue: _selectedMemo,
        onChanged: (text) => {
              setState(() {
                _selectedMemo = text;
              })
            },
        decoration: const InputDecoration(labelText: 'Memo'));

    Widget submitButton = ElevatedButton.icon(
      onPressed: _submitForm,
      icon: const Icon(Icons.update),
      label: const Text('Update'),
    );

    var remainingCard = CardWithFloatRightItemWidget(
      icon: const Icon(Icons.attach_money_rounded),
      label: "Remaining cash",
      rightWidget: RemainingBudgetWidget(widget.remaining),
    );

    var burndownCard = CardWithFloatRightItemWidget(
      icon: const Icon(Icons.trending_down),
      label: "Burndown",
      rightWidget: BurndownWidget(widget.burndown),
    );

    var projectionCard = CardWithFloatRightItemWidget(
      icon: const Icon(Icons.waterfall_chart),
      label: "Projection",
      rightWidget: ProjectionWidget(widget.projection),
    );

    var diffCard = CardWithFloatRightItemWidget(
      icon: const Icon(Icons.exposure_outlined),
      label: "Difference",
      rightWidget: SignedAmountWidget(widget.diff),
    );

    final summary = Column(
      children: [
        widget.day.budget == null ? Container() : remainingCard,
        burndownCard,
        widget.day.budget == null ? projectionCard : Container(),
        diffCard,
        Form(
          key: _budgetFormKey,
          child: ExtraPadding(
            child: Column(
              children: [
                PaddingBottom(
                  child: Column(
                    children: [budgetInput, memoInput],
                  ),
                ),
                submitButton
              ],
            ),
          ),
        ),
      ],
    );

    final String title =
        "${widget.period.name} - ${DateUtil.formatDate(widget.day.dayDate)}";

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          // TODO: This bottom doesn't work (it gets rendered at the top).
          bottom: const TabBar(tabs: [
            Tab(
              text: "Summary",
              icon: Icon(Icons.summarize),
            ),
            Tab(
              text: "Expenses",
              icon: Icon(Icons.attach_money),
            ),
          ]),
        ),
        body: SizedBox(
          //Add this to give height
          height: MediaQuery.of(context).size.height,
          child: TabBarView(children: [
            ExtraPadding(
              child: summary,
            ),
            ExtraPadding(
              child: ExpensesManagementWidget(
                  day: widget.day, period: widget.period),
            ),
          ]),
        ),
      ),
    );
  }
}
