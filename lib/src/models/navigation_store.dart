import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/day_data.dart';
import 'package:kakeibo_ui/src/models/expense.dart';
import 'package:kakeibo_ui/src/models/extensions/period_queries.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/services/table_calculator.dart';

/// This class is used to store the global navigation state. This means, storing the currently
/// selected period, currently selected day, expenses, etc. It can also reload this data
/// for ease of navigation, for example when data needs to be reloaded after editing, or adding
/// an expense, and making sure the new data is reflected in all views.
/// This class also makes it easy to navigate without having to pass down period and day parameters,
/// this avoiding complications when nesting too many widgets.
/// An instance of this class should be provided at root scope, so that it can
/// be accessed by any widget.
class NavigationStore with ChangeNotifier {
  Period? _currentPeriod;
  Day? _currentDay;
  bool _loading = false;
  List<DayData> _dayDataList = [];

  Period? get currentPeriod => _currentPeriod;
  Day? get currentDay => _currentDay;
  bool get loading => _loading;
  List<Expense> get expenses {
    if (_currentDay == null) throw Exception('Cannot get expenses, since no day has been selected');
    return _currentDay!.expenses;
  }

  set currentDay(Day? day) {
    _currentDay = day;
    notifyListeners();
  }

  bool hasPeriod() {
    return _currentPeriod != null;
  }

  DayData dayDataForDay(Day day) {
    return _dayDataList.firstWhere((DayData dayData) => dayData.day.dayDate == day.dayDate);
  }

  // TODO: Should reload only expenses from the backend. But reloading the entire period works.
  //       Reloading expenses and then calling '_calculateAll' (calculate data and notify) also works,
  //       so implement that eventually.
  Future<void> reloadExpenses() async {
    await reloadPeriod();
  }

  // TODO: Not used, but since I plan to make updates more granular (for performance optimization)
  //       then I could also add a way to reload just the current day.
  Future<void> reloadDay() async {
    await reloadPeriod();
  }

  void _calculateDayData() {
    _dayDataList = TableCalculator.obtainData(_currentPeriod!);
  }

  Future<void> loadPeriod(int periodId) async {
    if (_currentPeriod?.id != periodId) {
      _currentPeriod = null;
    }

    _loading = true;
    notifyListeners();

    debugPrint('Fetching one period (graphql)');
    _currentPeriod = await PeriodQueries.fetchOne(periodId);
    _updateCurrentDayFromCurrentPeriod();

    _loading = false;
    _calculateAll();
  }

  void _updateCurrentDayFromCurrentPeriod() {
    if (_currentDay == null) return;

    _currentDay =
        _currentPeriod!.fullDays.firstWhereOrNull((Day day) => day.dayDate == _currentDay!.dayDate);
  }

  Future<void> reloadPeriod() async {
    if (_currentPeriod == null) {
      throw Exception('Cannot reload period because it has not been loaded yet');
    }

    await loadPeriod(_currentPeriod!.id!);
  }

  void _calculateAll() {
    _calculateDayData();
    notifyListeners();
  }

  void clearData() {
    _currentDay = null;
    _currentPeriod = null;
    _loading = false;
    _dayDataList.clear();
    notifyListeners();
  }
}
