import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/finance_provider.dart';
import '../models/transaction_model.dart';
import '../core/app_theme.dart';
import 'transaction_form_view.dart';
import 'savings_goals_view.dart';
import 'profile_view.dart';
import '../services/supabase_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().fetchData();
    });
  }

  Future<void> _showAdminDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Reset'),
        content: const Text('¿Estás seguro de borrar todos los datos?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await context.read<FinanceProvider>().resetAllData();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Confirmar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.userName.isEmpty ? '¡Hola!' : '¡Hola, ${provider.userName}!',
              style: const TextStyle(fontSize: 14, color: Colors.white54),
            ),
            const Text('O-myCash', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 20, color: Colors.white24),
            onPressed: () => _showAdminDialog(context),
          ),
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            onPressed: () async {
              await SupabaseService().signOut();
            },
          ),
        ],
      ),
      body: provider.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => provider.fetchData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _BalanceCard(currencyFormat: currencyFormat, provider: provider),
                  const SizedBox(height: 24),
                  _RuleStatusWidget(provider: provider, currencyFormat: currencyFormat),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transacciones Recientes', style: Theme.of(context).textTheme.titleLarge),
                      TextButton(onPressed: () {}, child: const Text('Ver todas')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.transactions.take(5).length,
                    itemBuilder: (context, index) {
                      final tx = provider.transactions[index];
                      return _TransactionTile(tx: tx, currencyFormat: currencyFormat);
                    },
                  ),
                ],
              ),
            ),
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionFormView())),
        label: const Text('Nuevo Registro'),
        icon: const Icon(LucideIcons.plus),
        backgroundColor: AppTheme.primaryColor,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.surfaceColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.white54,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.layoutDashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.target), label: 'Metas'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Perfil'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsGoalsView()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileView()));
          }
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.currencyFormat,
    required this.provider,
  });

  final NumberFormat currencyFormat;
  final FinanceProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withAlpha(76), // 0.3 * 255 approx 76
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Balance Total', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(provider.balance),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BalanceInfo(
                icon: LucideIcons.arrowUpCircle,
                label: 'Ingresos',
                amount: currencyFormat.format(provider.totalIncome),
                color: Colors.green,
              ),
              _BalanceInfo(
                icon: LucideIcons.arrowDownCircle,
                label: 'Gastos',
                amount: currencyFormat.format(provider.totalExpenses),
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color color;

  const _BalanceInfo({required this.icon, required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _RuleStatusWidget extends StatelessWidget {
  final FinanceProvider provider;
  final NumberFormat currencyFormat;

  const _RuleStatusWidget({required this.provider, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    final income = provider.totalIncome == 0 ? 1.0 : provider.totalIncome;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Distribución 50/30/20', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildRuleBar('Necesidades (50%)', provider.needsSpent, income * 0.5, Colors.blue),
        const SizedBox(height: 12),
        _buildRuleBar('Deseos (30%)', provider.wantsSpent, income * 0.3, Colors.orange),
        const SizedBox(height: 12),
        _buildRuleBar('Ahorro/Inversión (20%)', provider.savingsSpent, income * 0.2, Colors.green),
      ],
    );
  }

  Widget _buildRuleBar(String title, double current, double limit, Color color) {
    final percent = (current / limit).clamp(0.0, 1.0);
    final isOver = current > limit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            Text('${currencyFormat.format(current)} / ${currencyFormat.format(limit)}', 
              style: TextStyle(fontSize: 12, color: isOver ? Colors.redAccent : Colors.white60)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(isOver ? Colors.redAccent : color),
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  final NumberFormat currencyFormat;

  const _TransactionTile({required this.tx, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == TransactionType.income;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isIncome ? Colors.green.withAlpha(25) : Colors.red.withAlpha(25), // 0.1 * 255 approx 25
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? LucideIcons.trendingUp : LucideIcons.shoppingCart,
              color: isIncome ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(DateFormat.MMMd().format(tx.createdAt), style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${currencyFormat.format(tx.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
