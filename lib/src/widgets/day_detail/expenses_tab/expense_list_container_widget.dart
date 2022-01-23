import 'package:flutter/widgets.dart';
import 'package:kakeibo_ui/src/models/expense.dart';
import 'package:kakeibo_ui/src/models/extensions/expense_queries.dart';
import 'package:kakeibo_ui/src/models/navigation_store.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:kakeibo_ui/src/services/snackbar_service.dart';
import 'package:kakeibo_ui/src/widgets/day_detail/expenses_tab/expense_list_item_widget.dart';
import 'package:provider/provider.dart';

class ExpenseListContainerWidget extends StatelessWidget {
  const ExpenseListContainerWidget({Key? key}) : super(key: key);

  Future<void> _undoRemoveExpense(BuildContext context, Expense expense) async {
    await expense.restore();

    try {
      await Provider.of<NavigationStore>(context, listen: false).reloadExpenses();
    } catch (e) {
      debugPrint('''Expense was restored, however the period data could not be reloaded,
due to issue with context (this happens when the UNDO button is clicked
outside the expense management screen). Exception message: $e''');
    }
  }

  Widget listItem(BuildContext context, Expense expense) => ExpenseListItemWidget(
        expense,
        undoCallback: (expense) async {
          _undoRemoveExpense(context, expense);
          serviceLocator.get<SnackbarService>().simpleSnackbar('Restored expense');
        },
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationStore>(
      builder: (context, nav, _) {
        return ListView.builder(
          shrinkWrap: true,
          restorationId: 'ExpensesManagementWidget_ExpenseList',
          itemCount: nav.expenses.length,
          itemBuilder: (context, idx) => listItem(context, nav.expenses[idx]),
        );
      },
    );
  }
}
