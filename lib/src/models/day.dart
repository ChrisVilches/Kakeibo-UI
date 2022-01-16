import 'package:intl/intl.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';

class Day {
  final int? id;
  final DateTime? dayDate;
  final String memo;
  final int? budget;

  Day({this.id, this.dayDate, this.memo = '', this.budget});

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      id: int.parse(json['id']),
      budget: json['budget'],
      dayDate: DateUtil.parseDate(json['dayDate']),
      memo: json['memo'] ?? '',
    );
  }

  // TODO: This code and the factory can be recycled.
  static List<Day> fromJsonList(jsonList) {
    if (jsonList == null) return [];
    return jsonList.map<Day>((json) => Day.fromJson(json)).toList();
  }
}
