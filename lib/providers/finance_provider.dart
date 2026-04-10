import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/savings_goal_model.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';

class FinanceProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();
  
  List<TransactionModel> _transactions = [];
  List<SavingsGoalModel> _goals = [];
  String _userName = '';
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  List<SavingsGoalModel> get goals => _goals;
  String get userName => _userName;
  bool get isLoading => _isLoading;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, item) => sum + item.amount);

  double get totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, item) => sum + item.amount);

  double get balance => totalIncome - totalExpenses;

  // 50/30/20 Calculations based on TOTAL INCOME
  double get needsSpent => _transactions
      .where((t) => t.type == TransactionType.expense && t.ruleCategory == RuleCategory.need)
      .fold(0, (sum, item) => sum + item.amount);

  double get wantsSpent => _transactions
      .where((t) => t.type == TransactionType.expense && t.ruleCategory == RuleCategory.want)
      .fold(0, (sum, item) => sum + item.amount);

  double get savingsSpent => _transactions
      .where((t) => t.type == TransactionType.expense && t.ruleCategory == RuleCategory.save)
      .fold(0, (sum, item) => sum + item.amount);

  Future<void> fetchData() async {
    _isLoading = true;
    _safeNotify();
    try {
      _transactions = await _service.getTransactions();
      _goals = await _service.getSavingsGoals();
      
      final profile = await _service.getProfile();
      if (profile != null) {
        _userName = profile['full_name'] ?? '';
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  void _safeNotify() {
    try {
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _service.addTransaction(transaction);
    await fetchData();
  }

  Future<void> addGoal(SavingsGoalModel goal) async {
    await _service.addSavingsGoal(goal);
    await fetchData();
  }

  Future<void> updateUserName(String name) async {
    await _service.updateProfile(name);
    _userName = name;
    _safeNotify();
  }

  Future<void> injectToGoal(String goalId, double amount) async {
    final goal = _goals.firstWhere((g) => g.id == goalId);
    final newAmount = goal.currentAmount + amount;
    
    await _service.updateSavingsGoalProgress(goalId, newAmount);
    
    // Check if goal reached!
    if (newAmount >= goal.targetAmount && goal.currentAmount < goal.targetAmount) {
      await NotificationService().showNotification(
        id: goal.id.hashCode,
        title: '¡Meta Cumplida! ??',
        body: 'Has alcanzado tu meta: ${goal.goalName}. ¡Felicidades!',
      );
    }

    await fetchData();
  }

  Future<void> resetAllData() async {
    await _service.resetUserData();
    await fetchData();
  }
}
