import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/services/gql_client.dart';
import 'package:kakeibo_ui/src/services/locator.dart';

// TODO: Remove the nullable (?) to as many fields as possible.
// TODO: I think queries from GraphQL should come as a mixin/concern/extension. Not in this class.
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

  static Future<List<Period>> fetchAll() async {
    QueryResult result = await serviceLocator.get<GQLClient>().executeQuery(
      """
      query {
        fetchPeriods {
          id
          name
          dateFrom
          dateTo
        }
      }""",
    );

    return Period.fromJsonList(result.data!['fetchPeriods']);
  }

  static Future<Period> fetchOne(int id) async {
    QueryResult result = await serviceLocator.get<GQLClient>().executeQuery(
      """
      query FetchOnePeriod(\$id: ID!) {
        fetchOnePeriod(id: \$id) {
          id
          name
          dateFrom
          dateTo
          salary
          initialMoney
          dailyExpenses
          savingsPercentage
          days {
            id
            memo
            dayDate
            budget
            expenses {
              id
              label
              cost
            }
          }
        }
      }""",
      variables: {'id': id},
    );

    return Period.fromJson(result.data!['fetchOnePeriod']);
  }

  static Future<Period> create(String name, DateTime dateFrom, DateTime dateTo) async {
    QueryResult result = await serviceLocator.get<GQLClient>().executeQuery(
      """
      mutation CreatePeriod(\$input: PeriodsCreateInput!) {
        createPeriod(input: \$input) {
          id
          name
          dateTo
          dateFrom
        }
      }""",
      variables: {
        'input': {
          'name': name,
          'dateFrom': DateUtil.formatDate(dateFrom),
          'dateTo': DateUtil.formatDate(dateTo)
        }
      },
    );

    return Period.fromJson(result.data!['createPeriod']);
  }

  static Future<Period> update(Period period) async {
    QueryResult result = await serviceLocator.get<GQLClient>().executeQuery(
      """
      mutation UpdatePeriod(\$input: PeriodsUpdateInput!) {
        updatePeriod(input: \$input) {
          id
          name
          dateTo
          dateFrom
        }
      }""",
      variables: {'input': period.toJson()},
    );

    return Period.fromJson(result.data!['updatePeriod']);
  }

  Future<Day> upsertDay(Day day) async {
    QueryResult result = await serviceLocator.get<GQLClient>().executeQuery(
      """
      mutation UpsertDayQuery(\$input: DaysUpsertInput!) {
        upsertDay(input: \$input) {
          id
          budget
          memo
          dayDate
        }
      }
    """,
      variables: {
        'input': {
          'budget': day.budget,
          'memo': day.memo,
          'periodId': id!,
          'dayDate': DateUtil.formatDate(day.dayDate)
        }
      },
    );

    return Day.fromJson(result.data!['upsertDay']);
  }

  Future<Period> destroy() async {
    QueryResult result = await serviceLocator.get<GQLClient>().executeQuery(
      """
      mutation DestroyPeriod(\$input: PeriodsDestroyInput!) {
        destroyOnePeriod(input: \$input) {
          id
          name
          dateFrom
          dateTo
        }
      }""",
      variables: {
        'input': {'id': id!} // TODO: Can't it be simpler? without the 'input'
      },
    );

    return Period.fromJson(result.data!['destroyOnePeriod']);
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
