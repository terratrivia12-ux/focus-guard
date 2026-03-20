package com.focusguard

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

class AppBlockerAccessibilityService : AccessibilityService() {

    companion object {
        private var blockedApps: List<String> = emptyList()
        private var blockEndTime: Long = 0L

        fun setBlockedApps(packages: List<String>) {
            blockedApps = packages
        }

        fun setBlockEndTime(time: Long) {
            blockEndTime = time
        }

        fun isBlocking(): Boolean {
            return blockedApps.isNotEmpty() && System.currentTimeMillis() < blockEndTime
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString() ?: return
            if (isBlocking() && blockedApps.contains(packageName)) {
                // Launch block overlay activity
                val intent = Intent(this, BlockOverlayActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("blocked_app", packageName)
                }
                startActivity(intent)
            }
        }
    }

    override fun onInterrupt() {}
}
