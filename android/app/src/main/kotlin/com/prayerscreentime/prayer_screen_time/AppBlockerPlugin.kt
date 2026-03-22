package com.prayerscreentime.prayer_screen_time

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AppBlockerPlugin private constructor(
    private val context: Context,
    private val activity: Activity
) : MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "com.prayerscreentime.appblocker"

        fun registerWith(flutterEngine: FlutterEngine, activity: Activity) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            channel.setMethodCallHandler(AppBlockerPlugin(activity, activity))
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getInstalledApps" -> getInstalledApps(result)
            "startBlocking" -> {
                val packages = call.argument<List<String>>("packages") ?: emptyList()
                startBlocking(packages, result)
            }
            "stopBlocking" -> stopBlocking(result)
            "isAccessibilityEnabled" -> isAccessibilityEnabled(result)
            "openAccessibilitySettings" -> openAccessibilitySettings(result)
            else -> result.notImplemented()
        }
    }

    private fun getInstalledApps(result: MethodChannel.Result) {
        try {
            val pm = context.packageManager
            val apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
                .filter { app ->
                    // Only user-installed apps with a launcher intent
                    (app.flags and ApplicationInfo.FLAG_SYSTEM) == 0 &&
                    pm.getLaunchIntentForPackage(app.packageName) != null
                }
                .map { app ->
                    mapOf(
                        "packageName" to app.packageName,
                        "appName" to (pm.getApplicationLabel(app)?.toString() ?: app.packageName)
                    )
                }
            result.success(apps)
        } catch (e: Exception) {
            result.error("GET_APPS_ERROR", e.message, null)
        }
    }

    private fun startBlocking(packages: List<String>, result: MethodChannel.Result) {
        try {
            AppBlockerService.blockedPackages = packages.toMutableSet()
            AppBlockerService.isBlocking = true
            result.success(true)
        } catch (e: Exception) {
            result.error("START_BLOCKING_ERROR", e.message, null)
        }
    }

    private fun stopBlocking(result: MethodChannel.Result) {
        try {
            AppBlockerService.isBlocking = false
            AppBlockerService.blockedPackages.clear()
            result.success(true)
        } catch (e: Exception) {
            result.error("STOP_BLOCKING_ERROR", e.message, null)
        }
    }

    private fun isAccessibilityEnabled(result: MethodChannel.Result) {
        try {
            val service = "${context.packageName}/${AppBlockerService::class.java.canonicalName}"
            val enabledServices = Settings.Secure.getString(
                context.contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            ) ?: ""
            result.success(enabledServices.contains(service))
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun openAccessibilitySettings(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            activity.startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("SETTINGS_ERROR", e.message, null)
        }
    }
}
