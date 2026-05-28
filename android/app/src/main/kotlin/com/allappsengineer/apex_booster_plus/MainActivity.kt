package com.allappsengineer.apex_booster_plus

import android.app.ActivityManager
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.BitmapDrawable
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private var _previousFilter: Int? = null
    private var _focusModeActivatedByApp: Boolean = false

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
    }
}
