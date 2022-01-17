import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/extra_padding_widget.dart';
import 'package:kakeibo_ui/src/decoration/helpers.dart';
import 'package:kakeibo_ui/src/decoration/loading_icon_widget.dart';
import 'package:kakeibo_ui/src/decoration/padding_bottom_widget.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/period_list/widgets/digits_only_input_widget.dart';
import 'package:kakeibo_ui/src/services/graphql_services.dart';
import 'package:kakeibo_ui/src/services/locator.dart';

class PeriodConfigWidget extends StatefulWidget {
  final Period period;

  const PeriodConfigWidget({Key? key, required this.period}) : super(key: key);

  @override
  PeriodConfigState createState() => PeriodConfigState();
}

class PeriodConfigState extends State<PeriodConfigWidget> {
  final _formKey = GlobalKey<FormState>();

  String _salaryValue = "";
  String _savingsPercentageValue = "";
  String _dailyExpensesValue = "";
  String _initialMoneyValue = "";
  bool _loading = false;
  bool _submitting = false;
  bool _formChanged = false;

  bool _canSubmitForm() {
    if (!_formChanged) return false;
    if (_submitting) return false;
    return true;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      debugPrint("Submitting form");
      setState(() {
        _submitting = true;
        _formChanged = false;
      });

      Period periodChanged = Period(
          id: widget.period.id,
          salary: int.parse(_salaryValue),
          dailyExpenses: int.parse(_dailyExpensesValue),
          savingsPercentage: int.parse(_savingsPercentageValue),
          initialMoney: int.parse(_initialMoneyValue),
          dateFrom: null,
          dateTo: null);

      Period updatedPeriod = await serviceLocator
          .get<GraphQLServices>()
          .updatePeriod(periodChanged);

      Helpers.simpleSnackbar(context, "Updated period information.");
      debugPrint("Updated period. New data: $updatedPeriod");
      Navigator.of(context).pop(true);
    }
  }

  @override
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPeriod();
  }

  void _loadPeriod() async {
    setState(() {
      _loading = true;
    });
    Period period = await serviceLocator
        .get<GraphQLServices>()
        .fetchOnePeriod(widget.period.id!);

    setState(() {
      _salaryValue = period.salary.toString();
      _savingsPercentageValue = period.savingsPercentage.toString();
      _dailyExpensesValue = period.dailyExpenses.toString();
      _initialMoneyValue = period.initialMoney.toString();
      _loading = false;
    });
  }

  void _removePeriod() async {
    Widget okButton = TextButton(
      child: const Text("Delete"),
      style:
          ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.red)),
      onPressed: () async {
        Period deletedPeriod = await serviceLocator
            .get<GraphQLServices>()
            .destroyPeriod(widget.period.id!);

        Helpers.simpleSnackbar(context, "Removed: ${deletedPeriod.name}");
        Navigator.popUntil(context, ModalRoute.withName('/'));
      },
    );

    AlertDialog alert;

    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      style:
          ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.grey)),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    alert = AlertDialog(
      title: const Text("Delete period?"),
      content: const Text(
          "Are you sure you want to remove this period? This action cannot be undone."),
      actions: [okButton, cancelButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget submitButton = ElevatedButton.icon(
      onPressed: _canSubmitForm() ? _submitForm : null,
      icon: const Icon(Icons.add),
      label: const Text('Save'),
    );

    final form = Form(
      key: _formKey,
      child: ExtraPadding(
        child: Column(
          children: [
            PaddingBottom(
              child: Column(
                children: [
                  DigitsOnlyInputWidget("This month's salary",
                      initialValue: _salaryValue,
                      onChanged: (text) => {
                            setState(() {
                              _formChanged = true;
                              _salaryValue = text ?? '';
                            })
                          }),
                  DigitsOnlyInputWidget("Initial money",
                      initialValue: _initialMoneyValue,
                      onChanged: (text) => {
                            setState(() {
                              _formChanged = true;
                              _initialMoneyValue = text ?? '';
                            })
                          }),
                  DigitsOnlyInputWidget("Savings Percentage (%)",
                      initialValue: _savingsPercentageValue,
                      onChanged: (text) => {
                            setState(() {
                              _formChanged = true;
                              _savingsPercentageValue = text ?? '';
                            })
                          }),
                  DigitsOnlyInputWidget("Daily Expenses",
                      initialValue: _dailyExpensesValue,
                      onChanged: (text) => {
                            setState(() {
                              _formChanged = true;
                              _dailyExpensesValue = text ?? '';
                            })
                          }),
                ],
              ),
            ),
            submitButton
          ],
        ),
      ),
    );

    Widget removeButton = ElevatedButton.icon(
      onPressed: _removePeriod,
      style:
          ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
      icon: const Icon(Icons.delete),
      label: const Text("Delete period"),
    );

    return Scaffold(
      appBar: AppBar(title: Text("${widget.period.name} - Settings")),
      body: _loading
          ? const LoadingIcon()
          : Column(
              children: [
                form,
                removeButton,
              ],
            ),
    );
  }
}
