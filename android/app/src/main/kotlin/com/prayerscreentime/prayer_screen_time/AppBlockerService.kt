package com.prayerscreentime.prayer_screen_time

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

class AppBlockerService : AccessibilityService() {

    companion object {
        var isBlocking = false
        var blockedPackages = mutableSetOf<String>()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (!isBlocking || event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val packageName = event.packageName?.toString() ?: return

        // Don't block our own app or system UI
        if (packageName == this.packageName) return
        if (packageName == "com.android.systemui") return
        if (packageName == "com.android.launcher3") return

        if (blockedPackages.contains(packageName)) {
            // Launch block overlay
            val intent = Intent(this, BlockOverlayActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                putExtra("blocked_package", packageName)
            }
            startActivity(intent)
        }
    }

    override fun onInterrupt() {
        // Required override
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
    }
}
