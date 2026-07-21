package com.allappsengineer.apex_booster_plus

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.MediaExtractor
import android.media.MediaMetadataRetriever
import android.net.Uri
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.common.util.Size
import androidx.media3.common.util.UnstableApi
import androidx.media3.effect.BitmapOverlay
import androidx.media3.effect.MatrixTransformation
import androidx.media3.effect.OverlayEffect
import androidx.media3.effect.Presentation
import androidx.media3.transformer.Composition
import androidx.media3.transformer.EditedMediaItem
import androidx.media3.transformer.EditedMediaItemSequence
import androidx.media3.transformer.Effects
import androidx.media3.transformer.ExportException
import androidx.media3.transformer.ExportResult
import androidx.media3.transformer.Transformer
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

/**
 * STUDIO-U3-THREE-LAYER-RENDER: composes a final branded MP4 from a source
 * video + two chrome PNGs produced by the Dart side (see
 * share_studio_screen.dart's hidden export captures):
 *
 * - [backgroundPath]: fully opaque outside the media slot — border,
 *   gradient, grid, glow. No text/badge/watermark baked in.
 * - [overlayPath]: the foreground — header, title, caption, badge,
 *   watermark, decorative elements. Also opaque outside the slot,
 *   transparent only inside it.
 *
 * Both PNGs are decoded as plain [Bitmap]s and applied via
 * [OverlayEffect]/[BitmapOverlay], in that order (background composited
 * first, foreground drawn on top last) — never as a second
 * [EditedMediaItemSequence]. An earlier version fed a PNG through a second
 * sequence, which Media3's `DefaultAssetLoaderFactory` routed to
 * `ExoPlayerAssetLoader` instead of `ImageAssetLoader` (no explicit image
 * MIME type / frame rate signaled), crashing with
 * "Unsupported track type: 4" (`C.TRACK_TYPE_IMAGE`).
 *
 * The video itself is only ever drawn inside the media slot: it's
 * cropped/scaled to the slot's own size via [Presentation], then placed at
 * the slot's exact offset inside the full canvas via
 * [SlotPlacementTransformation] (a custom [MatrixTransformation] —
 * [Presentation] alone only grows/centers a frame, it can't place one
 * off-center). Everything outside the slot rect is then fully covered by
 * the opaque background/foreground overlays, so the video can never look
 * like it "is" the canvas.
 */
@UnstableApi
class VideoCardExporter(private val context: Context) {

    companion object {
        const val MAX_DURATION_MS = 90_000L
        private const val TAG = "VideoCardExporter"
    }

    @Volatile
    private var activeTransformer: Transformer? = null

    fun cancel() {
        activeTransformer?.cancel()
        activeTransformer = null
    }

    fun compose(
        videoPath: String,
        overlayPath: String,
        backgroundPath: String,
        outputPath: String,
        slotX: Int,
        slotY: Int,
        slotW: Int,
        slotH: Int,
        canvasW: Int,
        canvasH: Int,
        fitMode: String,
        result: MethodChannel.Result,
    ) {
        val durationMs = probeDurationMs(videoPath)
        if (durationMs == null) {
            result.error("PROBE_FAILED", "Could not read source video duration", null)
            return
        }
        if (durationMs > MAX_DURATION_MS) {
            result.error(
                "VIDEO_TOO_LONG",
                "Video duration ${durationMs}ms exceeds cap of ${MAX_DURATION_MS}ms",
                null,
            )
            return
        }

        val (inputHasVideo, inputHasAudio) = probeTracks(videoPath)

        // STUDIO-U3-THREE-LAYER-RENDER condition: don't trust the Dart-side
        // (video_player) orientation guess alone — cross-check the input's
        // real, rotation-corrected dimensions via MediaMetadataRetriever, an
        // independent and reliable source read directly from the container.
        val (inputW, inputH, inputOrientation) = probeVideoOrientation(videoPath)
        val slotOrientation = when {
            slotW > slotH -> "landscape"
            slotW < slotH -> "portrait"
            else -> "square"
        }
        android.util.Log.i(
            TAG,
            "action=generate_video_card inputPath=$videoPath outputPath=$outputPath " +
                "outputPath!=inputPath=${outputPath != videoPath} " +
                "backgroundPath=$backgroundPath foregroundPath=$overlayPath " +
                "slotRect=($slotX,$slotY,$slotW,$slotH) fitMode=$fitMode " +
                "finalFormat=${canvasW}x$canvasH " +
                "input width=$inputW height=$inputH duration=${durationMs}ms " +
                "hasVideo=$inputHasVideo hasAudio=$inputHasAudio " +
                "inputOrientation=$inputOrientation slotOrientation=$slotOrientation",
        )
        if (inputW != null && inputH != null && inputOrientation != slotOrientation && slotOrientation != "square") {
            android.util.Log.w(
                TAG,
                "orientation mismatch: MediaMetadataRetriever says input is " +
                    "$inputOrientation (${inputW}x$inputH) but the Dart-measured slot is " +
                    "$slotOrientation ($slotW x $slotH) — Presentation's cover/contain crop " +
                    "still won't deform the frame, but the adaptive slot may not be the best fit",
            )
        }

        val backgroundBitmap = BitmapFactory.decodeFile(backgroundPath)
        if (backgroundBitmap == null) {
            result.error("BACKGROUND_DECODE_FAILED", "Could not decode background PNG: $backgroundPath", null)
            return
        }
        logAndDumpLayer(backgroundBitmap, "backgroundBitmap", "apex_video_card_background_debug.png")

        val chromeBitmap = BitmapFactory.decodeFile(overlayPath)
        if (chromeBitmap == null) {
            result.error("OVERLAY_DECODE_FAILED", "Could not decode chrome overlay PNG: $overlayPath", null)
            return
        }
        logAndDumpLayer(chromeBitmap, "chromeBitmap", "apex_video_card_foreground_debug.png")

        // Pure letterbox contain (LAYOUT_SCALE_TO_FIT) fits the WHOLE input
        // frame inside the slot box, so when the input's orientation is the
        // opposite of the slot's (e.g. a portrait capture placed in a
        // horizontal/landscape slot), the shared-limiting dimension is tiny:
        // a 1080x2400 portrait clip into a 1343x684 landscape slot scales by
        // min(1343/1080, 684/2400) = 684/2400, leaving a ~308x684 sliver
        // pillarboxed dead-center — exactly the "tiny/verticalized" video
        // reported after visual QA. When orientations mismatch, fall back to
        // LAYOUT_SCALE_TO_FIT_WITH_CROP instead: it scales by the LARGER
        // ratio, so the slot's dominant axis (width, for a horizontal slot)
        // is always filled and only the opposite axis is cropped — matching
        // "Template Horizontal = slot horizontal" regardless of input
        // orientation. Matching orientations keep plain contain (letterbox),
        // since aspect ratios are then close enough that no sliver forms.
        val orientationMismatch = slotOrientation != "square" &&
            inputOrientation != "unknown" &&
            inputOrientation != "square" &&
            inputOrientation != slotOrientation
        val layoutMode = if (fitMode == "contain" && !orientationMismatch) {
            Presentation.LAYOUT_SCALE_TO_FIT
        } else {
            Presentation.LAYOUT_SCALE_TO_FIT_WITH_CROP
        }
        android.util.Log.i(
            TAG,
            "fit decision: fitMode=$fitMode inputOrientation=$inputOrientation " +
                "slotOrientation=$slotOrientation orientationMismatch=$orientationMismatch " +
                "resolvedLayoutMode=" +
                if (layoutMode == Presentation.LAYOUT_SCALE_TO_FIT) "SCALE_TO_FIT" else "SCALE_TO_FIT_WITH_CROP",
        )

        val videoItem = EditedMediaItem.Builder(MediaItem.fromUri(Uri.fromFile(File(videoPath))))
            .setEffects(
                Effects(
                    emptyList(),
                    listOf(
                        Presentation.createForWidthAndHeight(slotW, slotH, layoutMode),
                        SlotPlacementTransformation(canvasW, canvasH, slotX, slotY, slotW, slotH),
                        // Background composited first (drawn first), foreground last
                        // (drawn on top) — list order is draw order in OverlayEffect,
                        // confirmed via javap: OverlayEffect(List<TextureOverlay>).
                        OverlayEffect(
                            listOf(
                                BitmapOverlay.createStaticBitmapOverlay(backgroundBitmap),
                                BitmapOverlay.createStaticBitmapOverlay(chromeBitmap),
                            ),
                        ),
                    ),
                ),
            )
            .build()
        val videoSequence = EditedMediaItemSequence.Builder(listOf(videoItem)).build()
        val composition = Composition.Builder(videoSequence).build()

        val transformer = Transformer.Builder(context)
            .setVideoMimeType(MimeTypes.VIDEO_H264)
            .addListener(
                object : Transformer.Listener {
                    override fun onCompleted(composition: Composition, exportResult: ExportResult) {
                        activeTransformer = null
                        android.util.Log.i(TAG, "Media3 compose succeeded")
                        val validation = validateOutput(outputPath, canvasW, canvasH)
                        if (validation != null) {
                            result.error("OUTPUT_INVALID", validation, null)
                            return
                        }
                        val debugFramePath = extractDebugFrame(outputPath)
                        android.util.Log.i(TAG, "output visual proof frame saved=$debugFramePath")
                        result.success(
                            mapOf(
                                "outputPath" to outputPath,
                                "debugFramePath" to debugFramePath,
                            ),
                        )
                    }

                    override fun onError(
                        composition: Composition,
                        exportResult: ExportResult,
                        exportException: ExportException,
                    ) {
                        activeTransformer = null
                        android.util.Log.e(
                            TAG,
                            "Media3 compose error: ${exportException.message}",
                            exportException,
                        )
                        result.error(
                            "COMPOSE_ERROR",
                            "${exportException.message}\n${android.util.Log.getStackTraceString(exportException)}",
                            null,
                        )
                    }
                },
            )
            .build()

        activeTransformer = transformer
        android.util.Log.i(TAG, "Media3 compose started")
        transformer.start(composition, outputPath)
    }

    /**
     * Logs decode metadata (dimensions/config/alpha) and saves a debug PNG
     * copy of a layer bitmap exactly as Kotlin decoded it — before Media3
     * ever touches it. Shared by both the background and foreground layers
     * so a visual regression in either can be isolated to before/after
     * compose independently.
     */
    private fun logAndDumpLayer(bitmap: Bitmap, label: String, debugFileName: String) {
        val cornerPixel = bitmap.getPixel(24, 24)
        android.util.Log.i(
            TAG,
            "$label decoded: ${bitmap.width}x${bitmap.height} " +
                "config=${bitmap.config} hasAlpha=${bitmap.hasAlpha()} " +
                "isPremultiplied=${bitmap.isPremultiplied} " +
                "cornerPixelARGB=${Integer.toHexString(cornerPixel)}",
        )
        val debugFile = File(context.cacheDir, debugFileName)
        try {
            FileOutputStream(debugFile).use { out ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
            }
            android.util.Log.i(TAG, "$label debug dump saved=${debugFile.absolutePath}")
        } catch (e: Exception) {
            android.util.Log.e(TAG, "$label debug dump failed: ${e.message}", e)
        }
    }

    /**
     * Confirms the muxed MP4 is a real, playable file before it's handed back
     * to Dart for sharing — never trust `onCompleted` alone. Returns `null` on
     * success, or a human-readable error message identifying which check
     * failed.
     */
    private fun validateOutput(outputPath: String, expectedW: Int, expectedH: Int): String? {
        val file = File(outputPath)
        if (!file.exists() || file.length() <= 0L) {
            val message = "output file missing or empty: exists=${file.exists()} size=${file.length()}"
            android.util.Log.e(TAG, message)
            return message
        }

        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(outputPath)
            val durationMs = retriever
                .extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                ?.toLongOrNull()
            val width = retriever
                .extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)
                ?.toIntOrNull()
            val height = retriever
                .extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)
                ?.toIntOrNull()
            val (hasVideo, hasAudio) = probeTracks(outputPath)
            android.util.Log.i(
                TAG,
                "output file exists=true size=${file.length()} duration=${durationMs}ms " +
                    "dimensions=${width}x$height (expected ${expectedW}x$expectedH) " +
                    "hasVideo=$hasVideo hasAudio=$hasAudio",
            )
            if (durationMs == null || durationMs <= 0L) {
                "output has no playable duration: $durationMs"
            } else if (width == null || height == null) {
                "output has no readable video dimensions"
            } else {
                null
            }
        } catch (e: Exception) {
            val message = "output metadata read failed: ${e.message}"
            android.util.Log.e(TAG, message, e)
            message
        } finally {
            retriever.release()
        }
    }

    /**
     * Places the already slot-cropped frame (see [Presentation.createForWidthAndHeight]
     * applied beforehand, sized to [slotW]x[slotH]) at the exact slot offset inside a
     * grown [canvasW]x[canvasH] frame. [Presentation] alone can't do this — it only
     * centers a frame within a bigger or smaller one — so this reimplements the same
     * translate+scale NDC anchor math this file previously fed to a compositor-level
     * `OverlaySettings.setBackgroundFrameAnchor`, but as a per-frame vertex matrix.
     */
    private class SlotPlacementTransformation(
        private val canvasW: Int,
        private val canvasH: Int,
        private val slotX: Int,
        private val slotY: Int,
        private val slotW: Int,
        private val slotH: Int,
    ) : MatrixTransformation {

        private val matrix: Matrix by lazy {
            val scaleX = slotW.toFloat() / canvasW.toFloat()
            val scaleY = slotH.toFloat() / canvasH.toFloat()
            val ndcX = (((slotX + slotW / 2.0) / canvasW) * 2.0 - 1.0).toFloat()
            val ndcY = (1.0 - ((slotY + slotH / 2.0) / canvasH) * 2.0).toFloat()
            android.util.Log.i(
                "VideoCardExporter",
                "SlotPlacementTransformation matrix: slotRect=($slotX,$slotY,$slotW,$slotH) " +
                    "canvas=${canvasW}x$canvasH scale=($scaleX,$scaleY) ndcOffset=($ndcX,$ndcY)",
            )
            Matrix().apply {
                setScale(scaleX, scaleY)
                postTranslate(ndcX, ndcY)
            }
        }

        override fun configure(inputWidth: Int, inputHeight: Int): Size = Size(canvasW, canvasH)

        override fun getMatrix(presentationTimeUs: Long): Matrix = matrix
    }

    private fun probeDurationMs(path: String): Long? {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(path)
            retriever
                .extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                ?.toLongOrNull()
        } catch (e: Exception) {
            null
        } finally {
            retriever.release()
        }
    }

    /**
     * STUDIO-U3-THREE-LAYER-RENDER: reads the input's real, rotation-
     * corrected width/height/orientation via [MediaMetadataRetriever] —
     * an independent, reliable cross-check against the Dart-side
     * (video_player) orientation guess used to size the adaptive slot.
     * [MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH]/`HEIGHT` return the
     * container's encoded dimensions ignoring rotation, so a 90/270 rotation
     * flag means the *effective* on-screen width/height are swapped.
     */
    private fun probeVideoOrientation(path: String): Triple<Int?, Int?, String> {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(path)
            val width = retriever
                .extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)
                ?.toIntOrNull()
            val height = retriever
                .extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)
                ?.toIntOrNull()
            val rotation = retriever
                .extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)
                ?.toIntOrNull() ?: 0
            if (width == null || height == null) {
                Triple(null, null, "unknown")
            } else {
                val rotated = rotation == 90 || rotation == 270
                val effW = if (rotated) height else width
                val effH = if (rotated) width else height
                val orientation = when {
                    effW > effH -> "landscape"
                    effW < effH -> "portrait"
                    else -> "square"
                }
                Triple(effW, effH, orientation)
            }
        } catch (e: Exception) {
            android.util.Log.e(TAG, "probeVideoOrientation failed for $path: ${e.message}", e)
            Triple(null, null, "unknown")
        } finally {
            retriever.release()
        }
    }

    /**
     * Reads each container track's MIME type via [MediaExtractor] — used both
     * on the source video (diagnostic only) and on the composed output
     * (STUDIO-U3-PROOF-FIX validation), so `hasAudio=false` on an input clip
     * from Apex Capture (which records video-only, see ScreenCaptureService)
     * is never mistaken for an export bug.
     */
    private fun probeTracks(path: String): Pair<Boolean, Boolean> {
        val extractor = MediaExtractor()
        return try {
            extractor.setDataSource(path)
            var hasVideo = false
            var hasAudio = false
            for (i in 0 until extractor.trackCount) {
                val mime = extractor.getTrackFormat(i).getString(android.media.MediaFormat.KEY_MIME)
                    ?: continue
                if (mime.startsWith("video/")) hasVideo = true
                if (mime.startsWith("audio/")) hasAudio = true
            }
            hasVideo to hasAudio
        } catch (e: Exception) {
            android.util.Log.e(TAG, "probeTracks failed for $path: ${e.message}", e)
            false to false
        } finally {
            extractor.release()
        }
    }

    /**
     * STUDIO-U3-PROOF-FIX: pulls a still frame from the middle of the
     * composed MP4 so a human can visually confirm the Apex chrome/branding
     * is actually present — the file-exists/duration/dimension checks in
     * [validateOutput] alone can't prove that (a silently no-op `OverlayEffect`
     * would still pass them). Diagnostic-only: a failure here is logged, not
     * surfaced as an export error, since the MP4 itself already validated.
     */
    private fun extractDebugFrame(outputPath: String): String? {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(outputPath)
            val durationMs = retriever
                .extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                ?.toLongOrNull() ?: 0L
            val midUs = (durationMs * 1_000L) / 2L
            val frame = retriever.getFrameAtTime(midUs, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
            if (frame == null) {
                android.util.Log.e(TAG, "extractDebugFrame: getFrameAtTime returned null")
                return null
            }
            val debugFile = File(context.cacheDir, "apex_video_card_final_debug_frame.jpg")
            FileOutputStream(debugFile).use { out ->
                frame.compress(Bitmap.CompressFormat.JPEG, 90, out)
            }
            frame.recycle()
            debugFile.absolutePath
        } catch (e: Exception) {
            android.util.Log.e(TAG, "extractDebugFrame failed: ${e.message}", e)
            null
        } finally {
            retriever.release()
        }
    }
}
