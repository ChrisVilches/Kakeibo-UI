import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/controllers/expenses_management_controller.dart';
import 'package:kakeibo_ui/src/controllers/navigation_controller.dart';
import 'package:kakeibo_ui/src/decoration/extra_padding_widget.dart';
import 'package:kakeibo_ui/src/services/snackbar_service.dart';
import 'package:kakeibo_ui/src/decoration/padding_bottom_widget.dart';
import 'package:kakeibo_ui/src/widgets/misc/digits_only_input_widget.dart';
import 'package:kakeibo_ui/src/models/expense.dart';
import 'package:kakeibo_ui/src/widgets/day_detail/expenses_tab/expense_list_item_widget.dart';
import 'package:provider/provider.dart';

class ExpensesManagementWidget extends StatefulWidget {
  const ExpensesManagementWidget({Key? key}) : super(key: key);

  @override
  _ExpensesManagementState createState() => _ExpensesManagementState();
}

class _ExpensesManagementState extends State<ExpensesManagementWidget> {
  final _expensesCtrl = ExpensesManagementController();

  Widget listItem(BuildContext context, Expense expense) {
    return ExpenseListItemWidget(expense, undoCallback: (expense) async {
      await Provider.of<NavigationController>(context, listen: false).undoRemoveExpense(expense);
      SnackbarService.simpleSnackbar(context, "Restored expense");
    });
  }

  @override
  Widget build(BuildContext context) {
    final navCtrl = Provider.of<NavigationController>(context, listen: false);

    Widget expenseList = Consumer<NavigationController>(builder: (context, data, _) {
      return ListView.builder(
        shrinkWrap: true,
        restorationId: 'ExpensesManagementWidget_ExpenseList',
        itemCount: data.expenses.length,
        itemBuilder: (context, idx) => listItem(context, navCtrl.expenses[idx]),
      );
    });

    Widget labelInput = TextFormField(
      onChanged: _expensesCtrl.onChangeLabel,
      decoration: const InputDecoration(labelText: 'Label'),
    );

    Widget costInput = DigitsOnlyInputWidget(
      'Cost',
      onChanged: (text) => _expensesCtrl.onChangeCost(text!),
    );

    Widget submitButton = ElevatedButton.icon(
      onPressed: () async {
        if (await _expensesCtrl.submitForm(
          period: navCtrl.currentPeriod!,
          day: navCtrl.currentDay!,
        )) {
          SnackbarService.simpleSnackbar(context, "Created");

          navCtrl.reloadExpenses();
          _expensesCtrl.resetForm();
        }
      },
      icon: const Icon(Icons.add),
      label: const Text('Add expense'),
    );

    final form = Form(
      key: _expensesCtrl.formKey,
      child: ExtraPadding(
        child: Column(
          children: [
            PaddingBottom(child: Column(children: [labelInput, costInput])),
            submitButton
          ],
        ),
      ),
    );

    final column = Column(children: [form, expenseList]);

    return column;
  }
}
