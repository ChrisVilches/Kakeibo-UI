import 'package:flutter/widgets.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/extensions/period_queries.dart';
import 'package:kakeibo_ui/src/models/period.dart';

class DayDetailFormController with ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  String _selectedBudget = '';
  String _selectedMemo = '';
  final Period period;
  final Day day;

  bool _formChanged = false;
  bool _submitting = false;

  GlobalKey<FormState> get formKey => _formKey;
  String get selectedBudget => _selectedBudget;
  String get selectedMemo => _selectedMemo;

  DayDetailFormController({required this.period, required this.day}) {
    _selectedBudget = day.budget == null ? '' : day.budget.toString();
    _selectedMemo = day.memo;
  }

  bool canSubmitForm() {
    if (!_formChanged) return false;
    if (_submitting) return false;
    return true;
  }

  void onChangeMemo(String text) {
    _selectedMemo = text;
    _formChanged = true;
    notifyListeners();
  }

  void onChangeBudget(String text) {
    _selectedBudget = text;
    _formChanged = true;
    notifyListeners();
  }

  Future<bool> submitForm() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    _submitting = true;
    notifyListeners();

    try {
      await period.upsertDay(
        Day(
            dayDate: day.dayDate,
            memo: selectedMemo,
            budget: selectedBudget == '' ? null : int.parse(selectedBudget)),
      );
    } on Exception {
      rethrow;
    } finally {
      _formChanged = false;
      _submitting = false;
      notifyListeners();
    }

    return true;
  }
}
