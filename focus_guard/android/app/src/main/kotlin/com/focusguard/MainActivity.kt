package com.focusguard

import android.content.Intent
import android.content.pm.PackageManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.focusguard/app_blocker"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    try {
                        val pm = packageManager
                        val apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
                        val appList = apps
                            .filter { it.packageName != packageName }
                            .filter { pm.getLaunchIntentForPackage(it.packageName) != null }
                            .map { appInfo ->
                                mapOf(
                                    "packageName" to appInfo.packageName,
                                    "appName" to pm.getApplicationLabel(appInfo).toString()
                                )
                            }
                            .sortedBy { it["appName"] }
                        result.success(appList)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "startBlocking" -> {
                    try {
                        val packages = call.argument<List<String>>("packages") ?: emptyList()
                        val duration = call.argument<Int>("durationMinutes") ?: 25
                        AppBlockerAccessibilityService.setBlockedApps(packages)
                        AppBlockerAccessibilityService.setBlockEndTime(
                            System.currentTimeMillis() + duration * 60 * 1000L
                        )
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "stopBlocking" -> {
                    AppBlockerAccessibilityService.setBlockedApps(emptyList())
                    result.success(true)
                }
                "openAccessibilitySettings" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(true)
                }
                "openUsageAccessSettings" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
