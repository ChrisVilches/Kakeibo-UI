import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kakeibo_ui/src/services/gql_client.dart';
import 'package:kakeibo_ui/src/services/locator.dart';

class Expense {
  final int id;
  final int cost;
  final String? label;

  Expense({required this.id, required this.cost, this.label});

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
        'input': {'id': id} // TODO: impossible only with ID???? (i.e. without 'input')
      },
    );

    return Expense.fromJson(result.data!['destroyExpense']);
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: int.parse(json['id']),
      cost: int.parse(json['cost']), // BigInt (rendered as string from the backend)
      label: json['label'],
    );
  }

  static List<Expense> fromJsonList(jsonList) {
    if (jsonList == null) return [];
    return jsonList.map<Expense>((json) => Expense.fromJson(json)).toList();
  }
}
