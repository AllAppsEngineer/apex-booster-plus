package com.allappsengineer.apex_booster_plus

import android.util.Log

/**
 * RELEASE-LOG-HARDENING-D1: single policy point for the audio-capture
 * pipeline's diagnostic log fragments (absolute paths, buffer/sample
 * counters) and fallback-error stack traces. Release builds never carry
 * either — debug builds keep the exact same full detail as before this
 * checkpoint. Centralized here so call sites in InternalAudioRecorder,
 * ClipAudioMuxer and ScreenCaptureService never repeat an ad hoc
 * `if (diagnosticsEnabled)` for the same decision.
 */

/**
 * Formats an optional " label=value" fragment — present only when
 * [diagnosticsEnabled] is true. Pure, so unit-testable without Robolectric.
 */
fun releaseSafeDetail(diagnosticsEnabled: Boolean, label: String, value: Any?): String =
    if (diagnosticsEnabled) " $label=$value" else ""

/**
 * Logs a "capture blocked or unavailable" style fallback error. Debug builds
 * keep the exception's stack trace exactly as before; release builds log
 * only the sanitized [message], never a stack trace.
 */
fun logFallbackError(tag: String, diagnosticsEnabled: Boolean, message: String, throwable: Throwable? = null) {
    if (diagnosticsEnabled && throwable != null) {
        Log.e(tag, message, throwable)
    } else {
        Log.e(tag, message)
    }
}
