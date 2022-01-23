import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/controllers/expenses_management_controller.dart';
import 'package:kakeibo_ui/src/models/navigation_store.dart';
import 'package:kakeibo_ui/src/decoration/extra_padding_widget.dart';
import 'package:kakeibo_ui/src/decoration/padding_bottom_widget.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:kakeibo_ui/src/services/snackbar_service.dart';
import 'package:kakeibo_ui/src/widgets/misc/digits_only_input_widget.dart';
import 'package:provider/provider.dart';

class ExpenseCreationFormWidget extends StatelessWidget {
  const ExpenseCreationFormWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expensesCtrl = ExpensesManagementController();
    final nav = Provider.of<NavigationStore>(context, listen: false);

    Widget labelInput = TextFormField(
      onChanged: expensesCtrl.onChangeLabel,
      decoration: const InputDecoration(labelText: 'Label'),
    );

    Widget costInput = DigitsOnlyInputWidget(
      'Cost',
      onChanged: (text) => expensesCtrl.onChangeCost(text ?? ''),
    );

    Widget submitButton = ElevatedButton.icon(
      onPressed: () async {
        if (await expensesCtrl.submitForm(
          period: nav.currentPeriod!,
          day: nav.currentDay!,
        )) {
          serviceLocator.get<SnackbarService>().simpleSnackbar("Created");

          nav.reloadPeriod();
          expensesCtrl.resetForm();
        }
      },
      icon: const Icon(Icons.add),
      label: const Text('Add expense'),
    );

    return Form(
      key: expensesCtrl.formKey,
      child: ExtraPadding(
        child: Column(
          children: [
            PaddingBottom(child: Column(children: [labelInput, costInput])),
            submitButton
          ],
        ),
      ),
    );
  }
}
