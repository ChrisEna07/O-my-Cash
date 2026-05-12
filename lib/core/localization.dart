class L10n {
  static const Map<String, Map<String, String>> _strings = {
    'es': {
      'settings': 'Ajustes',
      'language': 'Idioma',
      'export': 'Exportar Respaldo (JSON)',
      'import': 'Importar Respaldo (JSON)',
      'pdf': 'Descargar Resumen (PDF)',
      'personalization': 'Personalización',
      'tutorial': 'Repetir Tutorial',
      'color': 'Color de Acento',
      'backup': 'Respaldo y Reportes',
      'dev': 'Desarrollador',
      'success_export': 'Respaldo exportado con éxito',
      'success_import': 'Datos restaurados con éxito',
      'error': 'Ocurrió un error',
    },
    'en': {
      'settings': 'Settings',
      'language': 'Language',
      'export': 'Export Backup (JSON)',
      'import': 'Import Backup (JSON)',
      'pdf': 'Download Summary (PDF)',
      'personalization': 'Personalization',
      'tutorial': 'Repeat Tutorial',
      'color': 'Accent Color',
      'backup': 'Backup & Reports',
      'dev': 'Developer',
      'success_export': 'Backup exported successfully',
      'success_import': 'Data restored successfully',
      'error': 'An error occurred',
    }
  };

  static String tr(String lang, String key) {
    return _strings[lang]?[key] ?? key;
  }
}
