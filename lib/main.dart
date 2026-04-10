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
  
  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.scheduleDailyReminder();

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
    _initFuture = _initializeSupabase();
  }

  Future<void> _initializeSupabase() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
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
              body: const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error al inicializar: ${snapshot.error}')),
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
    // We check both the stream and the current session for robustness
    final currentSession = Supabase.instance.client.auth.currentSession;

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
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
