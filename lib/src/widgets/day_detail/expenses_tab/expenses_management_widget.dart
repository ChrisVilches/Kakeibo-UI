import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/widgets/day_detail/expenses_tab/expense_creation_form_widget.dart';
import 'package:kakeibo_ui/src/widgets/day_detail/expenses_tab/expense_list_container_widget.dart';

class ExpensesManagementWidget extends StatelessWidget {
  const ExpensesManagementWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ExpenseCreationFormWidget(),
        ExpenseListContainerWidget(),
      ],
    );
  }
}
