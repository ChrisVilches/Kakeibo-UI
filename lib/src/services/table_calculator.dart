import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/period.dart';

/// Logic for generating the full table (all data necessary for graphs and other views).
class TableCalculator {
  final Period _period;

  late final List<int?> projections = [];
  late final List<int?> remaining = [];
  late final List<int> burndown = [];
  late final List<int?> diff = [];
  late final List<int> dayExpenses = [];

  TableCalculator(this._period) {
    _setExpenses();
    _setBurndown();
    _setRemaining();
    _setProjections();
    _setDiff();

    assert(projections.length == remaining.length);
    assert(projections.length == burndown.length);
    assert(projections.length == diff.length);
    assert(projections.length == dayExpenses.length);
  }

  void _setProjections() {
    int expenseAccum = 0;
    int currValue =
        remaining[0] == null ? _period.initialMoney! : remaining[0]!;

    for (int i = 0; i < _period.fullDays.length; i++) {
      Day day = _period.fullDays[i];

      expenseAccum += dayExpenses[i];

      currValue -= expenseAccum;

      if (day.budget == null) {
        projections.add(currValue);
      } else {
        projections.add(null);
        currValue = remaining[i]!;
        expenseAccum = 0;
      }

      currValue -= _period.dailyExpenses!;
    }
  }

  void _setDiff() {
    for (int i = 0; i < _period.fullDays.length; i++) {
      Day day = _period.fullDays[i];
      if (day.budget == null) {
        diff.add(null);
      } else {
        int rem = remaining[i]!;
        int burn = burndown[i];
        diff.add(rem - burn);
      }
    }
  }

  void _setRemaining() {
    for (Day d in _period.fullDays) {
      if (d.budget == null) {
        remaining.add(null);
      } else {
        remaining.add(d.budget! - _period.limit());
      }
    }
  }

  void _setExpenses() {
    for (Day d in _period.fullDays) {
      dayExpenses.add(d.totalExpense());
    }
  }

  void _setBurndown() {
    for (int i = 0; i < _period.fullDays.length; i++) {
      int value = _period.useable() - ((i + 1) * _period.useablePerDay());
      burndown.add(value);
    }
  }
}
