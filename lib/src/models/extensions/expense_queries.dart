import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kakeibo_ui/src/models/expense.dart';
import 'package:kakeibo_ui/src/services/gql_client.dart';
import 'package:kakeibo_ui/src/services/locator.dart';

extension ExpenseQueries on Expense {
  Future<Expense> destroy() async {
    QueryResult result = await serviceLocator.get<GQLClient>().executeQuery(
      """
      mutation DestroyExpense(\$input: ExpensesDestroyInput!) {
        destroyExpense(input: \$input) {
          id
          cost
          label
        }
      }""",
      variables: {
        'input': {'id': id}
      },
    );

    return Expense.fromJson(result.data!['destroyExpense']);
  }
}
