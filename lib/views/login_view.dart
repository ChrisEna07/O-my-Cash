import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../core/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabaseService = SupabaseService();
  bool _loading = false;
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _emailController.text = prefs.getString('saved_email') ?? '';
      });
    }
  }

  Future<void> _handleAuth() async {
    setState(() => _loading = true);
    try {
      if (_isSignUp) {
        await _supabaseService.signUp(_emailController.text, _passwordController.text);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check your email for confirmation!')));
      } else {
        await _supabaseService.signIn(_emailController.text, _passwordController.text);
        // Save email for next time
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', _emailController.text);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.backgroundColor, Color(0xFF1E1B4B)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.account_balance_wallet_rounded, size: 80, color: AppTheme.primaryColor),
                const SizedBox(height: 16),
                Text(
                  'O-myCash',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                ),
                Text(
                  'by ChrizDev',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline)),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _loading ? null : _handleAuth,
                  child: _loading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_isSignUp ? 'Crear Cuenta' : 'Iniciar Sesión'),
                ),
                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(_isSignUp ? '¿Ya tienes cuenta? Ingresa' : '¿No tienes cuenta? Registrate'),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton(
                onPressed: _showAdminDialog,
                child: const Text('Configuración Admin', style: TextStyle(color: Colors.white30, fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdminDialog() {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Reset'),
        content: TextField(
          controller: passController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (passController.text == 'ChrizDev073008') {
                try {
                   final userId = _supabaseService.currentUser?.id;
                   if (userId != null) {
                     await _supabaseService.resetUserData();
                     if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data Reset Successful')));
                     }
                   } else {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: No session')));
                   }
                } catch (e) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('RESET ALL DATA'),
          ),
        ],
      ),
    );
  }
}
