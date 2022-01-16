import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:path/path.dart' as path;

class GraphQLServices {
  final _endpoint = path.join(dotenv.env['API_URL']!, 'graphql');

  Future<String> _getJwtToken() async {
    String token = (await serviceLocator
        .get<FlutterSecureStorage>()
        .read(key: 'jwtToken'))!;

    return token;
  }

  GraphQLClient? _client;

  Future<void> initialize() async {
    await initHiveForFlutter();

    final HttpLink httpLink = HttpLink(_endpoint);

    final AuthLink authLink = AuthLink(
      getToken: _getJwtToken,
    );

    final Link link = authLink.concat(httpLink);

    _client = GraphQLClient(link: link, cache: GraphQLCache());
  }

  // TODO: Put queries in a different file. They are mixed with the client creation boilerplate.

  final _fetchPeriodsQuery = """
  query {
    fetchPeriods {
      id
      name
      dateFrom
      dateTo
    }
  }
  """;

  final _createPeriodQuery = """
    mutation CreatePeriod(\$input: PeriodsCreateInput!) {
      createPeriod(input: \$input) {
        id
        name
      }
    }
  """;

  final _fetchOnePeriodQuery = """
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
      }
    }
  }
  """;

  // TODO: A bit too verbose
  Future<List<Period>> fetchPeriods() async {
    final QueryOptions opt = QueryOptions(document: gql(_fetchPeriodsQuery));
    final QueryResult result = await _client!.query(opt);

    if (result.data == null) {
      return Future.error('Error happened');
    } else {
      // TODO: is this last 'fetchPeriods' necessary?
      return Period.fromJsonList(result.data!['fetchPeriods']);
    }
  }

  Future<Period> fetchOnePeriod(int id) async {
    final QueryOptions opt = QueryOptions(
        document: gql(_fetchOnePeriodQuery), variables: {'id': id});
    final QueryResult result = await _client!.query(opt);

    if (result.data == null) {
      return Future.error('Error happened');
    } else {
      // TODO: is this last 'fetchPeriods' necessary?
      return Period.fromJson(result.data!['fetchOnePeriod']);
    }
  }

  // TODO: Return "Period" instance.
  Future<QueryResult> createPeriod(
      String name, DateTime dateFrom, DateTime dateTo) async {
    var vars = {
      'name': name,
      'dateFrom': DateUtil.formatDate(dateFrom),
      'dateTo': DateUtil.formatDate(dateTo)
    };

    final QueryOptions opt = QueryOptions(
        document: gql(_createPeriodQuery), variables: {'input': vars});

    return await _client!.query(opt);
  }
}
