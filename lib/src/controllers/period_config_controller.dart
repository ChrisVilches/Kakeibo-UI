import 'package:flutter/widgets.dart';
import 'package:kakeibo_ui/src/models/extensions/period_queries.dart';
import 'package:kakeibo_ui/src/models/period.dart';

class PeriodConfigController with ChangeNotifier {
  PeriodConfigController(this.period);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Period period;
  late String _salaryValue = period.salary.toString();
  late String _savingsPercentageValue = period.savingsPercentage.toString();
  late String _dailyExpensesValue = period.dailyExpenses.toString();
  late String _initialMoneyValue = period.initialMoney.toString();
  late String _nameValue = period.name ?? '';
  bool _submitting = false;
  bool _formChanged = false;

  String get salaryValue => _salaryValue;
  String get savingsPercentageValue => _savingsPercentageValue;
  String get dailyExpensesValue => _dailyExpensesValue;
  String get initialMoneyValue => _initialMoneyValue;
  String get nameValue => _nameValue;
  bool get submitting => _submitting;
  GlobalKey<FormState> get formKey => _formKey;

  bool canSubmitForm() {
    if (!_formChanged) return false;
    if (_submitting) return false;
    return true;
  }

  void formChanged() {
    _formChanged = true;
    notifyListeners();
  }

  void onChangedName(String? text) {
    _nameValue = text ?? '';
    formChanged();
  }

  void onChangedSalary(String? text) {
    _salaryValue = text ?? '';
    formChanged();
  }

  void onChangedInitialMoney(String? text) {
    _initialMoneyValue = text ?? '';
    formChanged();
  }

  void onChangedSavingsPercentage(String? text) {
    _savingsPercentageValue = text ?? '';
    formChanged();
  }

  void onChangedDailyExpenses(String? text) {
    _dailyExpensesValue = text ?? '';
    formChanged();
  }

  Future<bool> executePeriodUpdate() async {
    if (!_formKey.currentState!.validate()) return false;
    _submitting = true;
    notifyListeners();

    try {
      Period periodChanged = Period(
          id: period.id,
          name: _nameValue,
          salary: int.parse(_salaryValue),
          dailyExpenses: int.parse(_dailyExpensesValue),
          savingsPercentage: int.parse(_savingsPercentageValue),
          initialMoney: int.parse(_initialMoneyValue));

      await PeriodQueries.update(periodChanged);
      return true;
    } catch (_) {
    } finally {
      _submitting = false;
      notifyListeners();
    }

    return false;
  }
}
