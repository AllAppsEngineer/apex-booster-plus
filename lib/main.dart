import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/i18n/app_language.dart';
import 'core/i18n/language_service.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  languageNotifier.value = LanguageService(prefs).load();
  runApp(const ApexBoosterApp());
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
