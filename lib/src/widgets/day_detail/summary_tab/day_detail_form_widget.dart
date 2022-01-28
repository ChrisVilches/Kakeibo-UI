import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/controllers/day_detail_form_controller.dart';
import 'package:kakeibo_ui/src/decoration/extra_padding_widget.dart';
import 'package:kakeibo_ui/src/decoration/padding_bottom_widget.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/navigation_store.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:kakeibo_ui/src/services/snackbar_service.dart';
import 'package:kakeibo_ui/src/widgets/misc/digits_only_input_widget.dart';
import 'package:provider/provider.dart';

class DayDetailFormWidget extends StatelessWidget {
  final Period period;
  final Day day;

  const DayDetailFormWidget({required this.period, required this.day, Key? key}) : super(key: key);

  void _submitForm(BuildContext context) async {
    if (await Provider.of<DayDetailFormController>(context, listen: false).submitForm()) {
      Provider.of<NavigationStore>(context, listen: false).reloadPeriod();
      serviceLocator.get<SnackbarService>().simpleSnackbar('Updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DayDetailFormController>(
      create: (_) => DayDetailFormController(period: period, day: day),
      builder: (context, _) {
        final ctrl = Provider.of<DayDetailFormController>(context, listen: false);

        final budgetInput = DigitsOnlyInputWidget(
          'Amount remaining in your account',
          initialValue: ctrl.selectedBudget,
          required: false,
          onChanged: (text) => ctrl.onChangeBudget(text ?? ''),
        );

        final memoInput = TextFormField(
          initialValue: ctrl.selectedMemo,
          onChanged: ctrl.onChangeMemo,
          decoration: const InputDecoration(labelText: 'Memo'),
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 10,
        );

        final submitButton = Consumer<DayDetailFormController>(
          builder: (context, ctrl, _) => ElevatedButton.icon(
            onPressed: ctrl.canSubmitForm() ? () => _submitForm(context) : null,
            icon: const Icon(Icons.update),
            label: const Text('Update'),
          ),
        );

        return Form(
          key: ctrl.formKey,
          child: ExtraPadding(
            child: Column(
              children: [
                PaddingBottom(
                  child: Column(
                    children: [
                      budgetInput,
                      memoInput,
                    ],
                  ),
                ),
                submitButton
              ],
            ),
          ),
        );
      },
    );
  }
}
