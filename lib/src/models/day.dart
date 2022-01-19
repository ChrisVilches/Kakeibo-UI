import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/models/expense.dart';

class Day {
  final int? id;
  final DateTime dayDate;
  final String memo;
  final int? budget;
  final List<Expense> expenses;

  Day({
    this.id,
    required this.dayDate,
    this.memo = '',
    this.budget,
    this.expenses = const [],
  });

  int totalExpense() {
    int result = 0;

    for (final Expense e in expenses) {
      result += e.cost;
    }

    return result;
  }

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      id: int.parse(json['id']),
      budget: json['budget'],
      dayDate: DateUtil.parseDate(json['dayDate']),
      expenses: Expense.fromJsonList(json['expenses']),
      memo: json['memo'] ?? '',
    );
  }

  static List<Day> fromJsonList(jsonList) {
    if (jsonList == null) return [];
    return jsonList.map<Day>((json) => Day.fromJson(json)).toList();
  }
}
