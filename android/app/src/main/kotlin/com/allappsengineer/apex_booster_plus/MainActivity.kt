package com.allappsengineer.apex_booster_plus

import android.app.Activity
import android.app.ActivityManager
import android.app.NotificationManager
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.BitmapDrawable
import android.media.projection.MediaProjectionManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.activity.result.ActivityResult
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterFragmentActivity() {
    private val overlayManager get() = FloatingOverlayManager.getInstance(applicationContext)
    private var _previousFilter: Int? = null
    private var _focusModeActivatedByApp: Boolean = false
    private var overlayChannel: MethodChannel? = null
    private var _pendingOverlayTap = false

    // Holds the pending Flutter result while waiting for MediaProjection consent.
    private var pendingCaptureResult: MethodChannel.Result? = null

    // Mode requested via armSession — screenshot or video — carried across
    // the consent round-trip so captureResultLauncher's callback can forward
    // it to ScreenCaptureService. Defaults to screenshot for safety.
    private var pendingSessionMode: String = ScreenCaptureService.MODE_SCREENSHOT

    // Activity Result launcher for MediaProjection consent dialog.
    private lateinit var captureResultLauncher: ActivityResultLauncher<Intent>

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        captureResultLauncher = registerForActivityResult(
            ActivityResultContracts.StartActivityForResult()
        ) { result: ActivityResult ->
            if (result.resultCode == Activity.RESULT_OK && result.data != null) {
                // Arm the session service — it stays idle/armed until captureNow() is
                // triggered later from the native A+ mini-menu. No capture happens
                // here, no overlay is hidden, no task is moved to background.
                val serviceIntent = Intent(this, ScreenCaptureService::class.java).apply {
                    putExtra(ScreenCaptureService.EXTRA_RESULT_CODE, result.resultCode)
                    putExtra(ScreenCaptureService.EXTRA_RESULT_DATA, result.data)
                    putExtra(ScreenCaptureService.EXTRA_SESSION_MODE, pendingSessionMode)
                }
                startForegroundService(serviceIntent)
                pendingCaptureResult?.success(true)
                pendingCaptureResult = null
            } else {
                // User denied or cancelled — clean shutdown, no retry.
                pendingCaptureResult?.success(false)
                pendingCaptureResult = null
            }
        }
    }

    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.getBooleanExtra("apex_overlay_tap", false)) {
            android.util.Log.d("OverlayTap", "native tap via intent received")
            // Defer delivery to onResume() — Flutter may not be resumed yet.
            _pendingOverlayTap = true
        }
    }

    override fun onResume() {
        super.onResume()
        // Register direct callback so foreground taps bypass the Intent path.
        overlayManager.setDartCallback {
            android.util.Log.d("OverlayTap", "native dart callback sent")
            overlayChannel?.invokeMethod("onOverlayTapped", null)
        }
        // Deliver any tap that arrived via Intent while Flutter was not ready.
        deliverPendingOverlayTap()
    }

    override fun onPause() {
        super.onPause()
        // Clear callback so the next tap falls back to the Intent path.
        overlayManager.setDartCallback(null)
    }

    private fun deliverPendingOverlayTap() {
        if (!_pendingOverlayTap) return
        _pendingOverlayTap = false
        android.util.Log.d("OverlayTap", "native dart callback sent (deferred)")
        overlayChannel?.invokeMethod("onOverlayTapped", null)
    }

    override fun onDestroy() {
        super.onDestroy()
        if (isFinishing) overlayManager.hide()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.allappsengineer.apex_booster_plus/apps"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    try {
                        val pm = packageManager
                        val selfPkg = packageName
                        val apps = pm.getInstalledApplications(0)
                            .filter { info ->
                                val isSystem =
                                    (info.flags and ApplicationInfo.FLAG_SYSTEM) != 0
                                val hasLauncher =
                                    pm.getLaunchIntentForPackage(info.packageName) != null
                                !isSystem && hasLauncher && info.packageName != selfPkg
                            }
                            .map { info ->
                                @Suppress("DEPRECATION")
                                val isGame = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                    info.category == ApplicationInfo.CATEGORY_GAME
                                } else {
                                    (info.flags and ApplicationInfo.FLAG_IS_GAME) != 0
                                }
                                mapOf(
                                    "appName" to pm.getApplicationLabel(info).toString(),
                                    "packageName" to info.packageName,
                                    "isGame" to isGame,
                                )
                            }
                            .sortedBy { it["appName"] as String }
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("GET_APPS_ERROR", e.message, null)
                    }
                }

                "getAppIcon" -> {
                    val pkg = call.argument<String>("packageName")
                    if (pkg.isNullOrEmpty()) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    try {
                        val drawable = packageManager.getApplicationIcon(pkg)
                        val bitmap: Bitmap = when {
                            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                                    drawable is AdaptiveIconDrawable -> {
                                val size = 108
                                val bmp = Bitmap.createBitmap(
                                    size, size, Bitmap.Config.ARGB_8888
                                )
                                val canvas = Canvas(bmp)
                                drawable.setBounds(0, 0, size, size)
                                drawable.draw(canvas)
                                bmp
                            }
                            drawable is BitmapDrawable -> drawable.bitmap
                            else -> {
                                val w = drawable.intrinsicWidth.coerceAtLeast(1)
                                val h = drawable.intrinsicHeight.coerceAtLeast(1)
                                val bmp = Bitmap.createBitmap(
                                    w, h, Bitmap.Config.ARGB_8888
                                )
                                val canvas = Canvas(bmp)
                                drawable.setBounds(0, 0, w, h)
                                drawable.draw(canvas)
                                bmp
                            }
                        }
                        val stream = ByteArrayOutputStream()
                        bitmap.compress(Bitmap.CompressFormat.PNG, 85, stream)
                        result.success(stream.toByteArray())
                    } catch (e: PackageManager.NameNotFoundException) {
                        result.success(null)
                    } catch (e: Exception) {
                        result.success(null)
                    }
                }

                "openUrl" -> {
                    val url = call.argument<String>("url")
                    val uri = url?.let { Uri.parse(it) }
                    if (url.isNullOrEmpty() || uri?.scheme != "https") {
                        result.error("INVALID_URL", "url must be a non-empty https URL", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val intent = Intent(Intent.ACTION_VIEW, uri)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(null)
                    } catch (e: ActivityNotFoundException) {
                        result.error("ACTIVITY_NOT_FOUND", "No app can open this URL", null)
                    } catch (e: Exception) {
                        result.error("OPEN_URL_ERROR", e.message, null)
                    }
                }

                "launchApp" -> {
                    val pkg = call.argument<String>("packageName")
                    if (pkg.isNullOrEmpty()) {
                        result.error("INVALID_PACKAGE", "packageName is required", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val intent = packageManager.getLaunchIntentForPackage(pkg)
                        if (intent == null) {
                            result.error("APP_NOT_FOUND", "No launcher intent for $pkg", null)
                        } else {
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                            result.success(null)
                        }
                    } catch (e: Exception) {
                        result.error("LAUNCH_ERROR", e.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.allappsengineer.apex_booster_plus/metrics"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getMemoryInfo" -> {
                    try {
                        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                        val memInfo = ActivityManager.MemoryInfo()
                        am.getMemoryInfo(memInfo)
                        result.success(
                            mapOf(
                                "availableBytes" to memInfo.availMem,
                                "totalBytes" to memInfo.totalMem,
                                "lowMemory" to memInfo.lowMemory,
                                "thresholdBytes" to memInfo.threshold,
                            )
                        )
                    } catch (e: Exception) {
                        result.error("MEMORY_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.allappsengineer.apex_booster_plus/focus_mode"
        ).setMethodCallHandler { call, result ->
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            when (call.method) {
                "isPermissionGranted" -> {
                    result.success(nm.isNotificationPolicyAccessGranted)
                }

                "openSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.success(null)
                    }
                }

                "saveAndEnable" -> {
                    if (!nm.isNotificationPolicyAccessGranted) {
                        result.error("NO_PERMISSION", "ACCESS_NOTIFICATION_POLICY not granted", null)
                        return@setMethodCallHandler
                    }
                    try {
                        _previousFilter = nm.currentInterruptionFilter
                        _focusModeActivatedByApp = true
                        nm.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALARMS)
                        result.success(null)
                    } catch (e: SecurityException) {
                        _focusModeActivatedByApp = false
                        _previousFilter = null
                        result.error("SET_FILTER_ERROR", e.message, null)
                    } catch (e: Exception) {
                        _focusModeActivatedByApp = false
                        _previousFilter = null
                        result.error("SET_FILTER_ERROR", e.message, null)
                    }
                }

                "restore" -> {
                    if (!_focusModeActivatedByApp) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    try {
                        if (nm.isNotificationPolicyAccessGranted) {
                            val target = _previousFilter ?: NotificationManager.INTERRUPTION_FILTER_ALL
                            nm.setInterruptionFilter(target)
                        }
                    } catch (e: Exception) {
                        // silent — no-op on failure
                    } finally {
                        _focusModeActivatedByApp = false
                        _previousFilter = null
                        result.success(null)
                    }
                }

                else -> result.notImplemented()
            }
        }

        val apexOverlayCh = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "apex/overlay"
        )
        overlayChannel = apexOverlayCh
        apexOverlayCh.setMethodCallHandler { call, result ->
            when (call.method) {
                "bringToForeground" -> {
                    try {
                        val intent = Intent(this, MainActivity::class.java)
                        intent.addFlags(
                            Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                            Intent.FLAG_ACTIVITY_NEW_TASK
                        )
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.success(null)
                    }
                }
                "isOverlayPermissionGranted" -> {
                    result.success(overlayManager.isPermissionGranted())
                }
                "openOverlayPermissionSettings" -> {
                    try {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            android.net.Uri.parse("package:$packageName")
                        )
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.success(null)
                    }
                }
                "showFloating" -> {
                    result.success(overlayManager.show())
                }
                "hideFloating" -> {
                    overlayManager.hide()
                    result.success(null)
                }
                "isFloatingShowing" -> {
                    result.success(overlayManager.isShowing())
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "apex/capture"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "armSession" -> {
                    if (pendingCaptureResult != null) {
                        result.error("CAPTURE_IN_PROGRESS", "A capture consent request is already in progress", null)
                        return@setMethodCallHandler
                    }
                    if (ScreenCaptureService.instance != null) {
                        // Already armed from a previous call — no need to re-prompt.
                        result.success(true)
                        return@setMethodCallHandler
                    }
                    pendingSessionMode = (call.argument<String>("mode"))
                        ?.takeIf { it == ScreenCaptureService.MODE_VIDEO }
                        ?: ScreenCaptureService.MODE_SCREENSHOT
                    pendingCaptureResult = result
                    // Resolved in captureResultLauncher once consent is granted or denied.
                    val mpm = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
                    captureResultLauncher.launch(mpm.createScreenCaptureIntent())
                }
                "disarmSession" -> {
                    ScreenCaptureService.instance?.stopSession()
                    result.success(null)
                }
                "isSessionArmed" -> {
                    result.success(ScreenCaptureService.instance != null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
