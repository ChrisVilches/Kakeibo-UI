import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/models/day.dart';

class Period {
  final int? id;
  final String? name;
  final List<Day> days;
  late List<Day> fullDays;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int? initialMoney;
  final int? salary;
  final int? dailyExpenses;
  final int? savingsPercentage;

  Period(
      {this.id,
      this.name,
      this.salary,
      this.dailyExpenses,
      this.initialMoney,
      this.savingsPercentage,
      this.days = const [],
      this.fullDays = const [],
      this.dateFrom,
      this.dateTo}) {
    fullDays = _getFullDays();
  }

  bool fullyConfigured() {
    bool emptyOrZero(int? num) => (num ?? 0) == 0;
    return !emptyOrZero(salary) && !emptyOrZero(initialMoney) && !emptyOrZero(dailyExpenses);
  }

  int useable() {
    double result = (salary! * (100 - savingsPercentage!)) / 100.0;
    return result.round();
  }

  int useablePerDay() {
    return (useable() / fullDays.length).round();
  }

  int limit() {
    return initialMoney! - useable();
  }

  List<Day> _getFullDays() {
    if (dateFrom == null || dateTo == null) return [];

    DateTime date = dateFrom!;

    List<Day> result = [];

    int i = 0;

    while (date.compareTo(dateTo!) <= 0) {
      if (i < days.length && days[i].dayDate == date) {
        result.add(days[i++]);
      } else {
        result.add(Day(dayDate: date));
      }

      date = date.add(const Duration(days: 1));
    }

    return result;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'salary': salary,
        'initialMoney': initialMoney,
        'dailyExpenses': dailyExpenses,
        'savingsPercentage': savingsPercentage,
        'dateFrom': dateFrom == null ? null : DateUtil.formatDate(dateFrom!),
        'dateTo': dateTo == null ? null : DateUtil.formatDate(dateTo!)
      };

  factory Period.fromJson(Map<String, dynamic> json) {
    List<Day> days = Day.fromJsonList(json['days']);
    days.sort((d1, d2) => d1.dayDate.compareTo(d2.dayDate));

    return Period(
        id: int.parse(json['id']),
        name: json['name'].toString(),
        days: days,
        salary: json['salary'],
        initialMoney: json['initialMoney'],
        dailyExpenses: json['dailyExpenses'],
        savingsPercentage: json['savingsPercentage'],
        dateFrom: DateUtil.parseDate(json['dateFrom']),
        dateTo: DateUtil.parseDate(json['dateTo']));
  }

  static List<Period> fromJsonList(jsonList) {
    if (jsonList == null) return [];
    return jsonList.map<Period>((json) => Period.fromJson(json)).toList();
  }
}
