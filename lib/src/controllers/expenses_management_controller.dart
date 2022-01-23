import 'package:flutter/widgets.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/extensions/day_queries.dart';
import 'package:kakeibo_ui/src/models/period.dart';

class ExpensesManagementController with ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  String _selectedLabel = '';
  String _selectedCost = '';
  GlobalKey<FormState> get formKey => _formKey;
  String get selectedLabel => _selectedLabel;
  String get selectedCost => _selectedCost;

  void onChangeLabel(String text) {
    _selectedLabel = text;
    notifyListeners();
  }

  void onChangeCost(String text) {
    _selectedCost = text;
    notifyListeners();
  }

  void resetForm() {
    _selectedLabel = '';
    _selectedCost = '';
    _formKey.currentState!.reset();
    notifyListeners();
  }

  Future<bool> submitForm({required Period period, required Day day}) async {
    if (_formKey.currentState!.validate()) {
      await day.createExpense(period, _selectedLabel, int.parse(_selectedCost));
      return true;
    }
    return false;
  }
}
