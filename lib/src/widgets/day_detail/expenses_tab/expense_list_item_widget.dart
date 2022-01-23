import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/models/navigation_store.dart';
import 'package:kakeibo_ui/src/decoration/card_with_float_right_item_widget.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:kakeibo_ui/src/services/snackbar_service.dart';
import 'package:kakeibo_ui/src/models/expense.dart';
import 'package:kakeibo_ui/src/models/extensions/expense_queries.dart';
import 'package:kakeibo_ui/src/widgets/misc/signed_amount_widget.dart';
import 'package:provider/provider.dart';

// TODO: Remove expense -> Go back in view history -> Press "undo" because snackbar is still there (error)
class ExpenseListItemWidget extends StatelessWidget {
  final Expense expense;
  final Function(Expense) undoCallback;

  const ExpenseListItemWidget(this.expense, {Key? key, required this.undoCallback})
      : super(key: key);

  // TODO: Has some glitches and bugs.
  /* [ERROR:flutter/lib/ui/ui_dart_state.cc(209)] Unhandled Exception: Looking up a deactivated widget's ancestor is unsafe.
     At this point the state of the widget's element tree is no longer stable.
     To safely refer to a widget's ancestor in its dispose() method, save a reference to the ancestor by calling dependOnInheritedWidgetOfExactType() in the widget's didChangeDependencies() method.
  */
  Future<void> _removeExpense(BuildContext context, Expense expense) async {
    final nav = Provider.of<NavigationStore>(context, listen: false);

    nav.expenses.removeWhere((e) => e.id == expense.id);
    await expense.destroy();
    await nav.reloadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = expense.label.isEmpty;
    final fontStyle = isEmpty ? FontStyle.italic : FontStyle.normal;
    final title = Text(
      isEmpty ? 'No label' : expense.label,
      style: TextStyle(fontStyle: fontStyle),
    );

    final listTile = CardWithFloatRightItemWidget(
      icon: const Icon(Icons.arrow_downward),
      label: title,
      rightWidget: SignedAmountWidget(-expense.cost),
    );

    return Dismissible(
      key: Key(expense.id.toString()),
      onDismissed: (direction) async {
        debugPrint("Dismissed");
        await _removeExpense(context, expense);
        serviceLocator
            .get<SnackbarService>()
            .snackbarWithAction("Removed", "UNDO", () => undoCallback(expense));
      },
      confirmDismiss: (DismissDirection direction) async {
        return true;
      },
      child: listTile,
    );
  }
}
