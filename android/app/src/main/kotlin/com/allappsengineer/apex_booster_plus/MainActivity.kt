package com.allappsengineer.apex_booster_plus

import android.content.pm.ApplicationInfo
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.allappsengineer.apex_booster_plus/apps"
        ).setMethodCallHandler { call, result ->
            if (call.method == "getInstalledApps") {
                try {
                    val pm = packageManager
                    val selfPkg = packageName
                    val apps = pm.getInstalledApplications(0)
                        .filter { info ->
                            val isSystem = (info.flags and ApplicationInfo.FLAG_SYSTEM) != 0
                            val hasLauncher =
                                pm.getLaunchIntentForPackage(info.packageName) != null
                            !isSystem && hasLauncher && info.packageName != selfPkg
                        }
                        .map { info ->
                            mapOf(
                                "appName" to pm.getApplicationLabel(info).toString(),
                                "packageName" to info.packageName,
                            )
                        }
                        .sortedBy { it["appName"] as String }
                    result.success(apps)
                } catch (e: Exception) {
                    result.error("GET_APPS_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
