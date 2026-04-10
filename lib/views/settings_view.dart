import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/settings_provider.dart';
import '../core/app_theme.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _DeveloperInfo(),
          const SizedBox(height: 32),
          _SectionTitle(title: 'Personalización'),
          const SizedBox(height: 16),
          const Text('Color de Acento', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _ColorOption(color: const Color(0xFF6366F1)),
                _ColorOption(color: const Color(0xFFF43F5E)),
                _ColorOption(color: const Color(0xFF10B981)),
                _ColorOption(color: const Color(0xFFF59E0B)),
                _ColorOption(color: const Color(0xFF8B5CF6)),
                _ColorOption(color: const Color(0xFF06B6D4)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _SectionTitle(title: 'Guía y Tutorial'),
          ListTile(
            leading: const Icon(LucideIcons.repeat),
            title: const Text('Repetir Tutorial Inicial'),
            onTap: () async {
              await settings.setFirstTime(true);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 32),
          const Center(
            child: Text(
              'O-myCash v1.0.0',
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  const _ColorOption({required this.color});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    final isSelected = settings.primaryColor.value == color.value;
    
    return GestureDetector(
      onTap: () => settings.setPrimaryColor(color),
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        ),
        child: isSelected ? const Icon(LucideIcons.check, color: Colors.white) : null,
      ),
    );
  }
}

class _DeveloperInfo extends StatelessWidget {
  const _DeveloperInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: const Icon(LucideIcons.code2, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text('Desarrollado por', style: TextStyle(fontSize: 12, color: Colors.white54)),
          const Text(
            'ChrizDev',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.5),
    );
  }
}
