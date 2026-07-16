import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';
import 'package:apex_booster_plus/presentation/screens/home/tabs/social_tab.dart';

const _overlayChannel = MethodChannel('apex/overlay');
const _captureChannel = MethodChannel('apex/capture');

void _mockChannels() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_overlayChannel, (call) async {
    switch (call.method) {
      case 'isOverlayPermissionGranted':
        return false;
      case 'isFloatingShowing':
        return false;
      default:
        return null;
    }
  });
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_captureChannel, (call) async {
    if (call.method == 'isSessionArmed') return false;
    return null;
  });
}

void _clearChannels() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_overlayChannel, null);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_captureChannel, null);
}

ApexGame _game(String id, String name) => ApexGame(
      id: id,
      name: name,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  setUp(_mockChannels);
  tearDown(_clearChannels);

  testWidgets(
      'SocialTab mostra Modo Captura da Sessão, Criar Card e estado vazio sem jogos',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SocialTab(isActive: true))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Modo Captura da Sessão'), findsOneWidget);
    expect(find.text('Criar card'), findsOneWidget);
    expect(
      find.text('Adicione um jogo na Biblioteca para criar um card.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('SocialTab lista jogos existentes para criar card',
      (tester) async {
    final encoded = jsonEncode([_game('g1', 'Free Fire').toJson()]);
    SharedPreferences.setMockInitialValues({'apex_game_library': encoded});

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SocialTab(isActive: true))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Free Fire'), findsOneWidget);
    expect(
      find.text('Adicione um jogo na Biblioteca para criar um card.'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'SocialTab shows Criar novo card CTA above the quick access game list',
      (tester) async {
    final encoded = jsonEncode([_game('g1', 'Free Fire').toJson()]);
    SharedPreferences.setMockInitialValues({'apex_game_library': encoded});

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SocialTab(isActive: true))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Criar novo card'), findsOneWidget);
    expect(find.text('Acesso rápido'.toUpperCase()), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SocialTab does not show Criar novo card CTA with no games',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SocialTab(isActive: true))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Criar novo card'), findsNothing);
  });

  testWidgets(
      'SocialTab CTA opens Studio directly when only one game exists',
      (tester) async {
    final encoded = jsonEncode([_game('g1', 'Free Fire').toJson()]);
    SharedPreferences.setMockInitialValues({'apex_game_library': encoded});

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: SocialTab(isActive: true)),
        ),
        GoRoute(
          path: '/share-studio/:gameId',
          builder: (context, state) => Scaffold(
            body: Text('studio:${state.pathParameters['gameId']}'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Criar novo card'));
    await tester.pumpAndSettle();

    expect(find.text('studio:g1'), findsOneWidget);
  });

  testWidgets(
      'SocialTab CTA opens game chooser sheet reusing the game list when multiple games exist',
      (tester) async {
    final encoded = jsonEncode([
      _game('g1', 'Free Fire').toJson(),
      _game('g2', 'Valorant').toJson(),
    ]);
    SharedPreferences.setMockInitialValues({'apex_game_library': encoded});

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SocialTab(isActive: true))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Criar novo card'));
    await tester.pumpAndSettle();

    expect(find.text('Escolher jogo'), findsOneWidget);
    expect(find.text('Free Fire'), findsNWidgets(2));
    expect(find.text('Valorant'), findsNWidgets(2));
  });
}
