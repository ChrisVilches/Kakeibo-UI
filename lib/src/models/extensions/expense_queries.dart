import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kakeibo_ui/src/models/expense.dart';
import 'package:kakeibo_ui/src/services/gql_client.dart';
import 'package:kakeibo_ui/src/services/locator.dart';

extension ExpenseQueries on Expense {
  Future<Expense> destroy({bool undo = false}) async {
    QueryResult result = await serviceLocator.get<GQLClient>().executeQuery(
      """
      mutation(\$input: ExpensesDestroyInput!) {
        destroyExpense(input: \$input) {
          id
          cost
          label
        }
      }""",
      variables: {
        'input': {'id': id, 'undiscard': undo}
      },
    );

    return Expense.fromJson(result.data!['destroyExpense']);
  }
}
