import 'package:kakeibo_ui/src/models/day.dart';

class DayData {
  final int? projection;
  final int? remaining;
  final int burndown;
  final int? diff;
  final int dayExpenses;
  final Day day;

  const DayData(
      {required this.day,
      required this.projection,
      required this.remaining,
      required this.burndown,
      required this.diff,
      required this.dayExpenses});
}
