import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/accessibility/low_distraction_service.dart';
import 'core/i18n/app_language.dart';
import 'core/i18n/language_service.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  final t0 = DateTime.now().millisecondsSinceEpoch;
  debugPrint('[PERF-STARTUP] main started');
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  debugPrint('[PERF-STARTUP] SP loaded: ${DateTime.now().millisecondsSinceEpoch - t0}ms');
  languageNotifier.value = LanguageService(prefs).load();
  lowDistractionNotifier.value = LowDistractionService(prefs).load();
  debugPrint('[PERF-STARTUP] runApp called: ${DateTime.now().millisecondsSinceEpoch - t0}ms');
  runApp(const ApexBoosterApp());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    debugPrint('[PERF-STARTUP] first frame rendered: ${DateTime.now().millisecondsSinceEpoch - t0}ms');
  });
}

class ApexBoosterApp extends StatelessWidget {
  const ApexBoosterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: languageNotifier,
      builder: (_, __) => MaterialApp.router(
        title: 'Apex Booster+',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: appRouter,
      ),
    );
  }
}
