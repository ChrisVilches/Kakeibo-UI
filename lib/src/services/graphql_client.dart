import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

// TODO: Class and file name are different
class GraphQLServices {
  final String _endpoint = 'http://localhost:3000/graphql';
  final String _token =
      'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNjQyMjk0NTE4LCJleHAiOjE2NDIyOTgxMTgsImp0aSI6IjVjYzA1MGRkLTVjY2UtNDRhYS1hOWYzLTFlYTFkMzUzYjdmZSJ9.uATo9rdsLhTJ1UcULZL-kGozi7rZvrJAu6QwxLAmtWU';

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

  String _fetchPeriodsQuery() {
    return """
      query {
        fetchPeriods {
          id
          name
        }
      }
    """;
  }

  String _createPeriodQuery() {
    return """
      mutation CreatePeriod(\$input: PeriodsCreateInput!) {
        createPeriod(input: \$input) {
          id
          name
        }
      }
    """;
  }

  // TODO: A bit too verbose
  // TODO: List<dynamic> is kinda ugly
  Future<List<dynamic>> fetchPeriods() async {
    final QueryOptions opt = QueryOptions(document: gql(_fetchPeriodsQuery()));
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
        document: gql(_createPeriodQuery()), variables: {'input': vars});

    return await _client!.query(opt);
  }
}
