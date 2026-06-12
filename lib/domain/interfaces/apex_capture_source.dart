// Architecture hook for SOCIAL-U6 (Apex Floating Capture Button).
// Implement when that phase is approved — do not instantiate here.
abstract interface class ApexCaptureSource {
  /// Returns the local file path of the captured media, or null if cancelled.
  Future<String?> captureMedia();
}

/// Stub for SOCIAL-U2B (MediaProjection). Only [gallery] is used in U2A.
enum CaptureMethod { gallery, mediaProjection }
