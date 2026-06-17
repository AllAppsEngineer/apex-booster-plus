package com.allappsengineer.apex_booster_plus

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.TextView
import kotlin.math.abs

internal class FloatingOverlayManager private constructor(private val context: Context) {

    companion object {
        private const val TAG = "FloatingOverlay"

        @Volatile
        private var instance: FloatingOverlayManager? = null

        fun getInstance(context: Context): FloatingOverlayManager =
            instance ?: synchronized(this) {
                instance ?: FloatingOverlayManager(context.applicationContext).also { instance = it }
            }
    }

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null

    // Set by MainActivity when Activity is resumed; cleared on pause.
    // When non-null, the tap is delivered directly to Flutter (foreground path).
    // When null, the tap falls back to an Intent (background path).
    private var dartCallback: (() -> Unit)? = null

    fun setDartCallback(cb: (() -> Unit)?) {
        dartCallback = cb
    }

    fun isPermissionGranted(): Boolean = Settings.canDrawOverlays(context)

    fun show(): Boolean {
        if (!isPermissionGranted()) {
            Log.d(TAG, "show requested — permission not granted")
            return false
        }
        if (overlayView != null) {
            Log.d(TAG, "show requested — already showing")
            return true
        }
        // Defensive: ensure no stale state before adding a new view
        hide()

        Log.d(TAG, "show requested — adding view")
        val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        windowManager = wm

        val density = context.resources.displayMetrics.density
        val sizePx = (52 * density).toInt()
        val container = buildButtonView(density, sizePx)

        @Suppress("DEPRECATION")
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else
            WindowManager.LayoutParams.TYPE_PHONE

        val params = WindowManager.LayoutParams(
            sizePx, sizePx, type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = (16 * density).toInt()
            y = (200 * density).toInt()
        }

        container.setOnTouchListener(
            DragTouchListener(wm, params, container) { bringAppToForeground() },
        )

        wm.addView(container, params)
        overlayView = container
        Log.d(TAG, "show — view added")
        return true
    }

    fun hide() {
        val v = overlayView ?: run {
            Log.d(TAG, "hide requested — nothing to remove")
            return
        }
        Log.d(TAG, "hide requested — removing view")
        runCatching { windowManager?.removeView(v) }
        overlayView = null
        windowManager = null
        Log.d(TAG, "hide — removed")
    }

    fun isShowing(): Boolean = overlayView != null

    // ─── Private helpers ─────────────────────────────────────────────────────────

    private fun bringAppToForeground() {
        Log.d(TAG, "bring foreground requested")
        val cb = dartCallback
        if (cb != null) {
            // Activity is in foreground and Flutter engine is ready: deliver directly.
            Log.d(TAG, "native dart callback sent directly")
            cb.invoke()
        } else {
            // Activity is in background: bring to front via Intent.
            // onResume() will deliver the pending tap once Flutter is ready.
            Log.d(TAG, "native dart callback queued via intent")
            val intent = Intent(context, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                setPackage(context.packageName)
                putExtra("apex_overlay_tap", true)
            }
            context.startActivity(intent)
        }
    }

    private fun buildButtonView(density: Float, sizePx: Int): FrameLayout {
        val strokePx = (1.5f * density).toInt()

        val container = FrameLayout(context).apply {
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#E6050505"))
                setStroke(strokePx, Color.parseColor("#5522C55E"))
            }
        }

        val label = TextView(context).apply {
            text = "A+"
            textSize = 13f
            setTextColor(Color.parseColor("#22C55E"))
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            )
        }
        container.addView(label)
        return container
    }

    // ─── Drag + tap distinguisher ─────────────────────────────────────────────

    private class DragTouchListener(
        private val wm: WindowManager,
        private val params: WindowManager.LayoutParams,
        private val view: View,
        private val onClick: () -> Unit,
    ) : View.OnTouchListener {

        private var startRawX = 0f
        private var startRawY = 0f
        private var startParamsX = 0
        private var startParamsY = 0
        private var moved = false

        override fun onTouch(v: View, e: MotionEvent): Boolean {
            when (e.action) {
                MotionEvent.ACTION_DOWN -> {
                    startRawX = e.rawX
                    startRawY = e.rawY
                    startParamsX = params.x
                    startParamsY = params.y
                    moved = false
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = e.rawX - startRawX
                    val dy = e.rawY - startRawY
                    if (!moved && (abs(dx) > 8f || abs(dy) > 8f)) moved = true
                    if (moved) {
                        params.x = (startParamsX + dx).toInt()
                        params.y = (startParamsY + dy).toInt()
                        wm.updateViewLayout(view, params)
                    }
                }
                MotionEvent.ACTION_UP -> if (!moved) {
                    Log.d(TAG, "tap detected")
                    onClick()
                }
            }
            return true
        }
    }
}
