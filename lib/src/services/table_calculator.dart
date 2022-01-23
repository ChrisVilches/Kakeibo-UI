import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/day_data.dart';
import 'package:kakeibo_ui/src/models/period.dart';

/// Logic for generating the full table (all data necessary for graphs and other views).
class TableCalculator {
  static List<DayData> obtainData(Period period) {
    final List<int?> remaining = _getRemaining(period);
    final List<int> dayExpenses = _getExpenses(period);
    final List<int> burndown = _getBurndown(period);
    final List<int?> projections = _getProjections(period, remaining, dayExpenses);
    final List<int?> diff = _getDiff(period, remaining, burndown);

    List<DayData> data = [];

    assert(projections.length == remaining.length);
    assert(projections.length == burndown.length);
    assert(projections.length == diff.length);
    assert(projections.length == dayExpenses.length);

    for (int i = 0; i < projections.length; i++) {
      data.add(DayData(
          day: period.fullDays[i],
          projection: projections[i],
          remaining: remaining[i],
          burndown: burndown[i],
          diff: diff[i],
          dayExpenses: dayExpenses[i]));
    }

    return data;
  }

  static List<int?> _getProjections(
      Period period, List<int?> remainingList, List<int> expensesList) {
    List<int?> result = [];
    int expenseAccum = 0;
    int currValue = remainingList[0] == null ? period.salary! : remainingList[0]!;

    for (int i = 0; i < period.fullDays.length; i++) {
      Day day = period.fullDays[i];

      expenseAccum += expensesList[i];

      currValue -= expenseAccum;

      if (day.budget == null) {
        result.add(currValue);
      } else {
        result.add(null);
        currValue = remainingList[i]!;
        expenseAccum = 0;
      }

      currValue -= period.dailyExpenses!;
    }
    return result;
  }

  static List<int?> _getDiff(Period period, List<int?> remainingList, List<int> burndownList) {
    List<int?> result = [];
    for (int i = 0; i < period.fullDays.length; i++) {
      Day day = period.fullDays[i];
      if (day.budget == null) {
        result.add(null);
      } else {
        int rem = remainingList[i]!;
        int burn = burndownList[i];
        result.add(rem - burn);
      }
    }
    return result;
  }

  static List<int?> _getRemaining(Period period) {
    List<int?> result = [];
    for (Day d in period.fullDays) {
      if (d.budget == null) {
        result.add(null);
      } else {
        result.add(d.budget! - period.limit());
      }
    }
    return result;
  }

  static List<int> _getExpenses(Period period) {
    List<int> result = [];
    for (Day d in period.fullDays) {
      result.add(d.totalExpense());
    }
    return result;
  }

  static List<int> _getBurndown(Period period) {
    List<int> result = [];
    for (int i = 0; i < period.fullDays.length; i++) {
      int value = period.useable() - ((i + 1) * period.useablePerDay());
      result.add(value);
    }
    return result;
  }
}
