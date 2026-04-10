import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/settings_provider.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Bienvenido a O-myCash',
      'desc': 'Gestiona tus finanzas personales de forma premium y sencilla.',
      'icon': LucideIcons.gem,
    },
    {
      'title': 'Dashboard Principal',
      'desc': 'Aquí verás tu balance total y cómo vas con la regla 50/30/20. Los colores te indicarán si estás cumpliendo tus límites.',
      'icon': LucideIcons.layoutDashboard,
    },
    {
      'title': 'Registra tus Movimientos',
      'desc': 'Usa el botón "+" para agregar ingresos o gastos. Puedes categorizarlos para que el Coach Financiero te dé mejores consejos.',
      'icon': LucideIcons.plusCircle,
    },
    {
      'title': 'Metas de Ahorro',
      'desc': 'Crea metas con fecha límite. Al registrar un ingreso, puedes inyectarlo directamente a una meta para verla crecer.',
      'icon': LucideIcons.target,
    },
    {
      'title': 'Tu Perfil y Coach',
      'desc': 'Personaliza tu nombre y foto. Recibe consejos automáticos basados en tus hábitos de gasto reales.',
      'icon': LucideIcons.user,
    },
    {
      'title': 'Ajustes y Estilo',
      'desc': 'Cambia el color de la app y el tema (claro/oscuro) desde el engranaje superior. ¡Hazla tuya!',
      'icon': LucideIcons.settings,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _pages.length,
                itemBuilder: (context, idx) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_pages[idx]['icon'], size: 100, color: primary),
                        const SizedBox(height: 48),
                        Text(
                          _pages[idx]['title'],
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _pages[idx]['desc'],
                          style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (idx) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == idx ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == idx ? primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  _currentPage == _pages.length - 1
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(minimumSize: const Size(120, 50)),
                          onPressed: () {
                            context.read<SettingsProvider>().setFirstTime(false);
                          },
                          child: const Text('Comenzar'),
                        )
                      : IconButton(
                          onPressed: () => _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease),
                          icon: const Icon(LucideIcons.arrowRightCircle, size: 40),
                          color: primary,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
