package com.allappsengineer.apex_booster_plus

import android.content.Context
import android.os.Environment
import android.util.Log
import java.io.File

/**
 * AUDIO-CAPTURE-U2.7: release-only startup sweep for diagnostic/intermediate
 * audio artifacts left behind by a crash or kill — a WAV, a failed
 * .wav.part/.m4a.part, or an abandoned _av.mp4.part from a mux thread that
 * was still running when its process died. Only ever runs from
 * MainActivity.onCreate(), i.e. a fresh process — any thread that could have
 * been using one of these files belonged to the PREVIOUS (now-dead) process,
 * so there is no live-file concurrency to worry about here (unlike the
 * mux-thread-still-running case [ScreenCaptureService.resolveMuxOutcome]
 * guards against within a single session).
 *
 * Debug builds never call [sweep] — every artifact stays exactly where
 * U2.1-U2.6 already left it, for manual inspection.
 */
object OrphanAudioArtifactCleanup {
    private const val TAG = "OrphanAudioCleanup"
    private val TARGET_SUFFIXES = listOf(".wav", ".wav.part", ".m4a", ".m4a.part", "_av.mp4.part")

    /**
     * Pure decision function — no I/O. A candidate is deleted only if its
     * path matches one of the intermediate/diagnostic suffixes above, is NOT
     * in [protectedPaths] (every path currently referenced by
     * apex_clips/index.json, see [ClipIndexStore.allVideoClipPaths]), and is
     * older than [minAgeMs]. The age floor is defense-in-depth on top of the
     * "fresh process" guarantee described above, not a requirement for
     * correctness.
     */
    fun candidatesToDelete(
        candidatePaths: List<String>,
        protectedPaths: Set<String>,
        lastModifiedMillisByPath: Map<String, Long>,
        nowMillis: Long,
        minAgeMs: Long,
    ): List<String> = candidatePaths.filter { path ->
        TARGET_SUFFIXES.any { suffix -> path.endsWith(suffix) } &&
            path !in protectedPaths &&
            (nowMillis - (lastModifiedMillisByPath[path] ?: 0L)) >= minAgeMs
    }

    /**
     * Real filesystem sweep — release builds only. Scans exactly the two
     * directories these artifacts can ever live in (never the screenshots
     * directory, never anything outside app-private external storage) and
     * deletes whatever [candidatesToDelete] approves.
     */
    fun sweep(context: Context, protectedPaths: Set<String>, nowMillis: Long, minAgeMs: Long) {
        val audioDir = File(context.getExternalFilesDir(Environment.DIRECTORY_MUSIC), "apex_audio_poc")
        val clipsDir = File(context.getExternalFilesDir(Environment.DIRECTORY_MOVIES), "apex_clips")
        val candidateFiles = (audioDir.listFiles()?.toList() ?: emptyList()) +
            (clipsDir.listFiles()?.toList() ?: emptyList())
        if (candidateFiles.isEmpty()) return

        val candidatePaths = candidateFiles.map { it.absolutePath }
        val lastModifiedByPath = candidateFiles.associate { it.absolutePath to it.lastModified() }
        val toDelete = candidatesToDelete(candidatePaths, protectedPaths, lastModifiedByPath, nowMillis, minAgeMs)
        if (toDelete.isEmpty()) return

        val deletedCount = toDelete.count { path -> runCatching { File(path).delete() }.getOrDefault(false) }
        Log.d(TAG, "orphan audio artifact sweep deletedCount=$deletedCount of ${toDelete.size} candidates")
    }
}
