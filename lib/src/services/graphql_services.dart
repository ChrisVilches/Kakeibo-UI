import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class GraphQLServices {
  final _endpoint = path.join(dotenv.env['API_URL']!, 'graphql');

  final _token =
      'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNjQyMjk5NDUwLCJleHAiOjE2NDIzMDMwNTAsImp0aSI6ImE3NDAzMTQ4LTRmODUtNDdkZC05YTg0LTIwNzAxM2RhMDdjMCJ9.6aYzWPVkKNY82Gr37-CX_-xOcja3R3OGgfIAXioRRSs';

  GraphQLClient? _client;

  Future<void> initialize() async {
    await initHiveForFlutter();

    final HttpLink httpLink = HttpLink(_endpoint);

    final AuthLink authLink = AuthLink(
      getToken: () => 'Bearer $_token',
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

  // TODO: A bit too verbose
  // TODO: List<dynamic> is kinda ugly
  Future<List<dynamic>> fetchPeriods() async {
    final QueryOptions opt = QueryOptions(document: gql(_fetchPeriodsQuery));
    final QueryResult result = await _client!.query(opt);

    if (result.data == null) {
      return Future.error('Error happened');
    } else {
      // TODO: is this last 'fetchPeriods' necessary?
      return result.data!['fetchPeriods'];
    }
  }

  String _formatDate(DateTime dt) {
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  Future<QueryResult> createPeriod(
      String name, DateTime dateFrom, DateTime dateTo) async {
    var vars = {
      'name': name,
      'dateFrom': _formatDate(dateFrom),
      'dateTo': _formatDate(dateTo)
    };

    final QueryOptions opt = QueryOptions(
        document: gql(_createPeriodQuery), variables: {'input': vars});

    return await _client!.query(opt);
  }
}
