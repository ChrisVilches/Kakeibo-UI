class Expense {
  final int id;
  final int cost;
  final String? label;

  Expense({required this.id, required this.cost, this.label});

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: int.parse(json['id']),
      cost: int.parse(
          json['cost']), // TODO: Should come as an int from the server.
      label: json['label'],
    );
  }

  static List<Expense> fromJsonList(jsonList) {
    if (jsonList == null) return [];
    return jsonList.map<Expense>((json) => Expense.fromJson(json)).toList();
  }
}
