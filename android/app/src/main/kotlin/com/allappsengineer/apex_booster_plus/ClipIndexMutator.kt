package com.allappsengineer.apex_booster_plus

import java.util.UUID

// AUDIO-CAPTURE-U2.4: pure JVM logic for index.json entries — no android.*,
// no org.json, no System.currentTimeMillis(). Every entry not explicitly
// targeted by an operation passes through unchanged (same instance), which
// is what keeps legacy/unknown JSON fields intact across read-modify-write.

enum class AudioState { PROCESSING, READY_WITH_AUDIO, READY_WITHOUT_AUDIO }

// AUDIO-FALLBACK-UX-U1.1: only meaningful on a terminal READY_WITHOUT_AUDIO
// entry — null on PROCESSING/READY_WITH_AUDIO, and on any legacy entry
// written before this field existed (ClipIndexCodec reads it as absent, not
// as a specific reason). SOURCE_SILENT_OR_UNAVAILABLE is the one reason
// Flutter's fallback UX (AUDIO-FALLBACK-UX-U1.1) surfaces to the user — the
// others describe device/permission/pipeline conditions the user can't act
// on by switching to the phone's screen recorder.
enum class AudioOutcomeReason {
    SOURCE_SILENT_OR_UNAVAILABLE,
    PERMISSION_DENIED,
    API_UNSUPPORTED,
    TIMELINE_INELIGIBLE,
    PROCESSING_FAILURE,
}

enum class ClipKind { SCREENSHOT, VIDEO }

data class ClipEntry(
    val path: String,
    val timestamp: Long,
    val type: String? = null,
    val id: String? = null,
    val audioState: String? = null,
    val audioProcessingStartedAt: Long? = null,
    val audioOutcomeReason: String? = null,
    // AUDIO-CAPTURE-U2.6: bytes/duration of the file currently at [path].
    // Set at registration for video clips and rewritten by
    // updateClipFile whenever [path] itself changes (promotion/rollback).
    val size: Long? = null,
    val durationMs: Long? = null,
    // Any JSON key this code doesn't recognize yet, preserved verbatim
    // across read-modify-write. Values are JSON scalars only
    // (String/Long/Double/Boolean/null) — no nested object/array has ever
    // been written to index.json by this codebase.
    val unknownFields: Map<String, Any?> = emptyMap(),
)

sealed class ClipIndexResult {
    data class Success(val id: String? = null, val path: String? = null) : ClipIndexResult()
    object NotFound : ClipIndexResult()
    data class Failure(val reason: String) : ClipIndexResult()
}

object ClipIndexMutator {
    private const val DEFAULT_MAX_ENTRIES = 60

    fun insertVideoClip(
        entries: List<ClipEntry>,
        path: String,
        timestamp: Long,
        audioState: AudioState,
        now: Long,
        sizeBytes: Long?,
        durationMs: Long?,
        audioOutcomeReason: AudioOutcomeReason? = null,
    ): Pair<List<ClipEntry>, ClipIndexResult> {
        val id = UUID.randomUUID().toString()
        val entry = ClipEntry(
            path = path,
            timestamp = timestamp,
            type = "video",
            id = id,
            audioState = audioState.name,
            // Same rule as updateAudioState: set once, only when the entry
            // is born already in PROCESSING (an eligible audio candidate
            // existed at registration time).
            audioProcessingStartedAt = if (audioState == AudioState.PROCESSING) now else null,
            size = sizeBytes,
            durationMs = durationMs,
            // AUDIO-FALLBACK-UX-U1.1: only meaningful when born directly as
            // READY_WITHOUT_AUDIO — a PROCESSING birth has no reason yet.
            audioOutcomeReason = if (audioState == AudioState.READY_WITHOUT_AUDIO) audioOutcomeReason?.name else null,
        )
        return (entries + entry) to ClipIndexResult.Success(id = id, path = path)
    }

    fun insertScreenshot(
        entries: List<ClipEntry>,
        path: String,
        timestamp: Long,
    ): Pair<List<ClipEntry>, ClipIndexResult> {
        val entry = ClipEntry(path = path, timestamp = timestamp)
        return (entries + entry) to ClipIndexResult.Success(path = path)
    }

    /** Only entries with a non-null [ClipEntry.id] can be matched here. */
    fun deleteById(entries: List<ClipEntry>, id: String): Pair<List<ClipEntry>, ClipIndexResult> {
        val target = entries.firstOrNull { it.id == id }
            ?: return entries to ClipIndexResult.NotFound
        return entries.filter { it !== target } to ClipIndexResult.Success(id = target.id, path = target.path)
    }

    /**
     * Fallback for legacy entries only — an id-bearing entry is never
     * matched by path here, even if paths happen to coincide.
     */
    fun deleteByPath(entries: List<ClipEntry>, path: String): Pair<List<ClipEntry>, ClipIndexResult> {
        val target = entries.firstOrNull { it.id == null && it.path == path }
            ?: return entries to ClipIndexResult.NotFound
        return entries.filter { it !== target } to ClipIndexResult.Success(id = target.id, path = target.path)
    }

    /**
     * [now] is always supplied by the caller (ClipIndexStore, via an
     * injected clock) — this function never reads the system clock itself.
     * audioProcessingStartedAt is set on first entry into PROCESSING and
     * never overwritten afterwards, whatever state it later resolves to.
     */
    fun updateAudioState(
        entries: List<ClipEntry>,
        id: String,
        newState: AudioState,
        now: Long,
        audioOutcomeReason: AudioOutcomeReason? = null,
    ): Pair<List<ClipEntry>, ClipIndexResult> {
        val target = entries.firstOrNull { it.id == id }
            ?: return entries to ClipIndexResult.NotFound
        val processingStartedAt = if (newState == AudioState.PROCESSING) {
            target.audioProcessingStartedAt ?: now
        } else {
            target.audioProcessingStartedAt
        }
        // AUDIO-FALLBACK-UX-U1.1: reason always reflects the state just
        // written — null whenever the caller doesn't pass one (PROCESSING,
        // READY_WITH_AUDIO), never carried over from a previous state.
        val reason = if (newState == AudioState.READY_WITHOUT_AUDIO) audioOutcomeReason?.name else null
        val updated = target.copy(
            audioState = newState.name,
            audioProcessingStartedAt = processingStartedAt,
            audioOutcomeReason = reason,
        )
        val updatedEntries = entries.map { if (it === target) updated else it }
        return updatedEntries to ClipIndexResult.Success(id = target.id, path = target.path)
    }

    /**
     * AUDIO-CAPTURE-U2.6: the only mutator allowed to change [ClipEntry.path]
     * on an existing entry. Used both to promote an entry to the muxed
     * `_av.mp4` (audioState=READY_WITH_AUDIO) and to roll it back to the
     * original file (audioState=READY_WITHOUT_AUDIO) if a post-promotion
     * confirmation read fails — a plain updateAudioState() would leave
     * [path] pointing at the wrong file in that case, which is exactly what
     * this mutator exists to avoid. audioProcessingStartedAt is preserved
     * (untouched by copy()) in both directions.
     */
    fun updateClipFile(
        entries: List<ClipEntry>,
        id: String,
        path: String,
        sizeBytes: Long?,
        durationMs: Long?,
        audioState: AudioState,
        audioOutcomeReason: AudioOutcomeReason? = null,
    ): Pair<List<ClipEntry>, ClipIndexResult> {
        val target = entries.firstOrNull { it.id == id }
            ?: return entries to ClipIndexResult.NotFound
        val reason = if (audioState == AudioState.READY_WITHOUT_AUDIO) audioOutcomeReason?.name else null
        val updated = target.copy(
            path = path,
            size = sizeBytes,
            durationMs = durationMs,
            audioState = audioState.name,
            audioOutcomeReason = reason,
        )
        val updatedEntries = entries.map { if (it === target) updated else it }
        return updatedEntries to ClipIndexResult.Success(id = target.id, path = path)
    }

    /**
     * AUDIO-CAPTURE-U2.6: entries left in PROCESSING by a crash, kill, or an
     * unresolved mux (e.g. a native hang past the join timeout) are demoted
     * to READY_WITHOUT_AUDIO once [audioProcessingStartedAt] is older than
     * [timeoutMs]. [path]/[size]/[durationMs] are left untouched — this
     * never re-points an entry, never recreates a deleted one (it only ever
     * iterates the entries actually present), and never re-triggers a mux.
     * Returns the ids that were recovered, so the caller can log/verify
     * without a second read.
     */
    fun recoverStaleAudioProcessing(
        entries: List<ClipEntry>,
        now: Long,
        timeoutMs: Long,
    ): Pair<List<ClipEntry>, List<String>> {
        val staleIds = entries
            .filter { entry ->
                entry.id != null &&
                    entry.audioState == AudioState.PROCESSING.name &&
                    entry.audioProcessingStartedAt != null &&
                    now - entry.audioProcessingStartedAt >= timeoutMs
            }
            .map { it.id!! }
        if (staleIds.isEmpty()) return entries to emptyList()
        val staleIdSet = staleIds.toSet()
        val updated = entries.map { entry ->
            if (entry.id != null && entry.id in staleIdSet) {
                entry.copy(
                    audioState = AudioState.READY_WITHOUT_AUDIO.name,
                    audioOutcomeReason = AudioOutcomeReason.PROCESSING_FAILURE.name,
                )
            } else {
                entry
            }
        }
        return updated to staleIds
    }

    fun trim(entries: List<ClipEntry>, maxEntries: Int = DEFAULT_MAX_ENTRIES): List<ClipEntry> =
        if (entries.size > maxEntries) entries.takeLast(maxEntries) else entries
}
