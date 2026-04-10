import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/finance_provider.dart';
import '../core/app_theme.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = context.read<FinanceProvider>().userName;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final isDoingWell = provider.needsSpent <= (provider.totalIncome * 0.5) &&
                        provider.wantsSpent <= (provider.totalIncome * 0.3);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(LucideIcons.user, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre Completo',
                prefixIcon: Icon(LucideIcons.edit3),
              ),
              onSubmitted: (val) => provider.updateUserName(val),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => provider.updateUserName(_nameController.text),
              child: const Text('Guardar Nombre'),
            ),
            const SizedBox(height: 48),
            _CoachSection(isDoingWell: isDoingWell),
          ],
        ),
      ),
    );
  }
}

class _CoachSection extends StatelessWidget {
  final bool isDoingWell;
  const _CoachSection({required this.isDoingWell});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDoingWell ? Colors.green.withAlpha(20) : Colors.orange.withAlpha(20),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDoingWell ? Colors.green.withAlpha(50) : Colors.orange.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(
            isDoingWell ? LucideIcons.partyPopper : LucideIcons.lightbulb,
            color: isDoingWell ? Colors.green : Colors.orange,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            isDoingWell ? '¡Excelente Trabajo!' : 'Tips de Economía',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDoingWell ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isDoingWell
                ? 'Estás siguiendo la regla 50/30/20 a la perfección. Tus finanzas están bajo control y tu futuro está asegurado.'
                : 'Parece que estás excediendo tus límites en Deseos o Necesidades. Intenta reducir gastos hormiga y prioriza el ahorro del 20%.',
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.5, color: Colors.white70),
          ),
          if (!isDoingWell) ...[
            const SizedBox(height: 20),
            _TipItem(text: 'Evita las compras impulsivas esperando 24 horas.'),
            _TipItem(text: 'Revisa tus suscripciones mensuales no utilizadas.'),
            _TipItem(text: 'Cocina más en casa para reducir el gasto en ocio.'),
          ],
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;
  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(LucideIcons.checkCircle, size: 16, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.white60))),
        ],
      ),
    );
  }
}
