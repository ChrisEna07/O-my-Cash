class SavingsGoalModel {
  final String? id;
  final String userId;
  final String goalName;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final DateTime? createdAt;

  SavingsGoalModel({
    this.id,
    required this.userId,
    required this.goalName,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.createdAt,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'],
      userId: json['user_id'],
      goalName: json['goal_name'],
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num).toDouble(),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'goal_name': goalName,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      if (deadline != null) 'deadline': deadline!.toIso8601String().split('T')[0],
    };
  }
}
