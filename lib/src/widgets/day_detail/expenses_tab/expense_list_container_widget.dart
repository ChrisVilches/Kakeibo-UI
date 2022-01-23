import 'package:flutter/widgets.dart';
import 'package:kakeibo_ui/src/models/navigation_store.dart';
import 'package:kakeibo_ui/src/models/expense.dart';
import 'package:kakeibo_ui/src/models/extensions/expense_queries.dart';
import 'package:kakeibo_ui/src/services/snackbar_service.dart';
import 'package:kakeibo_ui/src/widgets/day_detail/expenses_tab/expense_list_item_widget.dart';
import 'package:provider/provider.dart';

// TODO: Glitchy (I don't know the exact way to reproduce it, but delete/create/undo a lot and you'll see it)
//       The good thing is that the data comes exclusively from the NavigationStore and this is the only
//       data store provider (or controller) present. This means that the problem could be fixed
//       in the creation form (because it modifies the data in NavigationStore). However
//       one exception to this is that the dismissal thingie actually removes the item from the list
//       without modifying data in a controller or anything like that.
//
//      Also for example not reflecting in the period detail once I exit the day detail view.
//      (for both creation and delete)

class ExpenseListContainerWidget extends StatelessWidget {
  const ExpenseListContainerWidget({Key? key}) : super(key: key);

  Future<void> _undoRemoveExpense(BuildContext context, Expense expense) async {
    await expense.destroy(undo: true);
    await Provider.of<NavigationStore>(context, listen: false).reloadExpenses();
  }

  Widget listItem(BuildContext context, Expense expense) => ExpenseListItemWidget(
        expense,
        undoCallback: (expense) async {
          _undoRemoveExpense(context, expense);
          SnackbarService.simpleSnackbar(context, "Restored expense");
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
