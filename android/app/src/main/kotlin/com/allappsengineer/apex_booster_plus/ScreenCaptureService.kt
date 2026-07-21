package com.allappsengineer.apex_booster_plus

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.Image
import android.media.ImageReader
import android.media.MediaMetadataRetriever
import android.media.MediaRecorder
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.HandlerThread
import android.os.IBinder
import android.util.Log
import android.widget.Toast
import androidx.core.app.NotificationCompat
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import org.json.JSONArray
import org.json.JSONObject

/**
 * Foreground service for Modo Captura da Sessão (SOCIAL-U2B rework).
 * Arms once with a user-granted MediaProjection and stays idle until
 * [captureNow] is called (from the native A+ mini-menu), capturing a single
 * on-demand frame per call without re-prompting for consent.
 *
 * SOCIAL-U7A (Opção B): a session is print XOR video, chosen before arming
 * via [EXTRA_SESSION_MODE] — never both, since a single MediaProjection
 * instance can only back one VirtualDisplay for its whole lifetime on
 * API 34+. [MODE_SCREENSHOT] builds the ImageReader/VirtualDisplay pipeline
 * at arm time; [MODE_VIDEO] defers its VirtualDisplay to [startVideoRecording].
 */
class ScreenCaptureService : Service() {

    companion object {
        const val EXTRA_RESULT_CODE = "result_code"
        const val EXTRA_RESULT_DATA = "result_data"
        const val EXTRA_SESSION_MODE = "session_mode"
        const val EXTRA_VIDEO_DURATION_MS = "video_duration_ms"

        // SOCIAL-U7A (Opção B): a sessão é print OU vídeo, nunca ambos — cada
        // MediaProjection só pode gerar um único VirtualDisplay em API 34+.
        const val MODE_SCREENSHOT = "screenshot"
        const val MODE_VIDEO = "video"

        private const val NOTIFICATION_ID = 9_001
        private const val CHANNEL_ID = "apex_capture_channel"
        private const val TAG = "ScreenCaptureService"
        private const val CAPTURE_RETRY_DELAY_MS = 150L
        private const val MAX_INDEX_ENTRIES = 60

        // SOCIAL-U7B: short/manual clip recording, no audio, user-selectable
        // duration. EXTRA_VIDEO_DURATION_MS is re-validated against this
        // exact list so an unexpected value can never set an out-of-range cap.
        val ALLOWED_VIDEO_DURATIONS_MS = longArrayOf(10_000L, 15_000L, 30_000L, 60_000L)
        const val DEFAULT_VIDEO_DURATION_MS = 10_000L
        private const val VIDEO_BITRATE = 6_000_000
        private const val VIDEO_FRAME_RATE = 30
        private const val MAX_VIDEO_DIMENSION = 1280

        // Live reference to the running armed session, if any. Read from the
        // main thread by FloatingOverlayManager when the A+ mini-menu is tapped.
        @Volatile
        var instance: ScreenCaptureService? = null
            private set
    }

    private var mediaProjection: MediaProjection? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var imageReader: ImageReader? = null
    private var captureThread: HandlerThread? = null
    private var backgroundHandler: Handler? = null

    private var captureWidth = 0
    private var captureHeight = 0

    @Volatile
    private var armed = false

    @Volatile
    private var stopped = false

    @Volatile
    private var sessionMode: String = MODE_SCREENSHOT

    // SOCIAL-U7A: short/manual clip recording state — separate VirtualDisplay
    // from the same MediaProjection, active only during the recording window.
    private var mediaRecorder: MediaRecorder? = null
    private var videoVirtualDisplay: VirtualDisplay? = null
    private var recordingFile: File? = null
    private var mainHandler: Handler? = null
    private var stopRecordingRunnable: Runnable? = null

    // SOCIAL-U7B: recording cap for the current/next video session,
    // validated against ALLOWED_VIDEO_DURATIONS_MS in onStartCommand.
    @Volatile
    private var videoDurationMs: Long = DEFAULT_VIDEO_DURATION_MS

    @Volatile
    private var recording = false

    // DEBUG-U1: set for the duration of stopVideoRecording() so the
    // MediaProjection.Callback.onStop() fired by our OWN mediaProjection.stop()
    // call at the end of that sequence (Android invokes onStop for
    // self-initiated stops too, not just externally revoked ones) doesn't
    // re-enter stopSession()/stopVideoRecording(discard=true) while the
    // stop -> validate -> register sequence is still finishing.
    @Volatile
    private var internalStopInProgress = false

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        instance = this
        mainHandler = Handler(mainLooper)
    }

    fun isArmed(): Boolean = armed

    /** Active mode for the current armed session — [MODE_SCREENSHOT] or [MODE_VIDEO]. */
    fun getMode(): String = sessionMode

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // 1. Foreground notification first — required before touching MediaProjection APIs.
        createNotificationChannel()
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentText(getString(R.string.capture_notification_text))
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        if (armed) {
            // Duplicate start command while already armed — nothing else to do.
            return START_NOT_STICKY
        }

        // 2. Extract the MediaProjection token and session mode from the consent result.
        val resultCode = intent?.getIntExtra(EXTRA_RESULT_CODE, -1) ?: -1
        val resultData = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent?.getParcelableExtra(EXTRA_RESULT_DATA, Intent::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent?.getParcelableExtra<Intent>(EXTRA_RESULT_DATA)
        }
        val mode = intent?.getStringExtra(EXTRA_SESSION_MODE)
            ?.takeIf { it == MODE_VIDEO }
            ?: MODE_SCREENSHOT
        sessionMode = mode

        // SOCIAL-U7B: re-validate the requested duration server-side (in the
        // service, not just MainActivity) — defense in depth against a
        // malformed/out-of-range Intent extra.
        val requestedDurationMs =
            intent?.getLongExtra(EXTRA_VIDEO_DURATION_MS, DEFAULT_VIDEO_DURATION_MS)
                ?: DEFAULT_VIDEO_DURATION_MS
        videoDurationMs = if (ALLOWED_VIDEO_DURATIONS_MS.contains(requestedDurationMs)) {
            requestedDurationMs
        } else {
            DEFAULT_VIDEO_DURATION_MS
        }

        if (resultData == null) {
            Log.e(TAG, "Missing result data; aborting.")
            stopSession()
            return START_NOT_STICKY
        }

        // 3. Display dimensions — an arm-time snapshot, used only to size the
        // screenshot pipeline's fixed ImageReader/VirtualDisplay (built right
        // here, in this same call). Video recording does NOT reuse these:
        // see the fresh re-measure in startVideoRecording().
        val (w, h, density) = measureDisplayMetrics()
        captureWidth = w
        captureHeight = h

        // 4. Create the MediaProjection from the already-granted consent.
        val mpm = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        val projection = mpm.getMediaProjection(resultCode, resultData)
        if (projection == null) {
            Log.e(TAG, "MediaProjection is null; aborting.")
            stopSession()
            return START_NOT_STICKY
        }
        mediaProjection = projection

        // 5. Register callback BEFORE any createVirtualDisplay call (required on API 34+).
        //    Fires if the user revokes the capture permission mid-session — cleans up
        //    the service instead of leaving a dangling armed state. Registered
        //    regardless of mode.
        projection.registerCallback(object : MediaProjection.Callback() {
            override fun onStop() {
                if (internalStopInProgress) {
                    Log.d(TAG, "MediaProjection onStop — internal stop already in progress, ignoring re-entrant callback.")
                    return
                }
                Log.d(TAG, "MediaProjection stopped externally; ending session.")
                stopSession()
            }
        }, Handler(mainLooper))

        // SOCIAL-U7A (Opção B): a mesma MediaProjection só pode gerar UM
        // VirtualDisplay durante todo o seu ciclo de vida (API 34+). Por isso
        // o pipeline de screenshot (thread + ImageReader + VirtualDisplay) só
        // é montado no modo print; no modo vídeo, o único VirtualDisplay da
        // sessão é criado depois, em startVideoRecording().
        if (mode == MODE_SCREENSHOT) {
            // 6. Background thread reused for every on-demand capture while armed.
            val thread = HandlerThread("ApexCaptureThread").also { it.start() }
            captureThread = thread
            backgroundHandler = Handler(thread.looper)

            // 7. ImageReader — frames queue here continuously while the VirtualDisplay mirrors.
            val reader = ImageReader.newInstance(w, h, PixelFormat.RGBA_8888, 2)
            imageReader = reader

            // 8. VirtualDisplay pointing to the ImageReader surface — idle/armed until captureNow().
            virtualDisplay = projection.createVirtualDisplay(
                "ApexCaptureSession",
                w, h, density,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                reader.surface,
                null,
                null,
            )
        }

        armed = true
        Log.d(TAG, "Session armed (mode=$mode).")
        return START_NOT_STICKY
    }

    /**
     * Captures a single frame on demand, reusing the MediaProjection already
     * authorized when the session was armed. No new consent dialog, no Flutter
     * round-trip, no share sheet.
     *
     * One-shot: whatever the outcome, the session is torn down right after —
     * see [endSessionAfterCapture]. A new capture requires re-arming (new
     * consent) from the app.
     */
    fun captureNow() {
        val handler = backgroundHandler
        if (!armed || sessionMode != MODE_SCREENSHOT || handler == null) {
            Log.d(TAG, "captureNow ignored — session not armed for screenshot mode.")
            return
        }
        notifyToast(getString(R.string.capture_capturing_text))
        handler.post { captureFrameWithRetry(retriesLeft = 1) }
    }

    private fun captureFrameWithRetry(retriesLeft: Int) {
        val reader = imageReader ?: return
        val handler = backgroundHandler ?: return
        val image = reader.acquireLatestImage()
        if (image == null) {
            if (retriesLeft > 0) {
                handler.postDelayed({ captureFrameWithRetry(retriesLeft - 1) }, CAPTURE_RETRY_DELAY_MS)
            } else {
                Log.e(TAG, "No frame available for capture.")
                notifyToast(getString(R.string.capture_error_text))
                endSessionAfterCapture()
            }
            return
        }
        processFrame(image)
    }

    private fun processFrame(image: Image) {
        try {
            val w = captureWidth
            val h = captureHeight
            val planes = image.planes
            val buffer = planes[0].buffer
            val pixelStride = planes[0].pixelStride
            val rowStride = planes[0].rowStride
            val rowPadding = if (pixelStride > 0) rowStride - pixelStride * w else 0
            val bitmapWidth = if (pixelStride > 0) w + rowPadding / pixelStride else w

            val bitmap = Bitmap.createBitmap(bitmapWidth, h, Bitmap.Config.ARGB_8888)
            bitmap.copyPixelsFromBuffer(buffer)
            val cropped = Bitmap.createBitmap(bitmap, 0, 0, w, h)
            bitmap.recycle()
            image.close()

            val filePath = saveBitmap(cropped)
            cropped.recycle()

            if (filePath != null) {
                Log.d(TAG, "Capture saved: $filePath")
                notifyToast(getString(R.string.capture_saved_text))
            } else {
                notifyToast(getString(R.string.capture_error_text))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error capturing frame: ${e.message}", e)
            try { image.close() } catch (_: Exception) {}
            notifyToast(getString(R.string.capture_error_text))
        } finally {
            endSessionAfterCapture()
        }
    }

    /**
     * Starts a fixed-length (VIDEO_DURATION_MS), audio-free recording of the
     * armed session, reusing the already-authorized MediaProjection. Uses a
     * dedicated VirtualDisplay pointing at MediaRecorder's input surface —
     * distinct from the ImageReader-backed one used for screenshots — so
     * captureNow() and startVideoRecording() never share a Surface.
     */
    fun startVideoRecording() {
        val projection = mediaProjection
        Log.d(TAG, "action=start_video requestedDurationMs=$videoDurationMs")
        if (!armed || sessionMode != MODE_VIDEO || recording || projection == null) {
            Log.d(TAG, "startVideoRecording ignored — not armed for video mode, already recording, or no projection.")
            return
        }

        val dir = File(getExternalFilesDir(Environment.DIRECTORY_MOVIES), "apex_clips")
        if (!dir.mkdirs() && !dir.exists()) {
            Log.e(TAG, "Failed to create clips directory: $dir")
            notifyToast(getString(R.string.capture_video_error_text))
            return
        }

        // VIDEO-ORIENTATION-FIX: re-measure the live display right here,
        // instead of reusing captureWidth/captureHeight from armSession()
        // time. The armed session can sit idle for minutes while Apex
        // Booster+ (portrait-locked) is backgrounded and the user opens a
        // landscape-forced game — the stale portrait bounds from arm time
        // would otherwise size this VirtualDisplay/MediaRecorder as
        // portrait, and AUTO_MIRROR would letterbox the real (landscape)
        // content inside it, baking permanent black bars into the MP4.
        val (liveW, liveH, liveDensity) = measureDisplayMetrics()
        val (videoW, videoH) = computeSafeVideoSize(liveW, liveH)
        val file = File(dir, "apex_clip_${System.currentTimeMillis()}.mp4")
        val rotation = try {
            @Suppress("DEPRECATION")
            (getSystemService(Context.WINDOW_SERVICE) as android.view.WindowManager).defaultDisplay.rotation
        } catch (e: Exception) {
            -1
        }
        Log.d(
            TAG,
            "outputPath=${file.absolutePath} measuredWidth=$liveW measuredHeight=$liveH " +
                "videoWidth=$videoW videoHeight=$videoH rotation=$rotation",
        )

        val recorder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            MediaRecorder(this)
        } else {
            @Suppress("DEPRECATION")
            MediaRecorder()
        }

        try {
            recorder.setVideoSource(MediaRecorder.VideoSource.SURFACE)
            recorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
            recorder.setOutputFile(file.absolutePath)
            recorder.setVideoEncoder(MediaRecorder.VideoEncoder.H264)
            recorder.setVideoSize(videoW, videoH)
            recorder.setVideoFrameRate(VIDEO_FRAME_RATE)
            recorder.setVideoEncodingBitRate(VIDEO_BITRATE)
            recorder.prepare()
            Log.d(TAG, "recorder prepared")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to prepare MediaRecorder: ${e.message}", e)
            runCatching { recorder.release() }
            notifyToast(getString(R.string.capture_video_error_text))
            return
        }

        // Defensive try/catch: this is the session's only createVirtualDisplay
        // call (mode == MODE_VIDEO guarantees no screenshot VirtualDisplay was
        // created for this MediaProjection), but any other reuse/timeout edge
        // case must be handled as an error, not a process crash.
        val display = try {
            projection.createVirtualDisplay(
                "ApexRecordSession",
                videoW, videoH, liveDensity,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                recorder.surface,
                null,
                null,
            )
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException creating recording VirtualDisplay: ${e.message}", e)
            null
        }
        if (display == null) {
            Log.e(TAG, "Failed to create recording VirtualDisplay.")
            runCatching { recorder.release() }
            notifyToast(getString(R.string.capture_video_error_text))
            return
        }

        try {
            recorder.start()
            Log.d(TAG, "recorder started")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start MediaRecorder: ${e.message}", e)
            runCatching { display.release() }
            runCatching { recorder.release() }
            notifyToast(getString(R.string.capture_video_error_text))
            return
        }

        mediaRecorder = recorder
        videoVirtualDisplay = display
        recordingFile = file
        recording = true

        updateNotification(getString(R.string.capture_notification_recording_text))
        notifyToast(getString(R.string.capture_recording_text))

        val runnable = Runnable {
            Log.d(TAG, "stop requested by timer")
            stopVideoRecording(discard = false)
        }
        stopRecordingRunnable = runnable
        mainHandler?.postDelayed(runnable, videoDurationMs)
    }

    /**
     * Ends the recording (auto cap or abnormal teardown) and finalizes the
     * MediaMuxer via MediaRecorder.stop(). [discard] forces the clip to be
     * deleted even if stop() succeeds — used from stopSession() when the
     * session is torn down outside the normal recording flow, so a
     * possibly-incomplete file is never surfaced as valid.
     */
    fun stopVideoRecording(discard: Boolean) {
        if (!recording) return
        recording = false
        // DEBUG-U1: block the MediaProjection.Callback.onStop() re-entrancy
        // path for the duration of this stop -> validate -> register
        // sequence; only cleared in the finally block below, after the clip
        // is either registered or discarded.
        internalStopInProgress = true
        stopRecordingRunnable?.let { mainHandler?.removeCallbacks(it) }
        stopRecordingRunnable = null

        val recorder = mediaRecorder
        mediaRecorder = null
        val display = videoVirtualDisplay
        videoVirtualDisplay = null
        val file = recordingFile
        recordingFile = null

        try {
            // BUGFIX-U1: [discard] used to force this clip to be thrown away
            // unconditionally whenever stopVideoRecording() was reached from
            // anywhere other than the auto-stop timer (e.g. stopSession()
            // called while still recording). In real usage that path fires
            // far more often than a genuine broken/external teardown — e.g.
            // FloatingCaptureCard._syncState() (Dart) reconciles "armed" vs
            // "overlay showing" on every AppLifecycleState.resumed, and the
            // overlay is deliberately hidden during recording (so the A+
            // button never appears in the clip); a resume mid-recording read
            // that as drift and called disarmSession(), discarding an
            // otherwise perfectly valid, non-empty, playable clip every
            // time. MediaRecorder.stop() finalizes the MP4 container (moov
            // atom) correctly as long as it doesn't throw, whether the timer
            // or an early teardown triggered it — so validity should be
            // decided by inspecting the actual output file, not by which
            // caller asked for the stop. [discard] is now informational only
            // (logged below); [stopOk] tracks the one case that genuinely
            // makes the file untrustworthy: recorder.stop() itself throwing.
            var stopOk = true
            if (recorder != null) {
                try {
                    recorder.stop()
                    Log.d(TAG, "recorder stopped ok")
                } catch (e: Exception) {
                    Log.e(TAG, "Error stopping MediaRecorder: ${e.message}", e)
                    stopOk = false
                }
                runCatching { recorder.release() }
            }
            runCatching { display?.release() }

            val exists = file?.exists() == true
            val size = if (exists) file!!.length() else -1L
            Log.d(TAG, "output exists=$exists size=$size discard=$discard")

            var durationMs = -1L
            if (stopOk && exists && size > 0L) {
                val retriever = MediaMetadataRetriever()
                durationMs = try {
                    retriever.setDataSource(file!!.absolutePath)
                    retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                        ?.toLongOrNull() ?: -1L
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to read clip metadata duration: ${e.message}", e)
                    -1L
                } finally {
                    runCatching { retriever.release() }
                }
                Log.d(TAG, "metadata duration=${durationMs}ms")
            }

            if (stopOk && exists && size > 0L && durationMs > 0L) {
                registerClip(file!!)
                Log.d(TAG, "clip registered in index path=${file.absolutePath}")
                // Uses the clip's actual measured duration, not the
                // requested cap — an early-but-valid stop (see BUGFIX-U1
                // above) records less than videoDurationMs, and the toast
                // must reflect what was really saved.
                val seconds = (durationMs / 1_000L).toInt().coerceAtLeast(1)
                notifyToast(getString(R.string.capture_video_saved_with_duration, seconds))
            } else {
                Log.e(
                    TAG,
                    "clip rejected — stopOk=$stopOk exists=$exists size=$size durationMs=$durationMs",
                )
                file?.let { runCatching { it.delete() } }
                notifyToast(getString(R.string.capture_video_error_text))
            }

            if (armed) {
                updateNotification(getString(R.string.capture_notification_text))
            }
        } finally {
            internalStopInProgress = false
        }
        endSessionAfterCapture()
    }

    /**
     * Reads the live display bounds/density at the moment of the call.
     * Called at arm time (to size the screenshot pipeline) and again, fresh,
     * right before [startVideoRecording] builds its VirtualDisplay — the
     * armed session can sit idle for minutes between the two, during which
     * the visible app's orientation (e.g. a landscape-forced game) may have
     * changed entirely from what it was at arm time.
     */
    private fun measureDisplayMetrics(): Triple<Int, Int, Int> {
        val windowManager = getSystemService(Context.WINDOW_SERVICE) as android.view.WindowManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val bounds = windowManager.currentWindowMetrics.bounds
            Triple(bounds.width(), bounds.height(), resources.displayMetrics.densityDpi)
        } else {
            @Suppress("DEPRECATION")
            val display = windowManager.defaultDisplay
            val metrics = android.util.DisplayMetrics()
            @Suppress("DEPRECATION")
            display.getRealMetrics(metrics)
            Triple(metrics.widthPixels, metrics.heightPixels, metrics.densityDpi)
        }
    }

    private fun computeSafeVideoSize(w: Int, h: Int): Pair<Int, Int> {
        var targetW = w
        var targetH = h
        val longSide = maxOf(w, h)
        if (longSide > MAX_VIDEO_DIMENSION) {
            val scale = MAX_VIDEO_DIMENSION.toDouble() / longSide
            targetW = (w * scale).toInt()
            targetH = (h * scale).toInt()
        }
        targetW = (targetW / 16).coerceAtLeast(1) * 16
        targetH = (targetH / 16).coerceAtLeast(1) * 16
        return targetW to targetH
    }

    private fun updateNotification(text: String) {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentText(text)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTIFICATION_ID, notification)
    }

    /**
     * Appends the clip to apex_clips/index.json with a "type": "video" marker
     * so Flutter's gallery service can merge it with the screenshot index.
     * Best-effort, mirrors [registerCapture].
     */
    private fun registerClip(file: File) {
        try {
            val dir = file.parentFile ?: return
            val indexFile = File(dir, "index.json")
            val entries = if (indexFile.exists()) {
                JSONArray(indexFile.readText())
            } else {
                JSONArray()
            }
            entries.put(JSONObject().apply {
                put("type", "video")
                put("path", file.absolutePath)
                put("timestamp", System.currentTimeMillis())
            })
            val trimmed = if (entries.length() > MAX_INDEX_ENTRIES) {
                JSONArray(
                    (entries.length() - MAX_INDEX_ENTRIES until entries.length())
                        .map { entries.get(it) },
                )
            } else {
                entries
            }
            indexFile.writeText(trimmed.toString())
        } catch (e: Exception) {
            Log.e(TAG, "Failed to update clip index: ${e.message}", e)
        }
    }

    private fun notifyToast(text: String) {
        Handler(mainLooper).post {
            Toast.makeText(applicationContext, text, Toast.LENGTH_SHORT).show()
        }
    }

    /**
     * Ends the one-shot session on the main thread after a capture attempt
     * (success or failure) so MediaProjection/notification teardown and the
     * overlay hide happen off the background capture thread.
     */
    private fun endSessionAfterCapture() {
        Handler(mainLooper).post { stopSession() }
    }

    private fun saveBitmap(bitmap: Bitmap): String? {
        return try {
            val dir = File(getExternalFilesDir(Environment.DIRECTORY_PICTURES), "apex_captures")
            if (!dir.mkdirs() && !dir.exists()) {
                Log.e(TAG, "Failed to create directory: $dir")
                return null
            }
            val timestamp = System.currentTimeMillis()
            val file = File(dir, "apex_cap_$timestamp.png")
            FileOutputStream(file).use { out ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
            }
            registerCapture(dir, file.absolutePath, timestamp)
            file.absolutePath
        } catch (e: IOException) {
            Log.e(TAG, "IOException saving bitmap: ${e.message}", e)
            null
        } catch (e: Exception) {
            Log.e(TAG, "Error saving bitmap: ${e.message}", e)
            null
        }
    }

    /**
     * Appends the capture to apex_captures/index.json so Flutter (Apex Studio)
     * can list previously captured screenshots without a MethodChannel round-trip.
     * Best-effort: an index failure must not affect the capture itself, which is
     * already saved on disk by the time this runs.
     */
    private fun registerCapture(dir: File, filePath: String, timestamp: Long) {
        try {
            val indexFile = File(dir, "index.json")
            val entries = if (indexFile.exists()) {
                JSONArray(indexFile.readText())
            } else {
                JSONArray()
            }
            entries.put(JSONObject().apply {
                put("path", filePath)
                put("timestamp", timestamp)
            })
            val trimmed = if (entries.length() > MAX_INDEX_ENTRIES) {
                JSONArray(
                    (entries.length() - MAX_INDEX_ENTRIES until entries.length())
                        .map { entries.get(it) },
                )
            } else {
                entries
            }
            indexFile.writeText(trimmed.toString())
        } catch (e: Exception) {
            Log.e(TAG, "Failed to update capture index: ${e.message}", e)
        }
    }

    /**
     * Ends the armed session and releases all MediaProjection resources.
     * Idempotent — safe to call from onStop(), an abort path, or MainActivity.
     */
    fun stopSession() {
        if (stopped) return
        stopped = true
        armed = false

        if (recording) {
            // Abnormal teardown mid-recording (revoked consent, task killed,
            // disarm from the app) — always discard rather than risk handing
            // out a truncated .mp4 as if it were a valid clip.
            stopVideoRecording(discard = true)
        }

        imageReader?.setOnImageAvailableListener(null, null)
        virtualDisplay?.release()
        mediaProjection?.stop()
        virtualDisplay = null
        mediaProjection = null
        imageReader = null

        captureThread?.quitSafely()
        captureThread = null
        backgroundHandler = null

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }

        // Session ended (captured or explicitly disarmed) — the A+ button must
        // go with it so the app's toggle and the on-screen state stay in sync;
        // a new session requires re-enabling from the app (new consent).
        FloatingOverlayManager.getInstance(applicationContext).hide()

        Log.d(TAG, "session ended")
        stopSelf()
    }

    override fun onDestroy() {
        stopSession()
        if (instance === this) instance = null
        super.onDestroy()
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        // App task swiped away mid-recording — this service is not sticky, so
        // onDestroy is not guaranteed to fire promptly; tear down explicitly
        // to finalize (or discard) the MediaRecorder/MediaMuxer safely.
        stopSession()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Apex Capture",
                NotificationManager.IMPORTANCE_LOW,
            )
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }
}
