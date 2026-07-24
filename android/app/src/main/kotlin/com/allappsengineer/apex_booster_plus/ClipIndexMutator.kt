package com.allappsengineer.apex_booster_plus

import java.util.UUID

// AUDIO-CAPTURE-U2.4: pure JVM logic for index.json entries — no android.*,
// no org.json, no System.currentTimeMillis(). Every entry not explicitly
// targeted by an operation passes through unchanged (same instance), which
// is what keeps legacy/unknown JSON fields intact across read-modify-write.

enum class AudioState { PROCESSING, READY_WITH_AUDIO, READY_WITHOUT_AUDIO }

enum class ClipKind { SCREENSHOT, VIDEO }

data class ClipEntry(
    val path: String,
    val timestamp: Long,
    val type: String? = null,
    val id: String? = null,
    val audioState: String? = null,
    val audioProcessingStartedAt: Long? = null,
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
    ): Pair<List<ClipEntry>, ClipIndexResult> {
        val id = UUID.randomUUID().toString()
        val entry = ClipEntry(
            path = path,
            timestamp = timestamp,
            type = "video",
            id = id,
            audioState = audioState.name,
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
    ): Pair<List<ClipEntry>, ClipIndexResult> {
        val target = entries.firstOrNull { it.id == id }
            ?: return entries to ClipIndexResult.NotFound
        val processingStartedAt = if (newState == AudioState.PROCESSING) {
            target.audioProcessingStartedAt ?: now
        } else {
            target.audioProcessingStartedAt
        }
        val updated = target.copy(audioState = newState.name, audioProcessingStartedAt = processingStartedAt)
        val updatedEntries = entries.map { if (it === target) updated else it }
        return updatedEntries to ClipIndexResult.Success(id = target.id, path = target.path)
    }

    fun trim(entries: List<ClipEntry>, maxEntries: Int = DEFAULT_MAX_ENTRIES): List<ClipEntry> =
        if (entries.size > maxEntries) entries.takeLast(maxEntries) else entries
}
