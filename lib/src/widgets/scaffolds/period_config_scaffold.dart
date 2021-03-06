import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/controllers/period_config_controller.dart';
import 'package:kakeibo_ui/src/decoration/extra_padding_widget.dart';
import 'package:kakeibo_ui/src/decoration/form_validators.dart';
import 'package:kakeibo_ui/src/decoration/padding_bottom_widget.dart';
import 'package:kakeibo_ui/src/models/navigation_store.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:kakeibo_ui/src/services/snackbar_service.dart';
import 'package:kakeibo_ui/src/widgets/misc/digits_only_input_widget.dart';
import 'package:kakeibo_ui/src/widgets/period_config/period_remove_confirm_widget.dart';
import 'package:provider/provider.dart';

class PeriodConfigScaffold extends StatelessWidget {
  const PeriodConfigScaffold({Key? key}) : super(key: key);

  void _removePeriod(BuildContext context, Period period) {
    showDialog<PeriodRemoveConfirmWidget>(
      context: context,
      builder: (BuildContext context) {
        return PeriodRemoveConfirmWidget(
          period: period,
          afterRemoveSuccess: (Period deletedPeriod) {
            serviceLocator.get<SnackbarService>().simpleSnackbar('Removed: ${deletedPeriod.name}');
            Navigator.popUntil(context, ModalRoute.withName('/'));
            Provider.of<NavigationStore>(context, listen: false).clearData();
          },
        );
      },
    );
  }

  Widget form(BuildContext context) {
    final ctrl = Provider.of<PeriodConfigController>(context);

    return Form(
      key: ctrl.formKey,
      child: ExtraPadding(
        child: Column(
          children: [
            PaddingBottom(
              child: Column(
                children: [
                  TextFormField(
                    onChanged: ctrl.onChangedName,
                    initialValue: ctrl.nameValue,
                    validator: FormValidators.requiredField,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  DigitsOnlyInputWidget(
                    "This month's salary",
                    onChanged: ctrl.onChangedSalary,
                    initialValue: ctrl.salaryValue,
                  ),
                  DigitsOnlyInputWidget(
                    'Initial money',
                    onChanged: ctrl.onChangedInitialMoney,
                    initialValue: ctrl.initialMoneyValue,
                  ),
                  DigitsOnlyInputWidget(
                    'Savings Percentage (%)',
                    onChanged: ctrl.onChangedSavingsPercentage,
                    initialValue: ctrl.savingsPercentageValue,
                  ),
                  DigitsOnlyInputWidget(
                    'Daily Expenses',
                    onChanged: ctrl.onChangedDailyExpenses,
                    initialValue: ctrl.dailyExpensesValue,
                  ),
                  DigitsOnlyInputWidget(
                    'Total fixed expenses',
                    onChanged: ctrl.onChangedTotalFixedExpenses,
                    initialValue: ctrl.totalFixedExpenses,
                    hintText: 'Rent, bills, etc...',
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: ctrl.canSubmitForm()
                  ? () async {
                      if (await ctrl.executePeriodUpdate()) {
                        serviceLocator
                            .get<SnackbarService>()
                            .simpleSnackbar('Updated period information.');
                        Navigator.of(context).pop();
                        Provider.of<NavigationStore>(context, listen: false).reloadPeriod();
                      }
                    }
                  : null,
              icon: const Icon(Icons.add),
              label: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Period period = Provider.of<NavigationStore>(context, listen: false).currentPeriod!;

    final formWithState = ChangeNotifierProvider<PeriodConfigController>(
      create: (_) => PeriodConfigController(period),
      builder: (BuildContext context, _) => form(context),
    );

    Widget buttonRow = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: FloatingActionButton(
            onPressed: () => _removePeriod(context, period),
            backgroundColor: Theme.of(context).buttonTheme.colorScheme!.error,
            foregroundColor: Colors.white,
            tooltip: 'Delete period',
            child: const Icon(Icons.delete),
          ),
        )
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text('${period.name} - Settings')),
      body: SingleChildScrollView(child: formWithState),
      floatingActionButton: buttonRow,
    );
  }
}
