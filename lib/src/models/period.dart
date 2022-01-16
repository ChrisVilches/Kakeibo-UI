import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/models/day.dart';

// TODO: Remove the nullable (?) to as many fields as possible.
class Period {
  final int? id;
  final String? name;
  final List<Day> days;
  List<Day> fullDays;
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

  int useable() {
    double result = (salary! * (100 - savingsPercentage!)) / 100;
    return result.floor();
  }

  int useablePerDay() {
    return (useable() / fullDays.length).floor();
  }

  int limit() {
    return initialMoney! - useable();
  }

  List<Day> _getFullDays() {
    // TODO: Sort doesn't work. But for now it's ok because the backend renders the days in order.

    // days.sort((d1, d2) => d1.dayDate!.compareTo(d2.dayDate!));

    if (dateFrom == null || dateTo == null) return [];

    DateTime date = dateFrom!;

    List<Day> result = [];

    int i = 0;

    while (date.compareTo(dateTo!) <= 0) {
      if (i < days.length && days[i].dayDate == date) {
        result.add(days[i]);
        i++;
      } else {
        result.add(Day(dayDate: date));
      }

      date = date.add(const Duration(days: 1));
    }

    return result;
  }

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
        id: int.parse(json['id']),
        name: json['name'].toString(),
        days: Day.fromJsonList(json['days']),
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
