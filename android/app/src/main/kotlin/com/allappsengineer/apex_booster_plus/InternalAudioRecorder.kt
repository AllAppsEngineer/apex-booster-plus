package com.allappsengineer.apex_booster_plus

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioPlaybackCaptureConfiguration
import android.media.AudioRecord
import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMuxer
import android.media.projection.MediaProjection
import android.os.Build
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.io.RandomAccessFile
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.ArrayBlockingQueue
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicReference
import kotlin.math.abs
import kotlin.math.sqrt

/**
 * AUDIO-CAPTURE-U2.3: independent PCM copy handed off from the capture
 * thread to [InternalAudioRecorder]'s dedicated AAC encoder thread. Never
 * aliases the capture loop's reused buffers — [bytes] is this slot's own
 * fixed-capacity array, filled up to [validByteLength] on each handoff.
 */
private class AacPcmSlot(maxBytes: Int) {
    val bytes = ByteArray(maxBytes)
    var validByteLength = 0
    var validFrameCount = 0
}

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

        // AUDIO-CAPTURE-U2.3: AAC-LC encode of the same validated PCM,
        // isolated on its own thread — see ApexAacEncoderThread below.
        private const val AAC_MIME_TYPE = "audio/mp4a-latm"
        private const val AAC_BITRATE = 128_000
        private const val AAC_QUEUE_CAPACITY = 8
        private const val AAC_POLL_TIMEOUT_MS = 50L
        private const val AAC_INPUT_DEQUEUE_TIMEOUT_US = 10_000L

        // Operational budget for delivering one PCM chunk (fragmented, frame
        // aligned) to the encoder, and for the EOS handshake — exceeding
        // either invalidates the AAC session but never touches WAV/MP4.
        private const val AAC_FRAGMENT_BUDGET_MS = 200L
        private const val AAC_EOS_DRAIN_MAX_ATTEMPTS = 100
        private const val AAC_THREAD_JOIN_TIMEOUT_MS = 1_500L

        // Standard AAC-LC frame length in samples per channel — used only to
        // estimate the duration contributed by the last encoded frame, since
        // MediaExtractor exposes sample *start* times, not durations.
        private const val AAC_FRAME_SAMPLE_COUNT = 1_024L
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

    // AUDIO-CAPTURE-U2.3: AAC session state. aacSessionValid only ever moves
    // true -> false (never back), flipped exclusively through invalidateAac()
    // so the first reason wins and is never lost to a race between the
    // capture thread (queue/pool saturation) and the encoder thread (codec
    // errors). @Volatile because both threads write/read it.
    @Volatile
    private var aacSessionValid = false
    private val aacInvalidReason = AtomicReference<String?>(null)

    // Set (in a finally block) by the capture thread once no more PCM will
    // ever be produced — the encoder thread's only permitted signal to drain
    // its queue and move on to EOS.
    @Volatile
    private var aacProducerDone = false

    // Set by the encoder thread once its own MediaCodec/MediaMuxer
    // stop()/release() sequence has run (success or failure) — mirrors
    // pcmStreamClosed's role for the WAV path.
    @Volatile
    private var aacStreamClosed = false

    @Volatile
    private var aacEosOutputSeen = false

    // Single writer (encoder thread only) during encoding; read by the
    // caller's thread in validateAndPromoteAac() only after
    // ApexAacEncoderThread.join() returns — same happens-before reasoning as
    // pcmBytesWritten above.
    private var totalPcmFramesQueued = 0L

    private var aacEncoderThread: Thread? = null
    private var aacPart: File? = null
    private var aacFinal: File? = null

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
        val aacPartFile = File(outputDir, "apex_audio_poc_$timestamp.m4a.part")
        val aacFinalFile = File(outputDir, "apex_audio_poc_$timestamp.m4a")
        aacPart = aacPartFile
        aacFinal = aacFinalFile

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

        aacSessionValid = true
        aacInvalidReason.set(null)
        aacProducerDone = false
        aacStreamClosed = false
        aacEosOutputSeen = false
        totalPcmFramesQueued = 0L

        val maxChunkBytes = (minBufferSize / 2).coerceAtLeast(1) * 2
        val aacFreeSlots = ArrayBlockingQueue<AacPcmSlot>(AAC_QUEUE_CAPACITY)
        repeat(AAC_QUEUE_CAPACITY) { aacFreeSlots.offer(AacPcmSlot(maxChunkBytes)) }
        val aacWorkQueue = ArrayBlockingQueue<AacPcmSlot>(AAC_QUEUE_CAPACITY)

        val aacThread = Thread(
            { aacEncoderLoop(aacFreeSlots, aacWorkQueue, aacPartFile) },
            "ApexAacEncoderThread",
        )
        aacEncoderThread = aacThread
        aacThread.start()

        val thread = Thread(
            { readLoop(record, minBufferSize, part, aacFreeSlots, aacWorkQueue) },
            "ApexAudioCaptureThread",
        )
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

    private fun readLoop(
        record: AudioRecord,
        minBufferSize: Int,
        part: File,
        aacFreeSlots: ArrayBlockingQueue<AacPcmSlot>,
        aacWorkQueue: ArrayBlockingQueue<AacPcmSlot>,
    ) {
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

                // AUDIO-CAPTURE-U2.3: best-effort, non-blocking handoff of an
                // independent copy of this same validated chunk to the AAC
                // encoder thread. Any failure here is contained inside
                // submitPcmForAac() (invalidateAac()) and never touches the
                // WAV write above or this loop's control flow.
                runCatching {
                    submitPcmForAac(pcmBytes.array(), validShorts * 2, pcmFramesInBuffer, aacFreeSlots, aacWorkQueue)
                }

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
            // Must be set here, in the finally block, so the encoder thread
            // is guaranteed to observe "no more PCM coming" even if this
            // loop exits via an exception — otherwise it would poll its
            // queue forever and never reach EOS (req. 3).
            aacProducerDone = true
        }

        pcmBytesWritten = bytesWritten
        totalSamples = totalSamplesLocal
        sumSquares = sumSquaresLocal
        peakRms = peakRmsLocal
        negativeReadCount = negativeCount
        lastNegativeReadCode = lastNegativeCode
    }

    /**
     * Runs on the capture thread. Copies exactly [validByteLength] bytes
     * (already frame-aligned by the caller, same [validShorts]-derived value
     * used for the WAV write) out of the reused [sourceBytes] array into a
     * pooled [AacPcmSlot] — never a reference to a buffer the capture loop
     * will overwrite on its next iteration. Non-blocking: pool/queue
     * exhaustion invalidates the AAC session instead of waiting.
     */
    private fun submitPcmForAac(
        sourceBytes: ByteArray,
        validByteLength: Int,
        pcmFramesInBuffer: Int,
        aacFreeSlots: ArrayBlockingQueue<AacPcmSlot>,
        aacWorkQueue: ArrayBlockingQueue<AacPcmSlot>,
    ) {
        if (!aacSessionValid) return
        val slot = aacFreeSlots.poll()
        if (slot == null) {
            invalidateAac("aac_buffer_pool_exhausted")
            return
        }
        System.arraycopy(sourceBytes, 0, slot.bytes, 0, validByteLength)
        slot.validByteLength = validByteLength
        slot.validFrameCount = pcmFramesInBuffer
        if (!aacWorkQueue.offer(slot)) {
            // Nobody will ever consume this slot now — return it so the pool
            // doesn't shrink for the (already invalidated) rest of the session.
            aacFreeSlots.offer(slot)
            invalidateAac("aac_queue_saturated")
        }
    }

    /**
     * Single, thread-safe choke point for every AAC failure path (capture
     * thread: pool/queue saturation; encoder thread: codec/muxer/validation
     * errors). Preserves only the first reason via CAS, flips
     * [aacSessionValid] to false (a one-way transition for the session), and
     * never throws — safe to call from either thread at any time without any
     * risk of affecting WAV, video/MP4, or ScreenCaptureService.
     */
    private fun invalidateAac(reason: String) {
        aacSessionValid = false
        if (aacInvalidReason.compareAndSet(null, reason)) {
            Log.e(TAG, "capture blocked or unavailable — reason=$reason (aac)")
        }
    }

    /**
     * Runs entirely on ApexAacEncoderThread — the only thread that ever
     * touches [MediaCodec]/[MediaMuxer] for this session. Consumes
     * [aacWorkQueue] until the capture thread signals [aacProducerDone] AND
     * the queue is empty, then performs the EOS handshake. Every failure
     * path routes through [invalidateAac]; cleanup in the trailing block
     * always runs so native resources are released regardless of outcome.
     */
    private fun aacEncoderLoop(
        aacFreeSlots: ArrayBlockingQueue<AacPcmSlot>,
        aacWorkQueue: ArrayBlockingQueue<AacPcmSlot>,
        aacPartFile: File,
    ) {
        var codec: MediaCodec? = null
        var muxer: MediaMuxer? = null
        var muxerTrackIndex = -1
        var muxerStarted = false
        var formatChangeCount = 0
        var lastWrittenPtsUs = -1L
        val bufferInfo = MediaCodec.BufferInfo()

        fun drainOutput(timeoutUs: Long): Boolean {
            val enc = codec ?: return false
            while (true) {
                val outIndex = enc.dequeueOutputBuffer(bufferInfo, timeoutUs)
                when {
                    outIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                        if (muxerStarted) {
                            formatChangeCount++
                            if (formatChangeCount > 1) {
                                invalidateAac("aac_unexpected_format_change")
                                return aacEosOutputSeen
                            }
                        } else {
                            try {
                                val newMuxer = MediaMuxer(
                                    aacPartFile.absolutePath,
                                    MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4,
                                )
                                val trackIndex = newMuxer.addTrack(enc.outputFormat)
                                newMuxer.start()
                                muxer = newMuxer
                                muxerTrackIndex = trackIndex
                                muxerStarted = true
                            } catch (e: Exception) {
                                invalidateAac("aac_muxer_start_failed")
                                return aacEosOutputSeen
                            }
                        }
                    }
                    outIndex == MediaCodec.INFO_TRY_AGAIN_LATER -> return aacEosOutputSeen
                    outIndex >= 0 -> {
                        try {
                            val isConfigOnly = (bufferInfo.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG) != 0
                            if (bufferInfo.size > 0 && !isConfigOnly) {
                                val activeMuxer = muxer
                                if (!muxerStarted || activeMuxer == null) {
                                    invalidateAac("aac_sample_before_muxer_start")
                                } else if (bufferInfo.presentationTimeUs < lastWrittenPtsUs) {
                                    invalidateAac("aac_pts_non_monotonic")
                                } else {
                                    val outBuf = enc.getOutputBuffer(outIndex)
                                    if (outBuf != null) {
                                        outBuf.position(bufferInfo.offset)
                                        outBuf.limit(bufferInfo.offset + bufferInfo.size)
                                        activeMuxer.writeSampleData(muxerTrackIndex, outBuf, bufferInfo)
                                        lastWrittenPtsUs = bufferInfo.presentationTimeUs
                                    }
                                }
                            }
                            if ((bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
                                aacEosOutputSeen = true
                            }
                        } finally {
                            runCatching { enc.releaseOutputBuffer(outIndex, false) }
                        }
                        if (aacEosOutputSeen) return true
                    }
                }
            }
        }

        fun encodeSlot(slot: AacPcmSlot) {
            val enc = codec ?: return
            val frameSizeBytes = CHANNEL_COUNT * 2
            var offset = 0
            val deadline = System.nanoTime() + AAC_FRAGMENT_BUDGET_MS * 1_000_000L
            while (offset < slot.validByteLength && aacSessionValid) {
                val inIndex = enc.dequeueInputBuffer(AAC_INPUT_DEQUEUE_TIMEOUT_US)
                if (inIndex < 0) {
                    if (System.nanoTime() > deadline) break
                    continue
                }
                val inputBuffer = enc.getInputBuffer(inIndex)
                if (inputBuffer == null) {
                    invalidateAac("aac_input_buffer_unavailable")
                    break
                }
                inputBuffer.clear()
                val remaining = slot.validByteLength - offset
                val rawFit = minOf(inputBuffer.capacity(), remaining)
                // Never splits a stereo frame across two input buffers.
                val fit = rawFit - (rawFit % frameSizeBytes)
                if (fit <= 0) break
                inputBuffer.put(slot.bytes, offset, fit)
                val ptsUs = totalPcmFramesQueued * 1_000_000L / SAMPLE_RATE
                try {
                    enc.queueInputBuffer(inIndex, 0, fit, ptsUs, 0)
                } catch (e: Exception) {
                    invalidateAac("aac_queue_input_failed")
                    break
                }
                totalPcmFramesQueued += fit / frameSizeBytes
                offset += fit
                drainOutput(0L)
            }
            if (offset < slot.validByteLength) {
                // A chunk that could not be delivered whole, within budget,
                // is never partially represented in the AAC — the whole
                // session is invalid, but WAV/MP4 are untouched.
                invalidateAac("aac_chunk_incomplete")
            }
        }

        try {
            val format = MediaFormat.createAudioFormat(AAC_MIME_TYPE, SAMPLE_RATE, CHANNEL_COUNT).apply {
                setInteger(MediaFormat.KEY_BIT_RATE, AAC_BITRATE)
                setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC)
                setInteger(MediaFormat.KEY_PCM_ENCODING, AudioFormat.ENCODING_PCM_16BIT)
            }
            val enc = MediaCodec.createEncoderByType(AAC_MIME_TYPE)
            enc.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
            enc.start()
            codec = enc
        } catch (e: Exception) {
            invalidateAac("aac_encoder_init_failed: ${e.message}")
        }

        // Drains the work queue regardless of validity — an invalidated
        // session still recycles slots back to the pool so the capture
        // thread's non-blocking submitPcmForAac() degrades cleanly instead
        // of tripping aac_buffer_pool_exhausted on every remaining chunk.
        while (true) {
            val slot = aacWorkQueue.poll(AAC_POLL_TIMEOUT_MS, TimeUnit.MILLISECONDS)
            if (slot != null) {
                if (aacSessionValid) encodeSlot(slot)
                aacFreeSlots.offer(slot)
                continue
            }
            if (aacProducerDone && aacWorkQueue.isEmpty()) break
        }

        if (aacSessionValid) {
            val enc = codec
            if (enc == null) {
                invalidateAac("aac_encoder_missing_at_eos")
            } else {
                var eosSent = false
                val eosDeadline = System.nanoTime() + AAC_FRAGMENT_BUDGET_MS * 1_000_000L
                while (System.nanoTime() < eosDeadline) {
                    val inIndex = enc.dequeueInputBuffer(AAC_INPUT_DEQUEUE_TIMEOUT_US)
                    if (inIndex >= 0) {
                        val ptsUs = totalPcmFramesQueued * 1_000_000L / SAMPLE_RATE
                        try {
                            enc.queueInputBuffer(inIndex, 0, 0, ptsUs, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            eosSent = true
                        } catch (e: Exception) {
                            invalidateAac("aac_eos_queue_failed")
                        }
                        break
                    }
                }
                if (!eosSent) {
                    invalidateAac("aac_eos_input_timeout")
                } else {
                    var attempts = 0
                    while (!aacEosOutputSeen && attempts < AAC_EOS_DRAIN_MAX_ATTEMPTS && aacSessionValid) {
                        drainOutput(AAC_INPUT_DEQUEUE_TIMEOUT_US)
                        attempts++
                    }
                    if (!aacEosOutputSeen) {
                        invalidateAac("aac_eos_output_timeout")
                    }
                }
            }
        }

        runCatching { if (muxerStarted) muxer?.stop() }.onFailure { invalidateAac("aac_muxer_stop_failed") }
        runCatching { muxer?.release() }
        runCatching { codec?.stop() }
        runCatching { codec?.release() }
        aacStreamClosed = true
    }

    /**
     * Runs on the caller's thread, only after ApexAacEncoderThread.join() has
     * confirmed the thread finished — the same happens-before guarantee used
     * for the WAV-side fields. Promotes .m4a.part -> .m4a only when the
     * session stayed valid end to end AND an independent MediaExtractor pass
     * confirms exactly one playable audio/mp4a-latm track with monotonic PTS
     * and a duration consistent with the PCM frames actually queued. Any
     * failure preserves the .m4a.part (debug-only path, gated upstream by
     * isDebuggableBuild() in ScreenCaptureService) and never touches WAV/MP4.
     */
    private fun validateAndPromoteAac() {
        if (!aacSessionValid) {
            Log.e(
                TAG,
                "capture blocked or unavailable — reason=${aacInvalidReason.get() ?: "aac_session_invalid"} " +
                    "(aac) — .m4a not promoted",
            )
            return
        }
        if (!aacStreamClosed || !aacEosOutputSeen) {
            invalidateAac("aac_stream_incomplete")
            return
        }
        if (totalPcmFramesQueued <= 0L) {
            invalidateAac("no_pcm_frames_queued")
            return
        }
        val part = aacPart
        val final = aacFinal
        if (part == null || final == null || !part.exists() || part.length() <= 0L) {
            invalidateAac("aac_part_missing_or_empty")
            return
        }

        val expectedDurationUs = totalPcmFramesQueued * 1_000_000L / SAMPLE_RATE
        val estimatedLastSampleDurationUs = AAC_FRAME_SAMPLE_COUNT * 1_000_000L / SAMPLE_RATE

        val extractor = MediaExtractor()
        try {
            extractor.setDataSource(part.absolutePath)
            if (extractor.trackCount != 1) {
                invalidateAac("aac_track_count_unexpected")
                return
            }
            val format = extractor.getTrackFormat(0)
            if (format.getString(MediaFormat.KEY_MIME) != AAC_MIME_TYPE) {
                invalidateAac("aac_track_mime_mismatch")
                return
            }
            extractor.selectTrack(0)

            var sampleCount = 0
            var firstPtsUs = -1L
            var lastPtsUs = -1L
            val scratch = ByteBuffer.allocate(256 * 1024)
            while (true) {
                val size = extractor.readSampleData(scratch, 0)
                if (size < 0) break
                val pts = extractor.sampleTime
                if (firstPtsUs < 0L) firstPtsUs = pts
                if (pts < lastPtsUs) {
                    invalidateAac("aac_extractor_pts_non_monotonic")
                    return
                }
                lastPtsUs = pts
                sampleCount++
                extractor.advance()
            }
            if (sampleCount == 0 || firstPtsUs < 0L) {
                invalidateAac("aac_extractor_no_samples")
                return
            }

            val actualDurationUs = (lastPtsUs - firstPtsUs) + estimatedLastSampleDurationUs
            val toleranceUs = maxOf(250_000L, expectedDurationUs * 3L / 100L)
            if (abs(actualDurationUs - expectedDurationUs) > toleranceUs) {
                invalidateAac("aac_duration_mismatch")
                Log.e(
                    TAG,
                    "capture blocked or unavailable — reason=aac_duration_mismatch (aac) " +
                        "actualDurationUs=$actualDurationUs expectedDurationUs=$expectedDurationUs " +
                        "toleranceUs=$toleranceUs",
                )
                return
            }
        } catch (e: Exception) {
            invalidateAac("aac_extractor_validation_failed: ${e.message}")
            return
        } finally {
            runCatching { extractor.release() }
        }

        val renamed = try {
            part.renameTo(final)
        } catch (e: Exception) {
            Log.e(TAG, "capture blocked or unavailable — reason=aac_rename_failed: ${e.message} (aac)", e)
            false
        }
        if (!renamed) {
            invalidateAac("aac_rename_failed")
            return
        }

        Log.d(
            TAG,
            "AAC saved path=${final.absolutePath} bytes=${final.length()} " +
                "framesQueued=$totalPcmFramesQueued expectedDurationUs=$expectedDurationUs",
        )
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

        // AUDIO-CAPTURE-U2.3: bounded wait for the AAC encoder thread — never
        // indefinite. requestStop()/the capture-thread join above already
        // guarantee aacProducerDone=true was set (in a finally block) once
        // the capture thread confirmed finished, so a healthy encoder thread
        // has everything it needs to reach EOS and exit on its own by now.
        val aacThread = aacEncoderThread
        aacEncoderThread = null
        if (aacThread != null) {
            aacThread.join(AAC_THREAD_JOIN_TIMEOUT_MS)
            if (aacThread.isAlive) {
                invalidateAac("aac_thread_timeout")
                Log.e(
                    TAG,
                    "capture blocked or unavailable — reason=aac_thread_timeout waitedMs=$AAC_THREAD_JOIN_TIMEOUT_MS " +
                        "path=${aacPart?.absolutePath} (aac) — preserving .m4a.part",
                )
            } else {
                validateAndPromoteAac()
            }
        }

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
