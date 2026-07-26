package com.allappsengineer.apex_booster_plus

import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMetadataRetriever
import android.media.MediaMuxer
import android.util.Log
import java.io.File
import java.nio.ByteBuffer
import kotlin.math.abs
import kotlin.math.max

/**
 * AUDIO-CAPTURE-U2.5: isolated experiment that muxes the already-finalized,
 * audio-free MP4 (MediaRecorder/H264, from ScreenCaptureService) with the
 * already-finalized, validated M4A (AAC-LC, from InternalAudioRecorder) into
 * a NEW file with two tracks — container copy only, never re-encodes either
 * stream. Debug-only, best-effort: every failure path here logs a
 * "capture blocked or unavailable — reason=..." line and returns without
 * throwing, and never touches the original MP4/WAV/M4A, the clip index, or
 * Flutter/Apex Studio. A failed attempt at most leaves an undiscarded
 * apex_clip_<timestamp>_av.mp4.part for diagnosis; it is only ever promoted
 * to apex_clip_<timestamp>_av.mp4 after [validateOutput] passes.
 */
/**
 * AUDIO-CAPTURE-U2.6: outcome of [ClipAudioMuxer.muxSynchronously] — lets the
 * caller (ScreenCaptureService) know whether to promote the clip index entry
 * to the muxed file, and with which path/size/duration, without re-opening
 * the output file itself.
 */
sealed class MuxResult {
    data class Success(val outputFile: File, val sizeBytes: Long, val durationMs: Long) : MuxResult()
    data class Failure(val reason: String) : MuxResult()
}

class ClipAudioMuxer {

    companion object {
        private const val TAG = "ClipAudioMuxer"

        // U2.5 gate: only attempt the mux when the video's own container
        // duration is close enough to the real wall-clock recording window.
        // ScreenCaptureService already computes durationMs/realSessionDurationMs
        // for its own U2.1 diagnostic-only classification; this reuses that
        // same ratio but with a tighter band since it gates real work here.
        private const val MUX_TIMELINE_RATIO_MIN = 0.90
        private const val MUX_TIMELINE_RATIO_MAX = 1.10

        private const val VIDEO_MIME_PREFIX = "video/"

        // Matches InternalAudioRecorder's own AAC_MIME_TYPE constant, kept as
        // an independent literal so this class has zero coupling to
        // InternalAudioRecorder beyond the File it hands over.
        private const val EXPECTED_AUDIO_MIME = "audio/mp4a-latm"

        // Copy buffer is sized from the larger of the two tracks' own
        // KEY_MAX_INPUT_SIZE, with a defensive floor/ceiling — extracted
        // track formats don't always carry KEY_MAX_INPUT_SIZE, so the floor
        // also serves as the fallback when it's absent.
        private const val COPY_BUFFER_FLOOR_BYTES = 256 * 1024
        private const val COPY_BUFFER_CEILING_BYTES = 4 * 1024 * 1024

        private const val DURATION_TOLERANCE_FLOOR_US = 250_000L
        private const val DURATION_TOLERANCE_RATIO_PERCENT = 3L

        private val ALLOWED_ROTATIONS = intArrayOf(0, 90, 180, 270)

        // AUDIO-CAPTURE-U2.6: replaces the old fixed 5s join wait. Longer
        // sessions produce bigger files and take longer to copy/validate, so
        // the bound scales with the real recording length instead of being a
        // one-size-fits-all constant — floor and ceiling keep it bounded
        // either way ("keep the service alive until done, or a controlled
        // timeout", never indefinitely, never disproportionate to a 4s clip).
        const val MUX_TIMEOUT_FLOOR_MS = 15_000L
        const val MUX_TIMEOUT_CEILING_MS = 30_000L

        /** Pure — no I/O, safe to call before spawning the mux thread. */
        fun computeMuxTimeoutMs(realSessionDurationMs: Long): Long =
            maxOf(MUX_TIMEOUT_FLOOR_MS, minOf(MUX_TIMEOUT_CEILING_MS, realSessionDurationMs / 2L))

        /**
         * AUDIO-CAPTURE-U2.6: single formula deciding whether a clip is
         * registered as PROCESSING (mux attempted) or READY_WITHOUT_AUDIO
         * right away (mux never attempted, no register-then-downgrade
         * churn). Pure — centralized here so it's unit-testable without
         * Robolectric, since ScreenCaptureService itself isn't.
         */
        fun computeAudioCandidateEligible(
            hasAudioCandidate: Boolean,
            silenceDetected: Boolean,
            muxTimelineEligible: Boolean,
        ): Boolean = hasAudioCandidate && !silenceDetected && muxTimelineEligible
    }

    /**
     * Pure gate check, no I/O. ScreenCaptureService calls this before even
     * spawning the mux thread, so an ineligible clip never touches disk for
     * this feature at all, and is never classified as an audio failure.
     */
    fun isTimelineEligible(videoDurationMs: Long, realSessionDurationMs: Long): Boolean {
        if (videoDurationMs <= 0L || realSessionDurationMs <= 0L) return false
        val ratio = videoDurationMs.toDouble() / realSessionDurationMs.toDouble()
        return ratio in MUX_TIMELINE_RATIO_MIN..MUX_TIMELINE_RATIO_MAX
    }

    /**
     * Runs synchronously on the caller's thread — ScreenCaptureService is
     * responsible for calling this from a dedicated thread and joining it
     * with an adaptive timeout (see [computeMuxTimeoutMs]). [videoStartElapsedMs] and
     * [audioStartElapsedMs] must both be SystemClock.elapsedRealtime()
     * instants (video recorder.start() success, and
     * InternalAudioRecorder.start()'s AudioRecord.startRecording() success,
     * respectively) — used to compute the signed offset between the two
     * recorders' start instants.
     */
    fun muxSynchronously(
        videoFile: File,
        audioFile: File,
        videoStartElapsedMs: Long,
        audioStartElapsedMs: Long,
    ): MuxResult {
        if (!videoFile.exists() || videoFile.length() <= 0L) {
            Log.e(TAG, "capture blocked or unavailable — reason=av_mux_video_missing path=${videoFile.absolutePath}")
            return MuxResult.Failure("av_mux_video_missing")
        }
        if (!audioFile.exists() || audioFile.length() <= 0L) {
            Log.e(TAG, "capture blocked or unavailable — reason=av_mux_audio_missing path=${audioFile.absolutePath}")
            return MuxResult.Failure("av_mux_audio_missing")
        }

        val videoBaseName = videoFile.name.removeSuffix(".mp4")
        val partFile = File(videoFile.parentFile, "${videoBaseName}_av.mp4.part")
        val finalFile = File(videoFile.parentFile, "${videoBaseName}_av.mp4")
        // Best-effort cleanup of a stray .part from a previous failed attempt
        // for this exact clip — never touches videoFile/audioFile/finalFile.
        runCatching { if (partFile.exists()) partFile.delete() }

        var videoExtractor: MediaExtractor? = null
        var audioExtractor: MediaExtractor? = null
        var muxer: MediaMuxer? = null
        var muxerStarted = false

        try {
            val vExtractor = MediaExtractor().apply { setDataSource(videoFile.absolutePath) }
            videoExtractor = vExtractor
            val videoTrackIndex = findTrackIndex(vExtractor, VIDEO_MIME_PREFIX)
            if (videoTrackIndex < 0) {
                Log.e(TAG, "capture blocked or unavailable — reason=av_mux_no_video_track")
                return MuxResult.Failure("av_mux_no_video_track")
            }
            vExtractor.selectTrack(videoTrackIndex)
            val videoFormat = vExtractor.getTrackFormat(videoTrackIndex)
            val videoMime = videoFormat.getString(MediaFormat.KEY_MIME)
            if (videoMime == null || !videoMime.startsWith(VIDEO_MIME_PREFIX)) {
                Log.e(TAG, "capture blocked or unavailable — reason=av_mux_video_mime_mismatch mime=$videoMime")
                return MuxResult.Failure("av_mux_video_mime_mismatch")
            }

            val aExtractor = MediaExtractor().apply { setDataSource(audioFile.absolutePath) }
            audioExtractor = aExtractor
            if (aExtractor.trackCount != 1) {
                Log.e(
                    TAG,
                    "capture blocked or unavailable — reason=av_mux_audio_track_count_unexpected " +
                        "count=${aExtractor.trackCount}",
                )
                return MuxResult.Failure("av_mux_audio_track_count_unexpected")
            }
            aExtractor.selectTrack(0)
            val audioFormat = aExtractor.getTrackFormat(0)
            val audioMime = audioFormat.getString(MediaFormat.KEY_MIME)
            if (audioMime != EXPECTED_AUDIO_MIME) {
                Log.e(TAG, "capture blocked or unavailable — reason=av_mux_audio_mime_mismatch mime=$audioMime")
                return MuxResult.Failure("av_mux_audio_mime_mismatch")
            }

            val rotationDegrees = readRotationDegrees(videoFile)

            val bufferSize = max(
                readMaxInputSizeOrFallback(videoFormat),
                readMaxInputSizeOrFallback(audioFormat),
            ).coerceIn(COPY_BUFFER_FLOOR_BYTES, COPY_BUFFER_CEILING_BYTES)
            val buffer = ByteBuffer.allocate(bufferSize)

            val newMuxer = MediaMuxer(partFile.absolutePath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
            muxer = newMuxer
            val muxerVideoTrack = newMuxer.addTrack(videoFormat)
            val muxerAudioTrack = newMuxer.addTrack(audioFormat)
            newMuxer.setOrientationHint(rotationDegrees)
            newMuxer.start()
            muxerStarted = true

            val copyResult = copyInterleaved(
                videoExtractor = vExtractor,
                audioExtractor = aExtractor,
                muxer = newMuxer,
                muxerVideoTrack = muxerVideoTrack,
                muxerAudioTrack = muxerAudioTrack,
                buffer = buffer,
                videoStartElapsedMs = videoStartElapsedMs,
                audioStartElapsedMs = audioStartElapsedMs,
            ) ?: return MuxResult.Failure("av_mux_copy_failed") // reason already logged inside copyInterleaved

            val stopped = runCatching { newMuxer.stop() }
            muxerStarted = false
            if (stopped.isFailure) {
                Log.e(
                    TAG,
                    "capture blocked or unavailable — reason=av_mux_muxer_stop_failed: ${stopped.exceptionOrNull()?.message}",
                )
                return MuxResult.Failure("av_mux_muxer_stop_failed")
            }
            runCatching { newMuxer.release() }
            muxer = null

            val valid = validateOutput(
                partFile = partFile,
                expectedVideoMime = videoMime,
                expectedAudioMime = audioMime,
                expectedRotation = rotationDegrees,
                originalVideoSpanUs = copyResult.videoSpanUs,
                originalAudioSpanUs = copyResult.audioSpanUs,
            )
            if (!valid) {
                // Reason already logged inside validateOutput; .part preserved for diagnosis.
                return MuxResult.Failure("av_mux_output_validation_failed")
            }

            val renamed = try {
                partFile.renameTo(finalFile)
            } catch (e: Exception) {
                Log.e(TAG, "capture blocked or unavailable — reason=av_mux_rename_failed: ${e.message}", e)
                false
            }
            if (!renamed) {
                Log.e(TAG, "capture blocked or unavailable — reason=av_mux_rename_failed path=${partFile.absolutePath}")
                return MuxResult.Failure("av_mux_rename_failed")
            }

            Log.d(
                TAG,
                "AV mux saved path=${finalFile.absolutePath} bytes=${finalFile.length()} " +
                    "rotation=$rotationDegrees videoSpanUs=${copyResult.videoSpanUs} audioSpanUs=${copyResult.audioSpanUs}",
            )
            return MuxResult.Success(
                outputFile = finalFile,
                sizeBytes = finalFile.length(),
                durationMs = copyResult.videoSpanUs / 1_000L,
            )
        } catch (e: Exception) {
            Log.e(TAG, "capture blocked or unavailable — reason=av_mux_unexpected_error: ${e.message}", e)
            return MuxResult.Failure("av_mux_unexpected_error")
        } finally {
            if (muxerStarted) {
                runCatching { muxer?.stop() }
            }
            runCatching { muxer?.release() }
            runCatching { videoExtractor?.release() }
            runCatching { audioExtractor?.release() }
        }
    }

    private fun findTrackIndex(extractor: MediaExtractor, mimePrefix: String): Int {
        for (i in 0 until extractor.trackCount) {
            val mime = extractor.getTrackFormat(i).getString(MediaFormat.KEY_MIME)
            if (mime != null && mime.startsWith(mimePrefix)) return i
        }
        return -1
    }

    private fun readMaxInputSizeOrFallback(format: MediaFormat): Int {
        return try {
            if (format.containsKey(MediaFormat.KEY_MAX_INPUT_SIZE)) {
                format.getInteger(MediaFormat.KEY_MAX_INPUT_SIZE)
            } else {
                COPY_BUFFER_FLOOR_BYTES
            }
        } catch (e: Exception) {
            COPY_BUFFER_FLOOR_BYTES
        }
    }

    private fun readRotationDegrees(videoFile: File): Int {
        val retriever = MediaMetadataRetriever()
        val rotation = try {
            retriever.setDataSource(videoFile.absolutePath)
            retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)?.toIntOrNull() ?: 0
        } catch (e: Exception) {
            0
        } finally {
            runCatching { retriever.release() }
        }
        return if (ALLOWED_ROTATIONS.contains(rotation)) rotation else 0
    }

    private class CopyResult(val videoSpanUs: Long, val audioSpanUs: Long)

    /**
     * Interleaves samples from both extractors by ascending OUTPUT
     * timestamp, writing whichever track's next sample is chronologically
     * earliest. Each track's PTS is normalized to its OWN first sample, then
     * the audio track is shifted by a signed [tDeltaUs] — the real
     * elapsedRealtime gap between the two recorders' start instants — and
     * both tracks receive the same [globalShiftUs] on top so every output
     * PTS is >= 0 without clamping either track independently. The relative
     * delay between the two tracks is preserved exactly.
     *
     * MediaExtractor.getSampleTime() returning -1L is used as the per-track
     * EOS signal (no readSampleData call needed just to detect it).
     */
    private fun copyInterleaved(
        videoExtractor: MediaExtractor,
        audioExtractor: MediaExtractor,
        muxer: MediaMuxer,
        muxerVideoTrack: Int,
        muxerAudioTrack: Int,
        buffer: ByteBuffer,
        videoStartElapsedMs: Long,
        audioStartElapsedMs: Long,
    ): CopyResult? {
        val tDeltaUs = (audioStartElapsedMs - videoStartElapsedMs) * 1_000L
        val globalShiftUs = if (tDeltaUs < 0L) -tDeltaUs else 0L

        var firstVideoRawUs = -1L
        var lastVideoRawUs = -1L
        var firstAudioRawUs = -1L
        var lastAudioRawUs = -1L
        var lastVideoOutUs = -1L
        var lastAudioOutUs = -1L

        val info = MediaCodec.BufferInfo()

        while (true) {
            val videoRawUs = videoExtractor.sampleTime
            val audioRawUs = audioExtractor.sampleTime
            if (videoRawUs < 0L && audioRawUs < 0L) break

            val videoOutUs = if (videoRawUs < 0L) {
                null
            } else {
                val firstUs = if (firstVideoRawUs < 0L) videoRawUs else firstVideoRawUs
                (videoRawUs - firstUs) + globalShiftUs
            }
            val audioOutUs = if (audioRawUs < 0L) {
                null
            } else {
                val firstUs = if (firstAudioRawUs < 0L) audioRawUs else firstAudioRawUs
                (audioRawUs - firstUs) + tDeltaUs + globalShiftUs
            }

            val takeVideo = when {
                videoOutUs == null -> false
                audioOutUs == null -> true
                else -> videoOutUs <= audioOutUs
            }

            if (takeVideo) {
                val outUs = videoOutUs!!
                if (firstVideoRawUs < 0L) firstVideoRawUs = videoRawUs
                lastVideoRawUs = videoRawUs

                val sampleFlags = videoExtractor.sampleFlags
                if ((sampleFlags and MediaExtractor.SAMPLE_FLAG_ENCRYPTED) != 0) {
                    Log.e(TAG, "capture blocked or unavailable — reason=av_mux_encrypted_sample_rejected track=video")
                    return null
                }
                if ((sampleFlags and MediaExtractor.SAMPLE_FLAG_PARTIAL_FRAME) != 0) {
                    Log.e(TAG, "capture blocked or unavailable — reason=av_mux_partial_frame_rejected track=video")
                    return null
                }
                if (outUs < lastVideoOutUs) {
                    Log.e(TAG, "capture blocked or unavailable — reason=av_mux_pts_non_monotonic track=video")
                    return null
                }
                lastVideoOutUs = outUs
                val muxFlags = if ((sampleFlags and MediaExtractor.SAMPLE_FLAG_SYNC) != 0) {
                    MediaCodec.BUFFER_FLAG_KEY_FRAME
                } else {
                    0
                }

                buffer.clear()
                val sampleSize = try {
                    videoExtractor.readSampleData(buffer, 0)
                } catch (e: Exception) {
                    Log.e(
                        TAG,
                        "capture blocked or unavailable — reason=av_mux_sample_exceeds_buffer track=video: ${e.message}",
                    )
                    return null
                }
                if (sampleSize < 0 || sampleSize > buffer.capacity()) {
                    Log.e(
                        TAG,
                        "capture blocked or unavailable — reason=av_mux_sample_exceeds_buffer track=video size=$sampleSize",
                    )
                    return null
                }
                buffer.position(0)
                buffer.limit(sampleSize)
                info.set(0, sampleSize, outUs, muxFlags)
                try {
                    muxer.writeSampleData(muxerVideoTrack, buffer, info)
                } catch (e: Exception) {
                    Log.e(TAG, "capture blocked or unavailable — reason=av_mux_write_failed track=video: ${e.message}", e)
                    return null
                }
                videoExtractor.advance()
            } else {
                val outUs = audioOutUs!!
                if (firstAudioRawUs < 0L) firstAudioRawUs = audioRawUs
                lastAudioRawUs = audioRawUs

                val sampleFlags = audioExtractor.sampleFlags
                if ((sampleFlags and MediaExtractor.SAMPLE_FLAG_ENCRYPTED) != 0) {
                    Log.e(TAG, "capture blocked or unavailable — reason=av_mux_encrypted_sample_rejected track=audio")
                    return null
                }
                if ((sampleFlags and MediaExtractor.SAMPLE_FLAG_PARTIAL_FRAME) != 0) {
                    Log.e(TAG, "capture blocked or unavailable — reason=av_mux_partial_frame_rejected track=audio")
                    return null
                }
                if (outUs < lastAudioOutUs) {
                    Log.e(TAG, "capture blocked or unavailable — reason=av_mux_pts_non_monotonic track=audio")
                    return null
                }
                lastAudioOutUs = outUs
                val muxFlags = if ((sampleFlags and MediaExtractor.SAMPLE_FLAG_SYNC) != 0) {
                    MediaCodec.BUFFER_FLAG_KEY_FRAME
                } else {
                    0
                }

                buffer.clear()
                val sampleSize = try {
                    audioExtractor.readSampleData(buffer, 0)
                } catch (e: Exception) {
                    Log.e(
                        TAG,
                        "capture blocked or unavailable — reason=av_mux_sample_exceeds_buffer track=audio: ${e.message}",
                    )
                    return null
                }
                if (sampleSize < 0 || sampleSize > buffer.capacity()) {
                    Log.e(
                        TAG,
                        "capture blocked or unavailable — reason=av_mux_sample_exceeds_buffer track=audio size=$sampleSize",
                    )
                    return null
                }
                buffer.position(0)
                buffer.limit(sampleSize)
                info.set(0, sampleSize, outUs, muxFlags)
                try {
                    muxer.writeSampleData(muxerAudioTrack, buffer, info)
                } catch (e: Exception) {
                    Log.e(TAG, "capture blocked or unavailable — reason=av_mux_write_failed track=audio: ${e.message}", e)
                    return null
                }
                audioExtractor.advance()
            }
        }

        if (firstVideoRawUs < 0L || firstAudioRawUs < 0L) {
            Log.e(TAG, "capture blocked or unavailable — reason=av_mux_no_samples_written")
            return null
        }

        return CopyResult(
            videoSpanUs = lastVideoRawUs - firstVideoRawUs,
            audioSpanUs = lastAudioRawUs - firstAudioRawUs,
        )
    }

    /**
     * Reopens the produced .part with a fresh MediaExtractor so this
     * validation exercises the actual muxed container end to end, instead of
     * trusting in-memory state from [copyInterleaved].
     */
    private fun validateOutput(
        partFile: File,
        expectedVideoMime: String,
        expectedAudioMime: String,
        expectedRotation: Int,
        originalVideoSpanUs: Long,
        originalAudioSpanUs: Long,
    ): Boolean {
        if (!partFile.exists() || partFile.length() <= 0L) {
            Log.e(
                TAG,
                "capture blocked or unavailable — reason=av_mux_output_missing_or_empty path=${partFile.absolutePath}",
            )
            return false
        }

        val retriever = MediaMetadataRetriever()
        val outputRotation = try {
            retriever.setDataSource(partFile.absolutePath)
            retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)?.toIntOrNull() ?: 0
        } catch (e: Exception) {
            -1
        } finally {
            runCatching { retriever.release() }
        }
        if (outputRotation != expectedRotation) {
            Log.e(
                TAG,
                "capture blocked or unavailable — reason=av_mux_rotation_mismatch " +
                    "expected=$expectedRotation actual=$outputRotation",
            )
            return false
        }

        val extractor = MediaExtractor()
        try {
            extractor.setDataSource(partFile.absolutePath)
            if (extractor.trackCount != 2) {
                Log.e(
                    TAG,
                    "capture blocked or unavailable — reason=av_mux_output_track_count_unexpected " +
                        "count=${extractor.trackCount}",
                )
                return false
            }

            var videoTrackIndex = -1
            var audioTrackIndex = -1
            for (i in 0 until extractor.trackCount) {
                val mime = extractor.getTrackFormat(i).getString(MediaFormat.KEY_MIME)
                when {
                    mime == expectedVideoMime && videoTrackIndex < 0 -> videoTrackIndex = i
                    mime == expectedAudioMime && audioTrackIndex < 0 -> audioTrackIndex = i
                }
            }
            if (videoTrackIndex < 0 || audioTrackIndex < 0) {
                Log.e(
                    TAG,
                    "capture blocked or unavailable — reason=av_mux_output_tracks_unexpected " +
                        "videoTrackIndex=$videoTrackIndex audioTrackIndex=$audioTrackIndex",
                )
                return false
            }

            val videoSpanUs = scanTrackSpan(extractor, videoTrackIndex)
            if (videoSpanUs == null) {
                Log.e(TAG, "capture blocked or unavailable — reason=av_mux_output_video_scan_failed")
                return false
            }
            val audioSpanUs = scanTrackSpan(extractor, audioTrackIndex)
            if (audioSpanUs == null) {
                Log.e(TAG, "capture blocked or unavailable — reason=av_mux_output_audio_scan_failed")
                return false
            }

            if (!withinTolerance(videoSpanUs, originalVideoSpanUs)) {
                Log.e(
                    TAG,
                    "capture blocked or unavailable — reason=av_mux_video_duration_mismatch " +
                        "outputSpanUs=$videoSpanUs originalSpanUs=$originalVideoSpanUs",
                )
                return false
            }
            if (!withinTolerance(audioSpanUs, originalAudioSpanUs)) {
                Log.e(
                    TAG,
                    "capture blocked or unavailable — reason=av_mux_audio_duration_mismatch " +
                        "outputSpanUs=$audioSpanUs originalSpanUs=$originalAudioSpanUs",
                )
                return false
            }

            return true
        } catch (e: Exception) {
            Log.e(TAG, "capture blocked or unavailable — reason=av_mux_output_validation_failed: ${e.message}", e)
            return false
        } finally {
            runCatching { extractor.release() }
        }
    }

    private fun withinTolerance(actualUs: Long, expectedUs: Long): Boolean {
        val toleranceUs = max(DURATION_TOLERANCE_FLOOR_US, expectedUs * DURATION_TOLERANCE_RATIO_PERCENT / 100L)
        return abs(actualUs - expectedUs) <= toleranceUs
    }

    /**
     * Selects exactly [trackIndex] on [extractor] and walks every sample to
     * the end, confirming non-decreasing PTS. Returns the (lastPts-firstPts)
     * span, or null if the track has no samples or PTS regress.
     */
    private fun scanTrackSpan(extractor: MediaExtractor, trackIndex: Int): Long? {
        extractor.selectTrack(trackIndex)
        try {
            extractor.seekTo(0L, MediaExtractor.SEEK_TO_CLOSEST_SYNC)
            val scratch = ByteBuffer.allocate(COPY_BUFFER_CEILING_BYTES)
            var firstPts = -1L
            var lastPts = -1L
            var sampleCount = 0
            while (true) {
                val size = extractor.readSampleData(scratch, 0)
                if (size < 0) break
                val pts = extractor.sampleTime
                if (firstPts < 0L) firstPts = pts
                if (pts < lastPts) return null
                lastPts = pts
                sampleCount++
                extractor.advance()
            }
            return if (sampleCount > 0 && firstPts >= 0L) lastPts - firstPts else null
        } finally {
            runCatching { extractor.unselectTrack(trackIndex) }
        }
    }
}
