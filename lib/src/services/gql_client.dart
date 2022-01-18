import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kakeibo_ui/src/enums/token_removal_cause.dart';
import 'package:kakeibo_ui/src/exceptions/not_logged_in_exception.dart';
import 'package:kakeibo_ui/src/exceptions/signature_expired_exception.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:collection/collection.dart';
import 'package:kakeibo_ui/src/services/user_service.dart';
import 'package:path/path.dart' as path;

class GQLClient {
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

  Future<QueryResult> executeQuery(queryString, {dynamic variables}) async {
    final QueryOptions opt = QueryOptions(
        document: gql(queryString), variables: variables ?? {}, fetchPolicy: FetchPolicy.noCache);

    final QueryResult result = await _client!.query(opt);

    _throwErrorsFromQueryResult(result);

    return result;
  }
}
