import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'core/supabase_config.dart';
import 'core/app_theme.dart';
import 'providers/finance_provider.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OMyCashApp());
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
      // Initialize Supabase
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );

      // Initialize Notifications (Non-blocking if possible, but we wait for init)
      try {
        final notificationService = NotificationService();
        await notificationService.init();
        await notificationService.scheduleDailyReminder();
      } catch (e) {
        debugPrint('Notification Init Error (ignored for startup): $e');
      }
    } catch (e) {
      debugPrint('Critical Init Error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryColor),
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
              backgroundColor: AppTheme.backgroundColor,
              body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'Error de conexión: Verifica tu internet o la configuración de Supabase.\n\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ),
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FinanceProvider()),
          ],
          child: MaterialApp(
            title: 'O-myCash by ChrizDev',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const AuthGate(),
          ),
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
