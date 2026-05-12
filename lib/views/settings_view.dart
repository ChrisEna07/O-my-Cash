import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/finance_provider.dart';
import '../services/local_database_service.dart';
import '../services/pdf_service.dart';
import '../core/app_theme.dart';
import '../core/localization.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  Future<void> _showAdminDialog(BuildContext context, String lang) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Datos'),
        content: const Text('¿Estás seguro de borrar todos los datos permanentemente?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await context.read<FinanceProvider>().resetAllData();
              if (context.mounted) {
                Navigator.pop(context);
                AppTheme.showCustomSnackBar(context, 'Datos eliminados correctamente');
              }
            },
            child: const Text('Confirmar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final lang = settings.languageCode;
    
    return Scaffold(
      appBar: AppBar(title: Text(L10n.tr(lang, 'settings'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _DeveloperInfo(lang: lang),
          const SizedBox(height: 32),
          
          _SectionTitle(title: L10n.tr(lang, 'language')),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Español'),
                  value: 'es',
                  groupValue: lang,
                  onChanged: (val) => settings.setLanguage(val!),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('English'),
                  value: 'en',
                  groupValue: lang,
                  onChanged: (val) => settings.setLanguage(val!),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          _SectionTitle(title: L10n.tr(lang, 'backup')),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(LucideIcons.fileJson, color: Colors.blue),
            title: Text(L10n.tr(lang, 'export')),
            onTap: () async {
              try {
                final jsonStr = await LocalDatabaseService().exportDataToJson();
                final dir = await getApplicationDocumentsDirectory();
                final file = File('${dir.path}/omycash_backup.json');
                await file.writeAsString(jsonStr);
                await Share.shareXFiles([XFile(file.path)], text: 'Mi respaldo de O-myCash');
                if (context.mounted) AppTheme.showCustomSnackBar(context, L10n.tr(lang, 'success_export'));
              } catch (e) {
                if (context.mounted) AppTheme.showCustomSnackBar(context, L10n.tr(lang, 'error'), isError: true);
              }
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.uploadCloud, color: Colors.orange),
            title: Text(L10n.tr(lang, 'import')),
            onTap: () async {
              try {
                final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
                if (result != null && result.files.single.path != null) {
                  final file = File(result.files.single.path!);
                  final jsonStr = await file.readAsString();
                  if (context.mounted) {
                    await context.read<FinanceProvider>().importDataFromJson(jsonStr);
                    AppTheme.showCustomSnackBar(context, L10n.tr(lang, 'success_import'));
                  }
                }
              } catch (e) {
                if (context.mounted) AppTheme.showCustomSnackBar(context, L10n.tr(lang, 'error'), isError: true);
              }
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.fileText, color: Colors.redAccent),
            title: Text(L10n.tr(lang, 'pdf')),
            onTap: () async {
              if (context.mounted) {
                final provider = context.read<FinanceProvider>();
                await PdfService.generateAndPrintSummary(provider);
              }
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.trash2, color: Colors.redAccent),
            title: const Text('Limpiar Base de Datos', style: TextStyle(color: Colors.redAccent)),
            onTap: () => _showAdminDialog(context, lang),
          ),

          const SizedBox(height: 32),
          _SectionTitle(title: L10n.tr(lang, 'personalization')),
          const SizedBox(height: 16),
          Text(L10n.tr(lang, 'color'), style: const TextStyle(fontWeight: FontWeight.bold)),
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
          _SectionTitle(title: L10n.tr(lang, 'tutorial')),
          ListTile(
            leading: const Icon(LucideIcons.repeat),
            title: Text(L10n.tr(lang, 'tutorial')),
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
  final String lang;
  const _DeveloperInfo({required this.lang});

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
          Text(L10n.tr(lang, 'dev'), style: const TextStyle(fontSize: 12, color: Colors.white54)),
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
