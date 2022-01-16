import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/format_util.dart';
import 'package:kakeibo_ui/src/decoration/helpers.dart';
import 'package:kakeibo_ui/src/models/expense.dart';
import 'package:kakeibo_ui/src/services/graphql_services.dart';
import 'package:kakeibo_ui/src/services/locator.dart';

class ExpenseListItemWidget extends StatelessWidget {
  final Expense expense;
  final Function removeCallback;

  const ExpenseListItemWidget(
    this.expense,
    this.removeCallback, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      child: Row(
        children: <Widget>[
          Text(
              "${expense.label} ${FormatUtil.formatNumberCurrency(expense.cost)}"),
        ],
      ),
    );

    return Dismissible(
      key: Key(expense.id.toString()),
      onDismissed: (direction) {
        removeCallback();
        Helpers.simpleSnackbar(context, "Removed");
      },
      confirmDismiss: (DismissDirection direction) async {
        await serviceLocator.get<GraphQLServices>().destroyExpense(expense.id);
        return true;
      },
      child: card,
    );
  }
}
