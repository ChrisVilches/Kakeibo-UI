import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/extra_padding_widget.dart';
import 'package:kakeibo_ui/src/decoration/form_validators.dart';
import 'package:kakeibo_ui/src/decoration/format_util.dart';
import 'package:kakeibo_ui/src/decoration/helpers.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/expense.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/period_list/widgets/burndown_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/diff_widget.dart';
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
  List<Expense> _expenses = [];

  final _budgetFormKey = GlobalKey<FormState>();
  final _expenseFormKey = GlobalKey<FormState>();
  String _selectedBudget = "";
  String _selectedMemo = "";
  String _selectedLabel = "";
  int _selectedCost = 0;

  DayDetailState() {}

  @override
  void initState() {
    super.initState();
    _expenses = widget.day.expenses;

    _selectedBudget =
        widget.day.budget == null ? "" : widget.day.budget.toString();
    _selectedMemo = widget.day.memo;
  }

  void _executeSetDayBudget() async {
    await serviceLocator.get<GraphQLServices>().upsertDay(
        widget.period, widget.day, int.parse(_selectedBudget), _selectedMemo);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Updated'),
    ));
  }

  void _executeCreateExpense() async {
    Day updatedDay = await serviceLocator.get<GraphQLServices>().createExpense(
        widget.period, widget.day, _selectedLabel, _selectedCost);

    Helpers.simpleSnackbar(context, "Created");

    setState(() {
      _expenses = updatedDay.expenses;
      _expenseFormKey.currentState?.reset();
    });
  }

  void _budgetSubmitForm() {
    if (_budgetFormKey.currentState!.validate()) {
      _executeSetDayBudget();
    }
  }

  void _expenseSubmitForm() {
    if (_expenseFormKey.currentState!.validate()) {
      _executeCreateExpense();
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

    Widget submitButton = ElevatedButton(
      onPressed: _budgetSubmitForm,
      child: const Text('Update'),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Day")),
      body: ExtraPadding(
        child: Column(
          children: [
            Text(FormatUtil.formatNumberCurrency(widget.remaining)),
            BurndownWidget(widget.burndown),
            RemainingBudgetWidget(widget.remaining),
            DiffWidget(widget.diff),
            ProjectionWidget(widget.projection),
            ExpensesManagementWidget(day: widget.day, period: widget.period),
            Form(
              key: _budgetFormKey,
              child: ExtraPadding(
                child: Column(
                  children: [budgetInput, memoInput, submitButton],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
