import 'package:shared_preferences/shared_preferences.dart';

import 'screen_capture_gallery_service.dart';

/// AUDIO-FALLBACK-UX-U1.1: identifies the video clip a pending audio-fallback
/// notice refers to, so the caller can mark it seen after showing it.
class PendingAudioFallbackNotice {
  final String clipId;
  const PendingAudioFallbackNotice({required this.clipId});
}

/// Decides whether the most recent recorded clip should trigger the "áudio
/// interno não disponível" bottom sheet — strictly narrower than "any video
/// saved without audio": the native side (ClipIndexMutator/ScreenCaptureService,
/// AUDIO-FALLBACK-UX-U1.1) only tags a clip audioOutcomeReason ==
/// SOURCE_SILENT_OR_UNAVAILABLE when the source itself delivered silence or
/// was unavailable — never for API_UNSUPPORTED, PERMISSION_DENIED,
/// TIMELINE_INELIGIBLE or PROCESSING_FAILURE, none of which the user can act
/// on by switching to the phone's screen recorder.
class AudioFallbackNoticeService {
  static const _seenClipIdKey = 'apex_audio_fallback_seen_clip_id';
  static const _sourceSilentOrUnavailable = 'SOURCE_SILENT_OR_UNAVAILABLE';
  static const _readyWithoutAudio = 'READY_WITHOUT_AUDIO';

  final ScreenCaptureGalleryService _galleryService;
  final Future<SharedPreferences> Function() _resolvePrefs;

  AudioFallbackNoticeService({
    ScreenCaptureGalleryService? galleryService,
    Future<SharedPreferences> Function()? resolvePrefs,
  })  : _galleryService = galleryService ?? ScreenCaptureGalleryService(),
        _resolvePrefs = resolvePrefs ?? SharedPreferences.getInstance;

  /// Returns the pending notice for the most recent video clip, or null when
  /// there is nothing to show — no video clip yet, the newest clip isn't the
  /// SOURCE_SILENT_OR_UNAVAILABLE case, or it was already shown once.
  Future<PendingAudioFallbackNotice?> checkPending() async {
    final captures = await _galleryService.listCaptures();
    final latestVideo = captures.firstWhere(
      (c) => c.isVideo,
      orElse: () => CapturedScreenshot(path: '', capturedAt: DateTime.now()),
    );
    if (latestVideo.path.isEmpty) return null;
    if (latestVideo.audioState != _readyWithoutAudio) return null;
    if (latestVideo.audioOutcomeReason != _sourceSilentOrUnavailable) {
      return null;
    }
    final clipId = latestVideo.id;
    if (clipId == null || clipId.isEmpty) return null;

    final prefs = await _resolvePrefs();
    if (prefs.getString(_seenClipIdKey) == clipId) return null;

    return PendingAudioFallbackNotice(clipId: clipId);
  }

  Future<void> markSeen(String clipId) async {
    final prefs = await _resolvePrefs();
    await prefs.setString(_seenClipIdKey, clipId);
  }
}
