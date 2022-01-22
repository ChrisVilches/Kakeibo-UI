import 'package:flutter/widgets.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/day_data.dart';
import 'package:kakeibo_ui/src/models/expense.dart';
import 'package:kakeibo_ui/src/models/extensions/period_queries.dart';
import 'package:kakeibo_ui/src/models/extensions/expense_queries.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/services/table_calculator.dart';

// TODO: In this site https://docs.flutter.dev/development/data-and-backend/state-mgmt/simple
//       They call it "model". Maybe a good name would be "PeriodDataModel" or something like that
//       although controller isn't bad either, as long as this class is the only one that fetches
//       period/day/expense related data, it's ok (note that update is not necessary to have here, e.g.
//       remove expense, etc... only fetch/reload is necessary).

// TODO: Comment (explain why it's necessary)
// TODO: If this class ends up being just a global store for the period, then rename it that way
//       something like "PeriodStore". But maybe it can also store other data like currently
//       selected day, or something like that.
// TODO: Note that I said in some comments that it's necessary to optimize the queries and only
//       update what's necessary to update, however one thing to note is that everytime anything
//       changes, it's necessary to recalculate all the DayData, charts and remaining/burndown/etc
//       widgets, therefore every change (like for example a deleted expense, etc) must re-fetch
//       the period and all its data.
//       Or at least fetch exactly the data that changed but make sure the currentPeriod and currentDay
//       get updated perfectly.
//
//       This means that I could remove the "remove Expense" related functions and put them in another
//       controller (single-responsability), and then keep this controller only as a store for reloading
//       data for consumption, and not for executing changes.
//
//       For changes, put the removeExpenses, etc in a different controller, call those methods,
//       and then manually call some method in this controller to reload/recalculate the data.
class NavigationController with ChangeNotifier {
  Period? _currentPeriod;
  Day? _currentDay;
  bool _loading = false;
  List<DayData> _dayDataList = [];

  Period? get currentPeriod => _currentPeriod;
  Day? get currentDay => _currentDay;
  bool get loading => _loading;
  List<Expense> get expenses {
    if (_currentDay == null) throw Exception("Cannot get expenses, since no day has been selected");
    return _currentDay!.expenses;
  }

  bool hasPeriod() {
    return _currentPeriod != null;
  }

  DayData dayDataForDay(Day day) {
    return _dayDataList.firstWhere((DayData dayData) => dayData.day.dayDate == day.dayDate);
  }

  Future<void> undoRemoveExpense(Expense expense) async {
    await expense.destroy(undo: true);
    await reloadExpenses();
  }

  void calculateDayData() {
    _dayDataList = TableCalculator.obtainData(_currentPeriod!);
  }

  Future<void> removeExpense(Expense expense) async {
    await expense.destroy();
    expenses.removeWhere((e) => e.id == expense.id);
    calculateAll();
  }

  void loadPeriod(int periodId) async {
    if (_currentPeriod?.id != periodId) {
      _currentPeriod = null;
    }

    _loading = true;
    notifyListeners();

    _currentPeriod = await PeriodQueries.fetchOne(periodId);

    _loading = false;
    calculateAll();
  }

  void reloadPeriod() async {
    if (_currentPeriod == null) {
      throw Exception("Cannot reload period because it has not been loaded yet");
    }

    loadPeriod(_currentPeriod!.id!);
  }

  void calculateAll() {
    calculateDayData();
    notifyListeners();
  }

  Future<void> reloadExpenses() async {
    // TODO: This implementation is very inefficient. Ideally the expenses are fetched individually
    //       from a specific query that fetches expenses.
    Period period = await PeriodQueries.fetchOne(_currentPeriod!.id!);
    Day day = period.fullDays.firstWhere((d) => d.dayDate == _currentDay!.dayDate);

    _currentDay = day;
    calculateAll();
  }

  void setCurrentDay(Day? day) {
    _currentDay = day;
    calculateAll();
  }

  void clearData() {
    _currentDay = null;
    _currentPeriod = null;
    _loading = false;
    _dayDataList.clear();
    notifyListeners();
  }
}
