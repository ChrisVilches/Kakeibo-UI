import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/models/expense.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/services/gql_client.dart';
import 'package:kakeibo_ui/src/services/locator.dart';

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

  Future<Day> createExpense(Period period, String label, int cost) async {
    QueryResult result = await serviceLocator.get<GQLClient>().executeQuery("""
      mutation CreateExpense(\$input: ExpensesCreateInput!) {
        createExpense(input: \$input) {
          id
          dayDate
          expenses {
            id
            label
            cost
          }
        }
      }
    """, variables: {
      'input': {
        'label': label,
        'cost': cost,
        'periodId': period.id!,
        'dayDate': DateUtil.formatDate(dayDate)
      }
    });

    return Day.fromJson(result.data!['createExpense']);
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
