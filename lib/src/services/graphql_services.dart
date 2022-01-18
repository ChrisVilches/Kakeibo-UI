import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/enums/token_removal_cause.dart';
import 'package:kakeibo_ui/src/exceptions/not_logged_in_exception.dart';
import 'package:kakeibo_ui/src/exceptions/signature_expired_exception.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/expense.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:collection/collection.dart';
import 'package:kakeibo_ui/src/services/user_service.dart';
import 'package:path/path.dart' as path;

// TODO: Split into files

class GraphQLServices {
  final _endpoint = path.join(dotenv.env['API_URL']!, 'graphql');

  GraphQLClient? _client;

  Future<void> initialize() async {
    await initHiveForFlutter();

    final HttpLink httpLink = HttpLink(_endpoint);

    final AuthLink authLink = AuthLink(
      getToken: () => serviceLocator.get<UserService>().token,
    );

    final Link link = authLink.concat(httpLink);

    _client = GraphQLClient(link: link, cache: GraphQLCache());
  }

  // TODO: The fact that queries require some parameters (but it's never explicit... I have to guess) and not some other ones is also a code smell.

  Future<List<Period>> fetchPeriods() async {
    QueryResult result = await executeQuery(
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

  // TODO: Execution of query is stopped abruptly simply by throwing an exception. Not sure about this pattern.
  //       (The exception is logged by Flutter and doesn't crash the app, so it works).
  void _throwErrorsFromQueryResult(QueryResult result) {
    if (!result.hasException) return;

    if (result.exception!.graphqlErrors.isEmpty) {
      throw Exception("An error happened");
    }

    List<GraphQLError> errorList = result.exception!.graphqlErrors;

    if (_containsErrorCode(errorList, "NOT_LOGGED_IN")) {
      serviceLocator.get<UserService>().removeToken(TokenRemovalCause.unknown);
      throw NotLoggedInException();
    }

    if (_containsErrorCode(errorList, "SIGNATURE_EXPIRED")) {
      serviceLocator.get<UserService>().removeToken(TokenRemovalCause.sessionExpired);
      throw SignatureExpiredException();
    }
  }

  bool _containsErrorCode(List<GraphQLError>? errors, String code) {
    if (errors == null) return false;
    return errors.firstWhereOrNull((e) => e.extensions?['code'] == code) != null;
  }

  Future<Period> fetchOnePeriod(int id) async {
    QueryResult result = await executeQuery(
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

  Future<Period> createPeriod(String name, DateTime dateFrom, DateTime dateTo) async {
    QueryResult result = await executeQuery(
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

  Future<QueryResult> executeQuery(queryString, {dynamic variables}) async {
    final QueryOptions opt = QueryOptions(
        document: gql(queryString), variables: variables ?? {}, fetchPolicy: FetchPolicy.noCache);

    final QueryResult result = await _client!.query(opt);

    _throwErrorsFromQueryResult(result);

    return result;
  }

  Future<Day> createExpense(Period period, Day day, String label, int cost) async {
    QueryResult result = await executeQuery("""
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
        'dayDate': DateUtil.formatDate(day.dayDate)
      }
    });

    return Day.fromJson(result.data!['createExpense']);
  }

  Future<Day> upsertDay(Period period, Day day, int budget, String memo) async {
    QueryResult result = await executeQuery(
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
          'budget': budget,
          'memo': memo,
          'periodId': period.id!,
          'dayDate': DateUtil.formatDate(day.dayDate)
        }
      },
    );

    return Day.fromJson(result.data!['upsertDay']);
  }

  Future<Period> updatePeriod(Period period) async {
    QueryResult result = await executeQuery(
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

  Future<Expense> destroyExpense(int expenseId) async {
    QueryResult result = await executeQuery(
      """
      mutation DestroyExpense(\$input: ExpensesDestroyInput!) {
        destroyExpense(input: \$input) {
          id
          cost
          label
        }
      }""",
      variables: {
        'input': {'id': expenseId} // TODO: impossible only with ID???? (i.e. without 'input')
      },
    );

    return Expense.fromJson(result.data!['destroyExpense']);
  }

  Future<Period> destroyPeriod(int periodId) async {
    QueryResult result = await executeQuery(
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
        'input': {'id': periodId} // TODO: Can't it be simpler? without the 'input'
      },
    );

    return Period.fromJson(result.data!['destroyOnePeriod']);
  }
}
