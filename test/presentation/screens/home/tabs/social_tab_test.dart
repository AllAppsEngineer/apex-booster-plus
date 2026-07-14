import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
