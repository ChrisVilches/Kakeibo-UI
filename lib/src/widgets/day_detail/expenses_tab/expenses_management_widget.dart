import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/extra_padding_widget.dart';
import 'package:kakeibo_ui/src/models/extensions/period_queries.dart';
import 'package:kakeibo_ui/src/services/snackbar_service.dart';
import 'package:kakeibo_ui/src/decoration/padding_bottom_widget.dart';
import 'package:kakeibo_ui/src/widgets/misc/digits_only_input_widget.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/expense.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/widgets/day_detail/expenses_tab/expense_list_item_widget.dart';
import 'package:kakeibo_ui/src/models/extensions/day_queries.dart';
import 'package:kakeibo_ui/src/models/extensions/expense_queries.dart';

class ExpensesManagementWidget extends StatefulWidget {
  final Period period;
  final Day day;

  const ExpensesManagementWidget({
    Key? key,
    required this.period,
    required this.day,
  }) : super(key: key);

  @override
  _ExpensesManagementState createState() => _ExpensesManagementState();
}

class _ExpensesManagementState extends State<ExpensesManagementWidget> {
  List<Expense> _expenses = [];

  final _formKey = GlobalKey<FormState>();
  String _selectedLabel = "";
  int _selectedCost = 0;

  @override
  void initState() {
    super.initState();
    _expenses = widget.day.expenses;
  }

  Future<void> _loadExpenses() async {
    Period period = await PeriodQueries.fetchOne(widget.period.id!);

    // TODO: Not sure about this way of managing state. Should update the parent and then
    //       make the changes propagate to this widget. Maybe.
    setState(() {
      widget.period.days.clear();
      for (Day day in period.days) {
        widget.period.days.add(day);
      }
    });
  }

  // TODO: Deletion doesn't work properly. Sometimes I get the "dismissed element is part of tree"
  //       But anyway, I have to modify a lot of things, not just that (e.g. update all views when a change happens,
  //       without having to restart the app).
  //       I have to test all of this, specially since I introduced providers, data might get messed up.
  //       Expense deletion also doesn't work I think (doesn't update the list I think, not sure though.)
  Widget listItem(BuildContext context, int index) {
    Expense expense = _expenses[index];
    return ExpenseListItemWidget(expense,
        removeCallback: () => {_expenses.removeWhere((e) => e.id == expense.id)},
        readdCallback: () => {_undoDestroyExpense(expense)});
  }

  // TODO: Discard works, but screen refresh is really bad. I have to think of a better way of
  //       refreshing the screens and managing data. Use some provider magic.
  //       Maybe create a class that has like a "navigation state" and it has a lot of methods
  //       and attributes to keep track of period/day/expenses and has methods to load different ones
  //       (for when changing to a different screen) or refresh.
  //       And let's also get the loading/not-loading state from there to render it in all widgets.
  void _undoDestroyExpense(Expense expense) async {
    await expense.destroy(undo: true);
    SnackbarService.simpleSnackbar(context, "Restored expense");
    await _loadExpenses();
  }

  void _executeCreateExpense(String label, int cost, String successMessage) async {
    Day updatedDay = await widget.day.createExpense(widget.period, label, cost);

    SnackbarService.simpleSnackbar(context, successMessage);

    setState(() {
      _expenses = updatedDay.expenses;
      _formKey.currentState?.reset();
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _executeCreateExpense(_selectedLabel, _selectedCost, "Created");
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget expenseList = ListView.builder(
      shrinkWrap: true,
      restorationId: 'ExpensesManagementWidget_ExpenseList',
      itemCount: _expenses.length,
      itemBuilder: listItem,
    );

    Widget labelInput = TextFormField(
        onChanged: (text) => {
              setState(() {
                _selectedLabel = text;
              })
            },
        decoration: const InputDecoration(labelText: 'Label'));

    Widget costInput = DigitsOnlyInputWidget('Cost',
        onChanged: (text) => {
              setState(
                () {
                  _selectedCost = int.parse(text ?? '');
                },
              )
            });

    Widget submitButton = ElevatedButton.icon(
      onPressed: _submitForm,
      icon: const Icon(Icons.add),
      label: const Text('Add expense'),
    );

    final form = Form(
      key: _formKey,
      child: ExtraPadding(
        child: Column(
          children: [
            PaddingBottom(
              child: Column(
                children: [labelInput, costInput],
              ),
            ),
            submitButton
          ],
        ),
      ),
    );

    final column = Column(
      children: [
        form,
        expenseList,
      ],
    );

    return column;
  }
}
