import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/period.dart';

class TableCalculator {
  final Period _period;

  late final List<int?> projections;
  late final List<int?> remaining;
  late final List<int> burndown;
  late final List<int?> diff;
  late final List<int> dayExpenses;

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
    for (int i = 0; i < _period.days.length; i++) {
      Day day = _period.fullDays[i];

      if (day.budget == null) {
        // add projection
      } else {
        // budget exists, so add null
        projections.add(null);
      }
    }
  }

  void _setDiff() {
    for (int i = 0; i < _period.days.length; i++) {
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
    for (int i = 0; i < _period.days.length; i++) {
      int value = _period.useable() - ((i + 1) * _period.useablePerDay());
      burndown.add(value);
    }
  }
}
