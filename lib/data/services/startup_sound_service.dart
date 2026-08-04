import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

/// Minimal player surface [StartupSoundService] depends on, so tests can
/// inject a fake without touching the audioplayers platform channel.
abstract class StartupAudioPlayer {
  Future<void> setReleaseMode(ReleaseMode mode);
  Future<void> setVolume(double volume);
  Future<void> setAudioContext(AudioContext context);
  Future<void> play(Source source);
  Stream<void> get onPlayerComplete;
  Future<void> dispose();
}

class _AudioPlayersAdapter implements StartupAudioPlayer {
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> setReleaseMode(ReleaseMode mode) =>
      _player.setReleaseMode(mode);

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> setAudioContext(AudioContext context) =>
      _player.setAudioContext(context);

  @override
  Future<void> play(Source source) => _player.play(source);

  @override
  Stream<void> get onPlayerComplete => _player.onPlayerComplete;

  @override
  Future<void> dispose() => _player.dispose();
}

/// STARTUP-SOUND-U1: plays the Apex opening sound once per instance/process,
/// right after the first Flutter frame. Placebo-honest — it is a UI sound
/// effect, never blocks the app and never lets a failure surface: missing
/// asset, platform error or a muted device all fall back to silence.
class StartupSoundService {
  static const _assetPath = 'audio/robot_audio_apex_startup.wav';
  static const _volume = 0.70;

  final StartupAudioPlayer Function() _playerFactory;

  bool _hasPlayed = false;

  StartupSoundService({StartupAudioPlayer Function()? playerFactory})
      : _playerFactory = playerFactory ?? (() => _AudioPlayersAdapter());

  Future<void> playOnce() async {
    if (_hasPlayed) return;
    _hasPlayed = true;

    final player = _playerFactory();
    StreamSubscription<void>? subscription;
    var disposed = false;
    Future<void> disposeOnce() async {
      if (disposed) return;
      disposed = true;
      await subscription?.cancel();
      await player.dispose();
    }

    try {
      subscription = player.onPlayerComplete.listen(
        (_) => disposeOnce(),
        onError: (_) => disposeOnce(),
      );
      await player.setReleaseMode(ReleaseMode.release);
      await player.setVolume(_volume);
      await player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.assistanceSonification,
            audioFocus: AndroidAudioFocus.none,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {AVAudioSessionOptions.mixWithOthers},
          ),
        ),
      );
      await player.play(AssetSource(_assetPath));
    } catch (_) {
      await disposeOnce();
    }
  }
}
