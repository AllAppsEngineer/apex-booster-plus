import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../data/datasources/installed_apps_datasource.dart';
import '../../../domain/entities/installed_app.dart';
import 'tabs/inicio_tab.dart';
import 'tabs/biblioteca_tab.dart';
import 'tabs/preparar_tab.dart';
import 'tabs/historico_tab.dart';
import 'tabs/configuracoes_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      InstalledAppsDatasource().getInstalledApps().catchError((Object e) {
        debugPrint('[PERF-BIBLIO] warm-up erro: $e');
        return const <InstalledApp>[];
      });
    });
  }

  List<Widget> get _tabs => [
    InicioTab(isActive: _selectedIndex == 0),
    BibliotecaTab(isActive: _selectedIndex == 1),
    PrepararTab(isActive: _selectedIndex == 2),
    HistoricoTab(isActive: _selectedIndex == 3),
    const ConfiguracoesTab(),
  ];

  Future<bool> _onPopInvoked() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }

    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings(languageNotifier.value).navExitSnackBar),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }

    await SystemNavigator.pop();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onPopInvoked();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _selectedIndex,
          children: _tabs,
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return ListenableBuilder(
      listenable: languageNotifier,
      builder: (_, __) {
        final s = AppStrings(languageNotifier.value);
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1C1C1C),
                Color(0xFF0A0A0A),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: AppColors.apexGreen.withValues(alpha: 0.28),
                width: 0.8,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.apexGreen.withValues(alpha: 0.07),
                blurRadius: 24,
                offset: const Offset(0, -8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.apexGreen,
            unselectedItemColor: AppColors.textGray,
            currentIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
            selectedFontSize: 11,
            unselectedFontSize: 11,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: s.navHome,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.sports_esports_outlined),
                activeIcon: const Icon(Icons.sports_esports),
                label: s.navLibrary,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.flash_on_outlined),
                activeIcon: const Icon(Icons.flash_on),
                label: s.navPrepare,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history_outlined),
                activeIcon: const Icon(Icons.history),
                label: s.navHistory,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                activeIcon: const Icon(Icons.settings),
                label: s.navSettings,
              ),
            ],
          ),
        );
      },
    );
  }
}
