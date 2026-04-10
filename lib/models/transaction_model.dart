enum TransactionType { income, expense }

enum RuleCategory { need, want, save }

class TransactionModel {
  final String? id;
  final String userId;
  final double amount;
  final TransactionType type;
  final String category;
  final RuleCategory ruleCategory;
  final String? description;
  final DateTime createdAt;

  TransactionModel({
    this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.ruleCategory,
    this.description,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      userId: json['user_id'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      category: json['category'],
      ruleCategory: RuleCategory.values.firstWhere((e) => e.name == json['rule_category']),
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type.name,
      'category': category,
      'rule_category': ruleCategory.name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
