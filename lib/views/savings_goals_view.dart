import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/finance_provider.dart';
import '../models/savings_goal_model.dart';
import '../core/app_theme.dart';
import '../services/prediction_service.dart';

class SavingsGoalsView extends StatelessWidget {
  const SavingsGoalsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Metas de Ahorro')),
      body: provider.goals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(LucideIcons.target, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text('No tienes metas aún', style: TextStyle(color: Colors.white54)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: provider.goals.length,
              itemBuilder: (context, index) {
                final goal = provider.goals[index];
                return _GoalCard(goal: goal, currencyFormat: currencyFormat);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? selectedDeadline;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nueva Meta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre de la meta')),
              const SizedBox(height: 12),
              TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monto objetivo')),
              const SizedBox(height: 12),
              ListTile(
                title: Text(selectedDeadline == null ? 'Fecha Límite (Opcional)' : 'Meta para: ${DateFormat.yMMMd().format(selectedDeadline!)}'),
                leading: const Icon(LucideIcons.calendar),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDeadline = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final amountStr = amountController.text.replaceAll(',', '.').trim();
                final amount = double.tryParse(amountStr);
                
                if (name.isEmpty) {
                  AppTheme.showCustomSnackBar(context, 'Por favor, ingresa un nombre.', isError: true);
                  return;
                }
                if (amount == null || amount <= 0) {
                  AppTheme.showCustomSnackBar(context, 'Monto inválido.', isError: true);
                  return;
                }

                try {
                  await context.read<FinanceProvider>().addGoal(
                    SavingsGoalModel(userId: 'local_user', goalName: name, targetAmount: amount, deadline: selectedDeadline),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    AppTheme.showCustomSnackBar(context, 'Meta creada con éxito');
                  }
                } catch (e) {
                  if (context.mounted) AppTheme.showCustomSnackBar(context, 'Error al crear meta', isError: true);
                }
              },
              child: const Text('Crear Meta'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoalModel goal;
  final NumberFormat currencyFormat;

  const _GoalCard({required this.goal, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final progress = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    
    final estimatedDate = PredictionService.estimateCompletionDate(goal, provider.transactions);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.goalName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (goal.deadline != null)
                      Text('Límite: ${DateFormat.yMMMd().format(goal.deadline!)}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                  ],
                ),
              ),
              Icon(LucideIcons.award, color: progress == 1 ? Theme.of(context).colorScheme.secondary : Colors.white24),
            ],
          ),
          if (estimatedDate != null && progress < 1) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.sparkles, size: 14, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Predicción: ${DateFormat.yMMMd().format(estimatedDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(currencyFormat.format(goal.currentAmount), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
              Text(currencyFormat.format(goal.targetAmount), style: const TextStyle(color: Colors.white54)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress * 100).toStringAsFixed(0)}% completado', style: const TextStyle(fontSize: 12, color: Colors.white54)),
              Row(
                children: [
                   IconButton(
                    icon: const Icon(LucideIcons.edit, size: 20, color: Colors.white54),
                    onPressed: () => _showEditGoalDialog(context, goal),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 20, color: Colors.redAccent),
                    onPressed: () => _showDeleteConfirm(context, goal),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, SavingsGoalModel goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Meta'),
        content: const Text('¿Estás seguro de que quieres eliminar esta meta?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await context.read<FinanceProvider>().deleteGoal(goal.id!);
              if (context.mounted) {
                Navigator.pop(context);
                AppTheme.showCustomSnackBar(context, 'Meta eliminada');
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, SavingsGoalModel goal) {
    final nameController = TextEditingController(text: goal.goalName);
    final amountController = TextEditingController(text: goal.targetAmount.toString());
    DateTime? selectedDeadline = goal.deadline;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Meta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre de la meta')),
              const SizedBox(height: 12),
              TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monto objetivo')),
              const SizedBox(height: 12),
              ListTile(
                title: Text(selectedDeadline == null ? 'Seleccionar Fecha Límite' : 'Meta para: ${DateFormat.yMMMd().format(selectedDeadline!)}'),
                leading: const Icon(LucideIcons.calendar),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDeadline = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final amountStr = amountController.text.replaceAll(',', '.').trim();
                final amount = double.tryParse(amountStr);
                if (name.isNotEmpty && amount != null) {
                  await context.read<FinanceProvider>().updateGoal(goal.id!, {
                    'goal_name': name,
                    'target_amount': amount,
                    'deadline': selectedDeadline?.toIso8601String(),
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    AppTheme.showCustomSnackBar(context, 'Meta actualizada con éxito');
                  }
                } else {
                  AppTheme.showCustomSnackBar(context, 'Datos inválidos', isError: true);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
