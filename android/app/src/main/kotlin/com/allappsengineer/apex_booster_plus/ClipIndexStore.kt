package com.allappsengineer.apex_booster_plus

import android.content.Context
import android.os.Environment
import java.io.File

/** Seam for "now" — ClipIndexMutator never calls System.currentTimeMillis() itself. */
fun interface ClipClock {
    fun nowMillis(): Long
}

object SystemClipClock : ClipClock {
    override fun nowMillis(): Long = System.currentTimeMillis()
}

/**
 * AUDIO-CAPTURE-U2.4: single process-wide coordinator for both
 * apex_captures/index.json and apex_clips/index.json — the only code path
 * (native or Dart) allowed to write either file. One lock serializes every
 * register/update/delete across both indices, shared by MainActivity and
 * ScreenCaptureService via [getInstance] (same idiom as
 * FloatingOverlayManager.getInstance).
 */
class ClipIndexStore(
    private val clipsStorage: ClipIndexStorage,
    private val capturesStorage: ClipIndexStorage,
    private val codec: ClipIndexCodec = JsonClipIndexCodec(),
    private val clock: ClipClock = SystemClipClock,
) {
    private val lock = Any()

    fun registerVideoClip(
        path: String,
        timestamp: Long,
        audioState: AudioState = AudioState.READY_WITHOUT_AUDIO,
    ): ClipIndexResult = mutate(clipsStorage) { entries ->
        ClipIndexMutator.insertVideoClip(entries, path, timestamp, audioState)
    }

    fun registerScreenshot(path: String, timestamp: Long): ClipIndexResult =
        mutate(capturesStorage) { entries -> ClipIndexMutator.insertScreenshot(entries, path, timestamp) }

    /** Only ever matches video entries — screenshots never receive an id. */
    fun deleteById(id: String): ClipIndexResult =
        mutate(clipsStorage) { entries -> ClipIndexMutator.deleteById(entries, id) }

    /** Fallback for legacy entries without an id — screenshots or pre-U2.4 clips. */
    fun deleteByPath(kind: ClipKind, path: String): ClipIndexResult =
        mutate(storageFor(kind)) { entries -> ClipIndexMutator.deleteByPath(entries, path) }

    fun updateAudioState(id: String, newState: AudioState): ClipIndexResult =
        mutate(clipsStorage) { entries ->
            ClipIndexMutator.updateAudioState(entries, id, newState, clock.nowMillis())
        }

    private fun storageFor(kind: ClipKind): ClipIndexStorage =
        if (kind == ClipKind.VIDEO) clipsStorage else capturesStorage

    private fun mutate(
        storage: ClipIndexStorage,
        op: (List<ClipEntry>) -> Pair<List<ClipEntry>, ClipIndexResult>,
    ): ClipIndexResult {
        synchronized(lock) {
            return try {
                val entries = codec.decode(storage.readRaw())
                val (updated, result) = op(entries)
                if (result is ClipIndexResult.Success) {
                    storage.writeRaw(codec.encode(ClipIndexMutator.trim(updated)))
                }
                result
            } catch (e: Exception) {
                ClipIndexResult.Failure(e.message ?: e.javaClass.simpleName)
            }
        }
    }

    companion object {
        @Volatile
        private var instance: ClipIndexStore? = null

        fun getInstance(context: Context): ClipIndexStore {
            return instance ?: synchronized(this) {
                instance ?: buildInstance(context.applicationContext).also { instance = it }
            }
        }

        private fun buildInstance(context: Context): ClipIndexStore {
            val clipsIndex =
                File(File(context.getExternalFilesDir(Environment.DIRECTORY_MOVIES), "apex_clips"), "index.json")
            val capturesIndex =
                File(File(context.getExternalFilesDir(Environment.DIRECTORY_PICTURES), "apex_captures"), "index.json")
            return ClipIndexStore(
                clipsStorage = AtomicFileClipIndexStorage(clipsIndex),
                capturesStorage = AtomicFileClipIndexStorage(capturesIndex),
            )
        }
    }
}
