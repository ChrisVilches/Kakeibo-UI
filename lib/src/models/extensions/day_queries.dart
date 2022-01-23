import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/services/gql_client.dart';
import 'package:kakeibo_ui/src/services/locator.dart';

extension DayQueries on Day {
  Future<Day> createExpense(Period period, String label, int cost) async {
    QueryResult result = await serviceLocator.get<GQLClient>().executeQuery('''
      mutation(\$input: ExpensesCreateInput!) {
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
    ''', variables: {
      'input': {
        'label': label,
        'cost': cost,
        'periodId': period.id!,
        'dayDate': DateUtil.formatDate(dayDate)
      }
    });

    return Day.fromJson(result.data!['createExpense']);
  }
}
