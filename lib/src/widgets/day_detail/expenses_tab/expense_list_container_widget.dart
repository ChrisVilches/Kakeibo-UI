import 'package:flutter/widgets.dart';
import 'package:kakeibo_ui/src/controllers/navigation_controller.dart';
import 'package:kakeibo_ui/src/models/expense.dart';
import 'package:kakeibo_ui/src/services/snackbar_service.dart';
import 'package:kakeibo_ui/src/widgets/day_detail/expenses_tab/expense_list_item_widget.dart';
import 'package:provider/provider.dart';

// TODO: Glitchy (I don't know the exact way to reproduce it, but delete/create/undo a lot and you'll see it)
//       The good thing is that the data comes exclusively from the NavigationController and this is the only
//       data store provider (or controller) present. This means that the problem could be fixed
//       in the creation form (because it modifies the data in NavigationController). However
//       one exception to this is that the dismissal thingie actually removes the item from the list
//       without modifying data in a controller or anything like that.
//
//      Also for example not reflecting in the period detail once I exit the day detail view.
//      (for both creation and delete)

class ExpenseListContainerWidget extends StatelessWidget {
  const ExpenseListContainerWidget({Key? key}) : super(key: key);

  Widget listItem(BuildContext context, Expense expense) => ExpenseListItemWidget(
        expense,
        undoCallback: (expense) async {
          await Provider.of<NavigationController>(context, listen: false)
              .undoRemoveExpense(expense);
          SnackbarService.simpleSnackbar(context, "Restored expense");
        },
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationController>(
      builder: (context, data, _) {
        return ListView.builder(
          shrinkWrap: true,
          restorationId: 'ExpensesManagementWidget_ExpenseList',
          itemCount: data.expenses.length,
          itemBuilder: (context, idx) => listItem(context, data.expenses[idx]),
        );
      },
    );
  }
}
