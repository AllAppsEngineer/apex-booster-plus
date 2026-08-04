import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/data/services/startup_sound_service.dart';

class _FakeAudioPlayer implements StartupAudioPlayer {
  late final StreamController<void> _completeController;

  int playCalls = 0;
  int disposeCalls = 0;
  double? lastVolume;
  ReleaseMode? lastReleaseMode;
  AudioContext? lastContext;
  Source? lastSource;
  bool listenerCancelled = false;
  bool throwOnPlay = false;

  _FakeAudioPlayer() {
    _completeController = StreamController<void>.broadcast(
      onCancel: () => listenerCancelled = true,
    );
  }

  @override
  Future<void> setReleaseMode(ReleaseMode mode) async {
    lastReleaseMode = mode;
  }

  @override
  Future<void> setVolume(double volume) async {
    lastVolume = volume;
  }

  @override
  Future<void> setAudioContext(AudioContext context) async {
    lastContext = context;
  }

  @override
  Future<void> play(Source source) async {
    playCalls++;
    lastSource = source;
    if (throwOnPlay) {
      throw Exception('simulated platform failure');
    }
  }

  @override
  Stream<void> get onPlayerComplete => _completeController.stream;

  @override
  Future<void> dispose() async {
    disposeCalls++;
  }

  void completeNow() => _completeController.add(null);
}

void main() {
  group('StartupSoundService', () {
    test('plays only once even after two attempts', () async {
      final fake = _FakeAudioPlayer();
      var factoryCalls = 0;
      final service = StartupSoundService(
        playerFactory: () {
          factoryCalls++;
          return fake;
        },
      );

      await service.playOnce();
      await service.playOnce();

      expect(factoryCalls, 1);
      expect(fake.playCalls, 1);
    });

    test('sets volume to 0.70', () async {
      final fake = _FakeAudioPlayer();
      final service = StartupSoundService(playerFactory: () => fake);

      await service.playOnce();

      expect(fake.lastVolume, 0.70);
    });

    test('plays the exact startup asset path', () async {
      final fake = _FakeAudioPlayer();
      final service = StartupSoundService(playerFactory: () => fake);

      await service.playOnce();

      expect(fake.lastSource, isA<AssetSource>());
      expect(
        (fake.lastSource as AssetSource).path,
        'audio/robot_audio_apex_startup.wav',
      );
    });

    test('never loops', () async {
      final fake = _FakeAudioPlayer();
      final service = StartupSoundService(playerFactory: () => fake);

      await service.playOnce();

      expect(fake.lastReleaseMode, isNot(ReleaseMode.loop));
      expect(fake.lastReleaseMode, ReleaseMode.release);
    });

    test('swallows a failure from play() without rethrowing', () async {
      final fake = _FakeAudioPlayer()..throwOnPlay = true;
      final service = StartupSoundService(playerFactory: () => fake);

      await expectLater(service.playOnce(), completes);
    });

    test('disposes the player after a normal completion', () async {
      final fake = _FakeAudioPlayer();
      final service = StartupSoundService(playerFactory: () => fake);

      await service.playOnce();
      fake.completeNow();
      await Future<void>.delayed(Duration.zero);

      expect(fake.disposeCalls, 1);
    });

    test('disposes the player when play() fails', () async {
      final fake = _FakeAudioPlayer()..throwOnPlay = true;
      final service = StartupSoundService(playerFactory: () => fake);

      await service.playOnce();

      expect(fake.disposeCalls, 1);
    });

    test('cancels the completion listener on dispose', () async {
      final fake = _FakeAudioPlayer();
      final service = StartupSoundService(playerFactory: () => fake);

      await service.playOnce();
      fake.completeNow();
      await Future<void>.delayed(Duration.zero);

      expect(fake.listenerCancelled, true);
    });

    test('registers the startup asset in pubspec.yaml', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(
        pubspec.contains('assets/audio/robot_audio_apex_startup.wav'),
        true,
      );
    });
  });
}
