import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';
import '../models/savings_goal_model.dart';

class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  // --- Transactions ---
  Future<List<TransactionModel>> getTransactions() async {
    final response = await _client
        .from('transactions')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _client.from('transactions').insert(transaction.toJson());
  }

  // --- Savings Goals ---
  Future<List<SavingsGoalModel>> getSavingsGoals() async {
    final response = await _client.from('savings_goals').select();
    return (response as List).map((json) => SavingsGoalModel.fromJson(json)).toList();
  }

  Future<void> addSavingsGoal(SavingsGoalModel goal) async {
    await _client.from('savings_goals').insert(goal.toJson());
  }

  Future<void> updateSavingsGoalProgress(String id, double currentAmount) async {
    await _client
        .from('savings_goals')
        .update({'current_amount': currentAmount})
        .eq('id', id);
  }

  // --- Auth ---
  User? get currentUser => _client.auth.currentUser;
  
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetUserData() async {
    final userId = currentUser?.id;
    if (userId == null) return;
    
    await _client.from('transactions').delete().eq('user_id', userId);
    await _client.from('savings_goals').delete().eq('user_id', userId);
  }

  // --- Profile ---
  Future<Map<String, dynamic>?> getProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    final response = await _client.from('profiles').select().eq('id', userId).maybeSingle();
    return response;
  }

  Future<void> updateProfile(String fullName) async {
    final userId = currentUser?.id;
    if (userId == null) return;
    await _client.from('profiles').upsert({
      'id': userId,
      'full_name': fullName,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
