package com.allappsengineer.apex_booster_plus

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
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

    // Native mini-menu shown on A+ tap (Capturar tela / Gravar vídeo / Fechar).
    // Anchored to buttonParams, which is the same LayoutParams instance used by
    // the button — DragTouchListener mutates it in place, so the menu always
    // re-reads the button's current position when opened.
    private var menuView: View? = null
    private var buttonParams: WindowManager.LayoutParams? = null

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
        buttonParams = params

        container.setOnTouchListener(
            DragTouchListener(wm, params, container) { toggleMiniMenu() },
        )

        wm.addView(container, params)
        overlayView = container
        Log.d(TAG, "show — view added")
        return true
    }

    fun hide() {
        hideMiniMenu()
        val v = overlayView ?: run {
            Log.d(TAG, "hide requested — nothing to remove")
            return
        }
        Log.d(TAG, "hide requested — removing view")
        runCatching { windowManager?.removeView(v) }
        overlayView = null
        windowManager = null
        buttonParams = null
        Log.d(TAG, "hide — removed")
    }

    fun isShowing(): Boolean = overlayView != null

    // ─── Private helpers ─────────────────────────────────────────────────────────

    // ─── Mini-menu nativo (Capturar tela / Gravar vídeo / Fechar) ─────────────

    private fun toggleMiniMenu() {
        if (menuView != null) hideMiniMenu() else showMiniMenu()
    }

    private fun showMiniMenu() {
        val wm = windowManager ?: return
        val anchor = buttonParams ?: return
        hideMiniMenu()

        val density = context.resources.displayMetrics.density
        val sizePx = (52 * density).toInt()
        val menu = buildMenuView(density)

        @Suppress("DEPRECATION")
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else
            WindowManager.LayoutParams.TYPE_PHONE

        val menuParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = anchor.x + sizePx + (8 * density).toInt()
            y = anchor.y
        }

        wm.addView(menu, menuParams)
        menuView = menu
        Log.d(TAG, "mini-menu shown")
    }

    private fun hideMiniMenu() {
        val v = menuView ?: return
        runCatching { windowManager?.removeView(v) }
        menuView = null
    }

    private fun buildMenuView(density: Float): View {
        val container = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            background = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = 10f * density
                setColor(Color.parseColor("#F0050505"))
                setStroke((1.5f * density).toInt(), Color.parseColor("#5522C55E"))
            }
            val pad = (6 * density).toInt()
            setPadding(pad, pad, pad, pad)
        }

        // SOCIAL-U7A (Opção B): a sessão armada é print XOR vídeo — o
        // mini-menu mostra só a ação compatível com o modo ativo, nunca as
        // duas juntas (cada MediaProjection só sustenta um VirtualDisplay).
        val mode = ScreenCaptureService.instance?.getMode()
        if (mode == ScreenCaptureService.MODE_VIDEO) {
            container.addView(
                buildMenuItem(density, "Gravar vídeo", Color.parseColor("#3B82F6"), enabled = true) {
                    // Same hide-before-act pattern as "Capturar tela" so the A+
                    // button/menu never appear inside the recorded clip.
                    hide()
                    Handler(context.mainLooper).postDelayed({
                        ScreenCaptureService.instance?.startVideoRecording()
                    }, 400)
                },
            )
        } else {
            container.addView(
                buildMenuItem(density, "Capturar tela", Color.parseColor("#22C55E"), enabled = true) {
                    // Reusa a MediaProjection já concedida pelo Modo Captura da Sessão —
                    // não abre novo diálogo de consentimento nem traz o Apex para frente.
                    // Esconde o overlay (botão A+ e mini-menu) ANTES de capturar para que
                    // eles não apareçam no frame salvo; aguarda o WindowManager assentar.
                    hide()
                    Handler(context.mainLooper).postDelayed({
                        ScreenCaptureService.instance?.captureNow()
                    }, 400)
                },
            )
        }
        container.addView(
            buildMenuItem(density, "Fechar", Color.parseColor("#A1A1AA"), enabled = true) {
                hideMiniMenu()
            },
        )

        return container
    }

    private fun buildMenuItem(
        density: Float,
        label: String,
        textColor: Int,
        enabled: Boolean,
        onClick: (() -> Unit)? = null,
    ): View {
        return TextView(context).apply {
            text = label
            textSize = 13f
            setTextColor(textColor)
            val hPad = (14 * density).toInt()
            val vPad = (10 * density).toInt()
            setPadding(hPad, vPad, hPad, vPad)
            if (enabled && onClick != null) {
                isClickable = true
                setOnClickListener { onClick() }
            } else {
                isClickable = false
            }
        }
    }

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
