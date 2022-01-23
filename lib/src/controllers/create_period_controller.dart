import 'package:flutter/widgets.dart';
import 'package:kakeibo_ui/src/models/extensions/period_queries.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CreatePeriodController with ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String _selectedName = '';
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now().add(const Duration(days: 31));

  GlobalKey<FormState> get formKey => _formKey;
  bool get loading => _loading;
  String get selectedName => _selectedName;
  DateTime get selectedStartDate => _selectedStartDate;
  DateTime get selectedEndDate => _selectedEndDate;

  CreatePeriodController();

  void onNameChanged(String text) {
    _selectedName = text;
    notifyListeners();
  }

  void onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    _selectedStartDate = args.value.startDate as DateTime;
    _selectedEndDate = args.value.endDate as DateTime;
    notifyListeners();
  }

  Future<bool> executeCreatePeriod() async {
    if (!_formKey.currentState!.validate()) return false;

    _loading = true;
    notifyListeners();

    try {
      await PeriodQueries.create(_selectedName, _selectedStartDate, _selectedEndDate);
      return true;
    } catch (_) {
      _loading = false;
    }
    notifyListeners();
    return false;
  }
}
