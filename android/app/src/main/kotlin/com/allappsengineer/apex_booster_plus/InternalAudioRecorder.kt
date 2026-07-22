package com.allappsengineer.apex_booster_plus

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioPlaybackCaptureConfiguration
import android.media.AudioRecord
import android.media.projection.MediaProjection
import android.os.Build
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.io.RandomAccessFile
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.math.sqrt

/**
 * AUDIO-CAPTURE-U1.1B: isolated experiment proving whether
 * [AudioPlaybackCaptureConfiguration] + [AudioRecord] deliver real, non-silent
 * samples from the SAME [MediaProjection] instance that is simultaneously
 * backing the video [MediaRecorder]/VirtualDisplay in ScreenCaptureService —
 * now with an auditable WAV file so the samples can be listened to directly,
 * instead of only inspected via RMS logs.
 *
 * Deliberately does nothing else: no AAC, no MediaCodec, no MediaMuxer, no
 * muxing into the MP4. This class only reads PCM samples, streams them
 * incrementally to a raw .wav.part file, measures RMS/peak, and finalizes a
 * playable .wav via finalizeAndRelease(). It never touches the video Surface/MediaRecorder/
 * output file, and every failure path here is swallowed — a problem in this
 * class must never affect video recording, which keeps running exactly as it
 * does today regardless of what happens here.
 */
class InternalAudioRecorder {

    companion object {
        private const val TAG = "InternalAudioRecorder"

        // Single source of truth for the AudioRecord config AND the WAV
        // header — both must describe the exact same stream, never
        // duplicated/divergent constants.
        private const val SAMPLE_RATE = 48_000
        private const val CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_STEREO
        private const val CHANNEL_COUNT = 2 // matches CHANNEL_IN_STEREO
        private const val AUDIO_ENCODING = AudioFormat.ENCODING_PCM_16BIT
        private const val BITS_PER_SAMPLE = 16 // matches ENCODING_PCM_16BIT
        private const val WAV_HEADER_SIZE = 44

        // Empirical floor for 16-bit PCM noise/DC-offset floor — RMS below
        // this is treated as "no real audio", not a scientifically derived
        // threshold. Good enough to tell "silence" from "something playing"
        // for this POC's purpose.
        private const val SILENCE_RMS_THRESHOLD = 50.0

        // One log line roughly every ~1s at 48kHz/stereo with our buffer size.
        private const val LOG_EVERY_N_READS = 47

        private const val THREAD_JOIN_TIMEOUT_MS = 1_500L
        private const val THREAD_JOIN_RETRY_TIMEOUT_MS = 500L
    }

    @Volatile
    private var recording = false

    // Set true only after readLoop()'s finally block has closed the PCM
    // FileOutputStream — finalizeAndRelease() refuses to patch/rename the
    // file until this is confirmed, on top of (not instead of) the
    // Thread.isAlive check.
    @Volatile
    private var pcmStreamClosed = false

    // AUDIO-CAPTURE-U2.2: true once start() has this instance fully wired up
    // (AudioRecord initialized, read thread launched) — distinguishes "never
    // started" (finalizeAndRelease() should be a silent no-op) from "started
    // and already finalized". Reset at the top of every start().
    @Volatile
    private var started = false

    // True after the first requestStop() call this session — makes
    // requestStop() idempotent, including the internal call finalizeAndRelease()
    // makes to itself. Reset at the top of every start().
    @Volatile
    private var stopRequested = false

    // True after finalizeAndRelease() has run its join/release/rename logic
    // once this session — guards against repeating that work on a duplicate
    // call. Reset at the top of every start().
    @Volatile
    private var finalized = false

    private var audioRecord: AudioRecord? = null
    private var readThread: Thread? = null
    private var minBufferSizeUsed = 0

    private var partFile: File? = null
    private var finalFile: File? = null

    // Written by readThread, read by the caller's thread in finalizeAndRelease()
    // only after Thread.join() returns — join() establishes a happens-before
    // edge, so these plain fields are safely visible without @Volatile.
    private var pcmBytesWritten = 0L
    private var totalSamples = 0L
    private var sumSquares = 0.0
    private var peakRms = 0.0
    private var negativeReadCount = 0
    private var lastNegativeReadCode = 0

    /** API 29 (Android 10) is the platform floor for AudioPlaybackCaptureConfiguration. */
    fun isSupported(): Boolean {
        val supported = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
        Log.d(TAG, "audioCapture supported=$supported sdkInt=${Build.VERSION.SDK_INT}")
        return supported
    }

    /**
     * Starts the isolated capture experiment against [projection] — the SAME
     * MediaProjection instance already backing the video VirtualDisplay in
     * ScreenCaptureService. [hasRecordAudioPermission] must be checked by the
     * caller (a Service cannot request runtime permissions itself); if false,
     * this is a clean no-op, never a crash. [outputDir] is an app-specific
     * external directory (no storage permission required) where the WAV is
     * written.
     *
     * Best-effort end to end: every failure branch logs a clear
     * "capture blocked or unavailable — reason=..." line and returns, so the
     * caller's video recording is never affected by anything that happens here.
     */
    fun start(projection: MediaProjection, hasRecordAudioPermission: Boolean, outputDir: File) {
        stopRequested = false
        finalized = false
        if (!isSupported()) {
            Log.d(TAG, "capture blocked or unavailable — reason=unsupported_sdk")
            return
        }
        if (!hasRecordAudioPermission) {
            Log.d(TAG, "capture blocked or unavailable — reason=permission_denied")
            return
        }
        Log.d(TAG, "permission granted")

        val config = try {
            AudioPlaybackCaptureConfiguration.Builder(projection)
                .addMatchingUsage(AudioAttributes.USAGE_GAME)
                .addMatchingUsage(AudioAttributes.USAGE_MEDIA)
                .build()
        } catch (e: Exception) {
            Log.e(TAG, "capture blocked or unavailable — reason=config_build_failed: ${e.message}", e)
            return
        }

        val minBufferSize = AudioRecord.getMinBufferSize(SAMPLE_RATE, CHANNEL_CONFIG, AUDIO_ENCODING)
        if (minBufferSize <= 0) {
            Log.e(TAG, "capture blocked or unavailable — reason=invalid_min_buffer_size value=$minBufferSize")
            return
        }
        minBufferSizeUsed = minBufferSize

        val record = try {
            AudioRecord.Builder()
                .setAudioFormat(
                    AudioFormat.Builder()
                        .setEncoding(AUDIO_ENCODING)
                        .setSampleRate(SAMPLE_RATE)
                        .setChannelMask(CHANNEL_CONFIG)
                        .build(),
                )
                .setBufferSizeInBytes(minBufferSize * 2)
                .setAudioPlaybackCaptureConfig(config)
                .build()
        } catch (e: Exception) {
            Log.e(TAG, "capture blocked or unavailable — reason=audio_record_build_failed: ${e.message}", e)
            return
        }

        if (record.state != AudioRecord.STATE_INITIALIZED) {
            Log.e(
                TAG,
                "capture blocked or unavailable — reason=audio_record_not_initialized state=${record.state}",
            )
            runCatching { record.release() }
            return
        }

        Log.d(
            TAG,
            "AudioRecord initialized sampleRate=$SAMPLE_RATE channelConfig=$CHANNEL_CONFIG " +
                "encoding=$AUDIO_ENCODING minBufferSize=$minBufferSize",
        )

        val dirReady = try {
            outputDir.exists() || outputDir.mkdirs()
        } catch (e: Exception) {
            Log.e(TAG, "capture blocked or unavailable — reason=output_dir_create_failed: ${e.message}", e)
            false
        }
        if (!dirReady) {
            Log.e(TAG, "capture blocked or unavailable — reason=output_dir_create_failed dir=${outputDir.absolutePath}")
            runCatching { record.release() }
            return
        }

        val timestamp = System.currentTimeMillis()
        val part = File(outputDir, "apex_audio_poc_$timestamp.wav.part")
        val final = File(outputDir, "apex_audio_poc_$timestamp.wav")
        partFile = part
        finalFile = final

        try {
            record.startRecording()
        } catch (e: Exception) {
            Log.e(TAG, "capture blocked or unavailable — reason=start_recording_failed: ${e.message}", e)
            runCatching { record.release() }
            return
        }
        if (record.recordingState != AudioRecord.RECORDSTATE_RECORDING) {
            Log.e(
                TAG,
                "capture blocked or unavailable — reason=start_recording_rejected " +
                    "recordingState=${record.recordingState}",
            )
            runCatching { record.release() }
            return
        }

        audioRecord = record
        pcmStreamClosed = false
        started = true
        recording = true

        val thread = Thread({ readLoop(record, minBufferSize, part) }, "ApexAudioCaptureThread")
        readThread = thread
        thread.start()
    }

    private fun buildWavHeader(pcmDataSize: Long): ByteArray {
        val byteRate = SAMPLE_RATE * CHANNEL_COUNT * BITS_PER_SAMPLE / 8
        val blockAlign = CHANNEL_COUNT * BITS_PER_SAMPLE / 8
        val buffer = ByteBuffer.allocate(WAV_HEADER_SIZE).order(ByteOrder.LITTLE_ENDIAN)
        buffer.put("RIFF".toByteArray(Charsets.US_ASCII))
        buffer.putInt((36L + pcmDataSize).toInt())
        buffer.put("WAVE".toByteArray(Charsets.US_ASCII))
        buffer.put("fmt ".toByteArray(Charsets.US_ASCII))
        buffer.putInt(16)
        buffer.putShort(1) // PCM
        buffer.putShort(CHANNEL_COUNT.toShort())
        buffer.putInt(SAMPLE_RATE)
        buffer.putInt(byteRate)
        buffer.putShort(blockAlign.toShort())
        buffer.putShort(BITS_PER_SAMPLE.toShort())
        buffer.put("data".toByteArray(Charsets.US_ASCII))
        buffer.putInt(pcmDataSize.toInt())
        return buffer.array()
    }

    private fun readLoop(record: AudioRecord, minBufferSize: Int, part: File) {
        val buffer = ShortArray((minBufferSize / 2).coerceAtLeast(1))
        val pcmBytes = ByteBuffer.allocate(buffer.size * 2).order(ByteOrder.LITTLE_ENDIAN)
        var bytesWritten = 0L
        var totalSamplesLocal = 0L
        var sumSquaresLocal = 0.0
        var peakRmsLocal = 0.0
        var reads = 0
        var negativeCount = 0
        var lastNegativeCode = 0

        var out: FileOutputStream? = null
        try {
            out = FileOutputStream(part)
            out.write(buildWavHeader(0)) // provisional header, patched on finalizeAndRelease()

            while (recording) {
                val read = record.read(buffer, 0, buffer.size)
                if (read < 0) {
                    negativeCount++
                    lastNegativeCode = read
                    Log.e(TAG, "capture blocked or unavailable — reason=read_error code=$read")
                    break
                }
                if (read == 0) continue

                // Only complete stereo frames are ever written/counted — a
                // read() returning a shortcount not divisible by CHANNEL_COUNT
                // would otherwise desync the L/R interleaving and skew the
                // duration math (totalSamples / CHANNEL_COUNT) downstream.
                val validShorts = read - (read % CHANNEL_COUNT)
                if (validShorts <= 0) continue
                val pcmFramesInBuffer = validShorts / CHANNEL_COUNT

                pcmBytes.clear()
                var sumOfSquares = 0.0
                for (i in 0 until validShorts) {
                    val sample = buffer[i]
                    pcmBytes.putShort(sample)
                    val s = sample.toDouble()
                    sumOfSquares += s * s
                }
                // Only the valid, frame-aligned samples from this call —
                // never the full (possibly stale-tailed) buffer.
                out.write(pcmBytes.array(), 0, validShorts * 2)
                bytesWritten += validShorts * 2

                val rms = sqrt(sumOfSquares / validShorts)
                sumSquaresLocal += sumOfSquares
                totalSamplesLocal += validShorts
                reads++
                if (rms > peakRmsLocal) peakRmsLocal = rms

                if (reads % LOG_EVERY_N_READS == 0) {
                    val silent = rms < SILENCE_RMS_THRESHOLD
                    Log.d(
                        TAG,
                        "rmsLevel=${"%.1f".format(rms)} silenceDetected=$silent " +
                            "pcmFramesInBuffer=$pcmFramesInBuffer",
                    )
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "capture blocked or unavailable — reason=pcm_write_failed: ${e.message}", e)
        } finally {
            runCatching { out?.flush() }
            runCatching { out?.close() }
            pcmStreamClosed = true
        }

        pcmBytesWritten = bytesWritten
        totalSamples = totalSamplesLocal
        sumSquares = sumSquaresLocal
        peakRms = peakRmsLocal
        negativeReadCount = negativeCount
        lastNegativeReadCode = lastNegativeCode
    }

    /**
     * Non-blocking, idempotent, no-throw: signals the read loop to stop and
     * best-effort calls [AudioRecord.stop] only to unblock a pending/blocking
     * [AudioRecord.read] in [readLoop]. Never releases audioRecord or joins
     * the read thread — that is [finalizeAndRelease]'s job. Safe to call
     * repeatedly (including internally, from [finalizeAndRelease]) or even if
     * [start] never got past an early return.
     */
    fun requestStop() {
        if (stopRequested) return
        stopRequested = true
        recording = false
        runCatching { audioRecord?.stop() }
    }

    /**
     * Idempotent, blocking: calls [requestStop] first (defensive — safe even
     * if the caller already did, and avoids an unnecessary join timeout if it
     * didn't), then waits for the read thread, confirms the PCM stream
     * closed, patches the WAV header, renames .wav.part -> .wav, and releases
     * the AudioRecord. Runs its join/release/rename logic at most once per
     * [start] — a repeated call is a silent no-op. Safe to call even if
     * [start] never got past an early return.
     *
     * If the read thread is still alive after both waits below, the
     * .wav.part is preserved and never renamed/treated as a valid .wav.
     */
    fun finalizeAndRelease() {
        requestStop()
        if (!started || finalized) return
        finalized = true

        val record = audioRecord
        audioRecord = null

        val thread = readThread
        thread?.join(THREAD_JOIN_TIMEOUT_MS)

        var threadFinished = thread == null || !thread.isAlive
        if (threadFinished) {
            runCatching { record?.release() }
        } else {
            Log.e(
                TAG,
                "capture blocked or unavailable — reason=read_thread_timeout waitedMs=$THREAD_JOIN_TIMEOUT_MS " +
                    "path=${partFile?.absolutePath}",
            )
            runCatching { record?.release() }
            thread?.join(THREAD_JOIN_RETRY_TIMEOUT_MS)
            threadFinished = thread == null || !thread.isAlive
            if (!threadFinished) {
                Log.e(
                    TAG,
                    "capture blocked or unavailable — reason=read_thread_still_alive " +
                        "waitedMs=${THREAD_JOIN_TIMEOUT_MS + THREAD_JOIN_RETRY_TIMEOUT_MS} " +
                        "path=${partFile?.absolutePath} size=${partFile?.length() ?: -1} — preserving .wav.part",
                )
                readThread = null
                return
            }
        }
        readThread = null

        if (!pcmStreamClosed) {
            Log.e(
                TAG,
                "capture blocked or unavailable — reason=pcm_stream_not_confirmed_closed " +
                    "path=${partFile?.absolutePath} size=${partFile?.length() ?: -1} — preserving .wav.part",
            )
            return
        }

        finalizeWavFile()
        Log.d(TAG, "audio capture stopped")
    }

    /**
     * Patches the provisional WAV header with real RIFF/data sizes and
     * renames .wav.part -> .wav — but only when the patch and the resulting
     * file size are verifiably correct. Any failure preserves the .wav.part
     * for diagnosis instead of deleting it.
     */
    private fun finalizeWavFile() {
        val part = partFile
        val final = finalFile
        if (part == null || final == null) {
            Log.d(TAG, "capture blocked or unavailable — reason=no_output_file_recorded")
            return
        }
        if (!part.exists()) {
            Log.e(TAG, "capture blocked or unavailable — reason=part_file_missing path=${part.absolutePath}")
            return
        }

        val dataSize = pcmBytesWritten
        if (dataSize <= 0L) {
            Log.e(
                TAG,
                "capture blocked or unavailable — reason=no_pcm_data_written " +
                    "path=${part.absolutePath} size=${part.length()} — preserving .wav.part",
            )
            return
        }

        val patched = try {
            RandomAccessFile(part, "rw").use { raf ->
                val riffChunkSize = ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN)
                    .putInt((36L + dataSize).toInt()).array()
                raf.seek(4)
                raf.write(riffChunkSize)

                val dataChunkSize = ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN)
                    .putInt(dataSize.toInt()).array()
                raf.seek(40)
                raf.write(dataChunkSize)
            }
            true
        } catch (e: Exception) {
            Log.e(
                TAG,
                "capture blocked or unavailable — reason=header_patch_failed: ${e.message} " +
                    "path=${part.absolutePath} size=${part.length()} — preserving .wav.part",
                e,
            )
            false
        }

        val expectedFileSize = WAV_HEADER_SIZE + dataSize
        val actualFileSize = part.length()
        if (!patched || actualFileSize != expectedFileSize) {
            Log.e(
                TAG,
                "capture blocked or unavailable — reason=invalid_wav_file patched=$patched " +
                    "expectedSize=$expectedFileSize actualSize=$actualFileSize " +
                    "path=${part.absolutePath} — preserving .wav.part",
            )
            return
        }

        val renamed = try {
            part.renameTo(final)
        } catch (e: Exception) {
            Log.e(TAG, "capture blocked or unavailable — reason=rename_failed: ${e.message}", e)
            false
        }
        if (!renamed) {
            Log.e(
                TAG,
                "capture blocked or unavailable — reason=rename_failed " +
                    "path=${part.absolutePath} size=${part.length()} — preserving .wav.part",
            )
            return
        }

        val overallRms = if (totalSamples > 0) sqrt(sumSquares / totalSamples) else 0.0
        val silenceDetected = totalSamples == 0L || overallRms < SILENCE_RMS_THRESHOLD
        val durationMs = if (totalSamples > 0) {
            (totalSamples.toDouble() / CHANNEL_COUNT / SAMPLE_RATE * 1000).toLong()
        } else {
            0L
        }

        Log.d(
            TAG,
            "WAV saved path=${final.absolutePath} bytes=${final.length()} durationMs=$durationMs " +
                "sampleRate=$SAMPLE_RATE channels=$CHANNEL_COUNT minBufferSize=$minBufferSizeUsed " +
                "overallRmsLevel=${"%.1f".format(overallRms)} peakRmsLevel=${"%.1f".format(peakRms)} " +
                "negativeReadCodes=$negativeReadCount lastNegativeReadCode=$lastNegativeReadCode " +
                "silenceDetected=$silenceDetected",
        )
    }
}
