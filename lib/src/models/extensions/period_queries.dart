import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/services/gql_client.dart';
import 'package:kakeibo_ui/src/services/locator.dart';

extension PeriodQueries on Period {
  static Future<List<Period>> fetchAll() async {
    QueryResult result = await serviceLocator.get<GQLClient>().executeQuery(
      '''
      {
        fetchPeriods {
          id
          name
          dateFrom
          dateTo
        }
      }''',
    );

    return Period.fromJsonList(result.data!['fetchPeriods'] as List);
  }

  static Future<Period> fetchOne(int id) async {
    QueryResult result = await serviceLocator.get<GQLClient>().executeQuery(
      '''
      query(\$id: ID!) {
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
      }''',
      variables: {'id': id},
    );

    return Period.fromJson(result.data!['fetchOnePeriod']);
  }

  static Future<Period> create(String name, DateTime dateFrom, DateTime dateTo) async {
    QueryResult result = await serviceLocator.get<GQLClient>().executeQuery(
      '''
      mutation(\$input: PeriodsCreateInput!) {
        createPeriod(input: \$input) {
          id
          name
          dateTo
          dateFrom
        }
      }''',
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
      '''
      mutation(\$input: PeriodsUpdateInput!) {
        updatePeriod(input: \$input) {
          id
          name
          dateTo
          dateFrom
        }
      }''',
      variables: {'input': period.toJson()},
    );

    return Period.fromJson(result.data!['updatePeriod']);
  }

  Future<Day> upsertDay(Day day) async {
    QueryResult result = await serviceLocator.get<GQLClient>().executeQuery(
      '''
      mutation(\$input: DaysUpsertInput!) {
        upsertDay(input: \$input) {
          id
          budget
          memo
          dayDate
        }
      }
    ''',
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
      '''
      mutation(\$input: PeriodsDestroyInput!) {
        destroyOnePeriod(input: \$input) {
          id
          name
          dateFrom
          dateTo
        }
      }''',
      variables: {
        'input': {'id': id!}
      },
    );

    return Period.fromJson(result.data!['destroyOnePeriod']);
  }
}
