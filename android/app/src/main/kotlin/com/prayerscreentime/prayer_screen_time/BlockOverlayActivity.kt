package com.prayerscreentime.prayer_screen_time

import android.os.Bundle
import android.os.CountDownTimer
import android.widget.LinearLayout
import android.widget.TextView
import android.view.Gravity
import android.graphics.Color
import android.app.Activity

class BlockOverlayActivity : Activity() {

    private var countDownTimer: CountDownTimer? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#1B5E20"))
            setPadding(48, 48, 48, 48)
        }

        val iconText = TextView(this).apply {
            text = "🕌"
            textSize = 64f
            gravity = Gravity.CENTER
        }

        val titleText = TextView(this).apply {
            text = "Prayer Time"
            textSize = 28f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setPadding(0, 32, 0, 16)
        }

        val messageText = TextView(this).apply {
            text = "This app is blocked during prayer time.\nFocus on what matters most."
            textSize = 16f
            setTextColor(Color.parseColor("#C8E6C9"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 48)
        }

        val countdownText = TextView(this).apply {
            textSize = 20f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
        }

        layout.addView(iconText)
        layout.addView(titleText)
        layout.addView(messageText)
        layout.addView(countdownText)

        setContentView(layout)

        // Auto-dismiss check every second
        countDownTimer = object : CountDownTimer(Long.MAX_VALUE, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                if (!AppBlockerService.isBlocking) {
                    finish()
                }
            }
            override fun onFinish() {}
        }.start()
    }

    override fun onDestroy() {
        super.onDestroy()
        countDownTimer?.cancel()
    }

    @Deprecated("Use OnBackInvokedCallback")
    override fun onBackPressed() {
        // Prevent back navigation — user must wait for prayer time to end
        // Go to home screen instead
        val homeIntent = android.content.Intent(android.content.Intent.ACTION_MAIN).apply {
            addCategory(android.content.Intent.CATEGORY_HOME)
            flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)
    }
}
