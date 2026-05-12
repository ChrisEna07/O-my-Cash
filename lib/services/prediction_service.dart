import '../models/transaction_model.dart';
import '../models/savings_goal_model.dart';

class PredictionService {
  /// Calculates the estimated completion date for a goal based on the average savings rate.
  static DateTime? estimateCompletionDate(
    SavingsGoalModel goal,
    List<TransactionModel> transactions,
  ) {
    if (goal.currentAmount >= goal.targetAmount) return DateTime.now();

    // Filtramos transacciones de tipo 'Ingreso' que fueron inyectadas a ahorros
    // O calculamos el ahorro promedio mensual/diario
    final savingsTransactions = transactions
        .where((t) => t.type == 'Ingreso' && t.ruleCategory == 'Ahorro')
        .toList();

    if (savingsTransactions.isEmpty) return null;

    // Calculamos el ahorro total y el tiempo transcurrido desde la primera transacción de ahorro
    double totalSaved = 0;
    for (var t in savingsTransactions) {
      totalSaved += t.amount;
    }

    final firstTransactionDate = savingsTransactions.last.createdAt;
    final daysElapsed = DateTime.now().difference(firstTransactionDate).inDays;

    if (daysElapsed <= 0) {
      // Si solo hay un día de datos, usamos el monto de esa transacción como ahorro diario
      double dailyRate = totalSaved;
      double remaining = goal.targetAmount - goal.currentAmount;
      int daysToGoal = (remaining / dailyRate).ceil();
      return DateTime.now().add(Duration(days: daysToGoal));
    }

    double dailyRate = totalSaved / daysElapsed;

    if (dailyRate <= 0) return null;

    double remaining = goal.targetAmount - goal.currentAmount;
    int daysToGoal = (remaining / dailyRate).ceil();

    // Limitamos la predicción a 10 años para evitar fechas absurdas
    if (daysToGoal > 3650) return null;

    return DateTime.now().add(Duration(days: daysToGoal));
  }

  /// Genera un consejo financiero basado en el cumplimiento de la regla actual.
  static String getSmartTip({
    required double needsLimit,
    required double wantsLimit,
    required double actualNeeds,
    required double actualWants,
    required String lang,
  }) {
    if (actualNeeds > needsLimit) {
      return lang == 'es' 
          ? 'Tus necesidades superan el límite. Intenta renegociar servicios o reducir gastos fijos.'
          : 'Your needs exceed the limit. Try renegotiating services or reducing fixed costs.';
    }
    if (actualWants > wantsLimit) {
      return lang == 'es'
          ? 'Has gastado mucho en deseos este mes. ¡Prioriza tu ahorro para alcanzar tus metas más rápido!'
          : 'You spent a lot on wants this month. Prioritize your savings to reach your goals faster!';
    }
    return lang == 'es'
        ? '¡Vas por excelente camino! Sigue manteniendo ese equilibrio financiero.'
        : 'You are on the right track! Keep maintaining that financial balance.';
  }
}
