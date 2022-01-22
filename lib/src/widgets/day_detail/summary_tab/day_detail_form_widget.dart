import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/controllers/navigation_controller.dart';
import 'package:kakeibo_ui/src/decoration/extra_padding_widget.dart';
import 'package:kakeibo_ui/src/services/snackbar_service.dart';
import 'package:kakeibo_ui/src/decoration/padding_bottom_widget.dart';
import 'package:kakeibo_ui/src/widgets/misc/digits_only_input_widget.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/models/extensions/period_queries.dart';
import 'package:provider/provider.dart';

// TODO: Can move some logic to a controller class (and make it stateless).

class DayDetailFormWidget extends StatefulWidget {
  final Period period;
  final Day day;

  const DayDetailFormWidget({required this.period, required this.day, Key? key}) : super(key: key);

  @override
  _DayDetailFormState createState() => _DayDetailFormState();
}

class _DayDetailFormState extends State<DayDetailFormWidget> {
  final _formKey = GlobalKey<FormState>();
  String _selectedBudget = "";
  String _selectedMemo = "";
  bool _formChanged = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedBudget = widget.day.budget == null ? "" : widget.day.budget.toString();
    _selectedMemo = widget.day.memo;
  }

  void _executeSetDayBudget() async {
    setState(() {
      _submitting = true;
    });

    await widget.period.upsertDay(
      Day(
          dayDate: widget.day.dayDate,
          memo: _selectedMemo,
          budget: _selectedBudget == "" ? null : int.parse(_selectedBudget)),
    );

    Provider.of<NavigationController>(context, listen: false).reloadPeriod();

    SnackbarService.simpleSnackbar(context, 'Updated');

    setState(() {
      _formChanged = false;
      _submitting = false;
    });
  }

  bool _canSubmitForm() {
    if (!_formChanged) return false;
    if (_submitting) return false;
    return true;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _executeSetDayBudget();
    }
  }

  Widget budgetInput() => DigitsOnlyInputWidget('Amount remaining in your account',
      initialValue: _selectedBudget,
      required: false,
      onChanged: (text) => {
            setState(() {
              _selectedBudget = text ?? '';
              _formChanged = true;
            })
          });

  Widget memoInput() => TextFormField(
      initialValue: _selectedMemo,
      onChanged: (text) => {
            setState(() {
              _selectedMemo = text;
              _formChanged = true;
            })
          },
      decoration: const InputDecoration(labelText: 'Memo'));

  Widget submitButton() => ElevatedButton.icon(
        onPressed: _canSubmitForm() ? _submitForm : null,
        icon: const Icon(Icons.update),
        label: const Text('Update'),
      );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ExtraPadding(
        child: Column(
          children: [
            PaddingBottom(
              child: Column(
                children: [budgetInput(), memoInput()],
              ),
            ),
            submitButton()
          ],
        ),
      ),
    );
  }
}
