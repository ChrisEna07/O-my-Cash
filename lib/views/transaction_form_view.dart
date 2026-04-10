import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/finance_provider.dart';
import '../models/transaction_model.dart';
import '../services/supabase_service.dart';
import '../core/app_theme.dart';

class TransactionFormView extends StatefulWidget {
  const TransactionFormView({super.key});

  @override
  State<TransactionFormView> createState() => _TransactionFormViewState();
}

class _TransactionFormViewState extends State<TransactionFormView> {
  final _amountController = TextEditingController();
  final _otherCategoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  String _category = 'Comida';
  RuleCategory _ruleCategory = RuleCategory.need;
  String? _selectedGoalId;
  bool _isLoading = false;

  final Map<String, List<String>> _categoriesByRule = {
    'need': ['Arriendo', 'Comida', 'Servicios', 'Transporte'],
    'want': ['Ocio', 'Ropa', 'Calzado', 'Restaurantes', 'Otro'],
    'save': ['Ahorro Directo', 'Inversión', 'Fondo Emergencia'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Transacción')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tipo de Transacción', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _TypeChip(
                  label: 'Ingreso',
                  selected: _type == TransactionType.income,
                  icon: LucideIcons.trendingUp,
                  color: Colors.green,
                  onSelected: () => setState(() {
                    _type = TransactionType.income;
                    _ruleCategory = RuleCategory.save;
                    _category = _categoriesByRule['save']!.first;
                  }),
                ),
                const SizedBox(width: 12),
                _TypeChip(
                  label: 'Gasto',
                  selected: _type == TransactionType.expense,
                  icon: LucideIcons.trendingDown,
                  color: Colors.red,
                  onSelected: () => setState(() {
                    _type = TransactionType.expense;
                    _ruleCategory = RuleCategory.need;
                    _category = _categoriesByRule['need']!.first;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixIcon: Icon(LucideIcons.dollarSign),
              ),
            ),
            if (_type == TransactionType.income) ...[
               const SizedBox(height: 24),
               const Text('¿A dónde va este ingreso?', style: TextStyle(fontWeight: FontWeight.bold)),
               const SizedBox(height: 12),
               Consumer<FinanceProvider>(
                 builder: (context, provider, child) {
                   return DropdownButtonFormField<String>(
                     decoration: const InputDecoration(labelText: 'Asignar a Meta (Opcional)'),
                     items: [
                       const DropdownMenuItem(value: 'none', child: Text('Saldo General (Dashboard)')),
                       ...provider.goals.map((g) => DropdownMenuItem(value: g.id, child: Text(g.goalName))),
                     ],
                     onChanged: (val) => setState(() => _selectedGoalId = val == 'none' ? null : val),
                   );
                 },
               ),
            ],
            if (_type == TransactionType.expense) ...[
              const SizedBox(height: 24),
              const Text('Categoría de la Regla (50/30/20)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<RuleCategory>(
                key: ValueKey('rule_${_type.name}'),
                value: _ruleCategory,
                items: RuleCategory.values.map((v) {
                  String label = v == RuleCategory.need ? 'Necesidad (50%)' : v == RuleCategory.want ? 'Deseo (30%)' : 'Ahorro (20%)';
                  return DropdownMenuItem(value: v, child: Text(label));
                }).toList(),
                onChanged: (val) => setState(() {
                  _ruleCategory = val!;
                  _category = _categoriesByRule[val.name]!.first;
                }),
              ),
              const SizedBox(height: 24),
              const Text('Categoría Detallada', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey('cat_${_ruleCategory.name}'),
                value: _category,
                items: _categoriesByRule[_ruleCategory.name]!.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              if (_category == 'Otro') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _otherCategoryController,
                  decoration: const InputDecoration(labelText: '¿Qué gasto es?'),
                ),
              ],
            ],
            const SizedBox(height: 24),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (Opcional)',
                prefixIcon: Icon(LucideIcons.textCursorInput),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveTransaction,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Guardar Transacción'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);
    final userId = SupabaseService().currentUser?.id;
    
    if (userId == null) return;

    final tx = TransactionModel(
      userId: userId,
      amount: amount,
      type: _type,
      category: _category == 'Otro' ? _otherCategoryController.text : _category,
      ruleCategory: _type == TransactionType.income ? RuleCategory.save : _ruleCategory,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      createdAt: DateTime.now(),
    );

    try {
      await context.read<FinanceProvider>().addTransaction(tx);
      if (_type == TransactionType.income && _selectedGoalId != null) {
        await context.read<FinanceProvider>().injectToGoal(_selectedGoalId!, amount);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData icon;
  final Color color;
  final VoidCallback onSelected;

  const _TypeChip({required this.label, required this.selected, required this.icon, required this.color, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onSelected,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? color : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? color : Colors.white10),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? Colors.white : color),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? Colors.white : Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
