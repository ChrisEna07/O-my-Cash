import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'core/supabase_config.dart';
import 'core/app_theme.dart';
import 'providers/finance_provider.dart';
import 'providers/settings_provider.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'views/onboarding_view.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
      ],
      child: const OMyCashApp(),
    ),
  );
}

class OMyCashApp extends StatefulWidget {
  const OMyCashApp({super.key});

  @override
  State<OMyCashApp> createState() => _OMyCashAppState();
}

class _OMyCashAppState extends State<OMyCashApp> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _startApp();
  }

  Future<void> _startApp() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      
      try {
        final notificationService = NotificationService();
        await notificationService.init();
        await notificationService.scheduleDailyReminder();
      } catch (e) {
        debugPrint('Notification Init Error: $e');
      }
    } catch (e) {
      debugPrint('Critical Init Error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(settings.primaryColor, settings.themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light),
            home: const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 24),
                    Text('Iniciando O-myCash...', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error de conexión: ${snapshot.error}')),
            ),
          );
        }

        return MaterialApp(
          title: 'O-myCash by ChrizDev',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(settings.primaryColor, Brightness.light),
          darkTheme: AppTheme.getTheme(settings.primaryColor, Brightness.dark),
          themeMode: settings.themeMode,
          home: settings.isFirstTime ? const OnboardingView() : const AuthGate(),
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final currentSession = Supabase.instance.client.auth.currentSession;

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && currentSession == null) {
           return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        final session = snapshot.hasData ? snapshot.data!.session : currentSession;

        if (session != null) {
          return const HomeView();
        } else {
          return const LoginView();
        }
      },
    );
  }
}
