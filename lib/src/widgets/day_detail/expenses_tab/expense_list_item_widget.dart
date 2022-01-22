import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/controllers/navigation_controller.dart';
import 'package:kakeibo_ui/src/decoration/card_with_float_right_item_widget.dart';
import 'package:kakeibo_ui/src/services/snackbar_service.dart';
import 'package:kakeibo_ui/src/models/expense.dart';
import 'package:kakeibo_ui/src/widgets/misc/signed_amount_widget.dart';
import 'package:provider/provider.dart';

class ExpenseListItemWidget extends StatelessWidget {
  final Expense expense;
  final Function(Expense) undoCallback;

  const ExpenseListItemWidget(this.expense, {Key? key, required this.undoCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = expense.label == null || expense.label!.isEmpty;
    final fontStyle = isEmpty ? FontStyle.italic : FontStyle.normal;
    final title = Text(
      isEmpty ? 'No label' : expense.label!,
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
        await Provider.of<NavigationController>(context, listen: false).removeExpense(expense);
        SnackbarService.snackbarWithAction(context, "Removed", "UNDO", () => undoCallback(expense));
      },
      confirmDismiss: (DismissDirection direction) async {
        return true;
      },
      child: listTile,
    );
  }
}
