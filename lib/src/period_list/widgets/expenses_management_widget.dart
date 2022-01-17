import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakeibo_ui/src/decoration/extra_padding_widget.dart';
import 'package:kakeibo_ui/src/decoration/form_validators.dart';
import 'package:kakeibo_ui/src/decoration/helpers.dart';
import 'package:kakeibo_ui/src/decoration/padding_bottom_widget.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/expense.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/period_list/widgets/expense_list_item_widget.dart';
import 'package:kakeibo_ui/src/services/graphql_services.dart';
import 'package:kakeibo_ui/src/services/locator.dart';

class ExpensesManagementWidget extends StatefulWidget {
  final Period period;
  final Day day;

  const ExpensesManagementWidget({
    Key? key,
    required this.period,
    required this.day,
  }) : super(key: key);

  @override
  ExpensesManagementState createState() => ExpensesManagementState();
}

class ExpensesManagementState extends State<ExpensesManagementWidget> {
  List<Expense> _expenses = [];

  final _formKey = GlobalKey<FormState>();
  String _selectedLabel = "";
  int _selectedCost = 0;

  ExpensesManagementState();

  @override
  void initState() {
    super.initState();
    _expenses = widget.day.expenses;
  }

  // TODO: Deletion doesn't work properly. Sometimes I get the "dismissed element is part of tree"
  //       But anyway, I have to modify a lot of things, not just that (e.g. update all views when a change happens,
  //       without having to restart the app).
  Widget listItem(BuildContext context, int index) {
    Expense expense = _expenses[index];
    return ExpenseListItemWidget(expense,
        removeCallback: () =>
            {_expenses.removeWhere((e) => e.id == expense.id)},
        readdCallback: () => {
              _executeCreateExpense(
                  expense.label ?? '', expense.cost, "Added again")
            });
  }

  void _executeCreateExpense(
      String label, int cost, String successMessage) async {
    Day updatedDay = await serviceLocator
        .get<GraphQLServices>()
        .createExpense(widget.period, widget.day, label, cost);

    Helpers.simpleSnackbar(context, successMessage);

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

    Widget costInput = TextFormField(
        onChanged: (text) => {
              setState(() {
                _selectedCost = int.parse(text);
              })
            },
        keyboardType: TextInputType.number,
        // TODO: Use my custom "DigitsOnlyInputWidget" widget?
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: FormValidators.amountValidator,
        decoration: const InputDecoration(labelText: 'Cost'));

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
