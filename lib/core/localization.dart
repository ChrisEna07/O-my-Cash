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
      'security': 'Seguridad',
      'biometrics': 'Bloqueo Biométrico',
      'cloud_sync': 'Sincronización en la Nube',
      'sync_drive': 'Sincronizar con Google Drive',
      'sync_success': 'Sincronización completada con éxito',
      'sync_error': 'Error al sincronizar con la nube',
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
      'security': 'Security',
      'biometrics': 'Biometric Lock',
      'cloud_sync': 'Cloud Synchronization',
      'sync_drive': 'Sync with Google Drive',
      'sync_success': 'Synchronization completed successfully',
      'sync_error': 'Error syncing with cloud',
    }
  };

  static String tr(String lang, String key) {
    return _strings[lang]?[key] ?? key;
  }
}
