package com.focusguard

import android.app.Activity
import android.os.Bundle
import android.widget.Button
import android.widget.TextView

class BlockOverlayActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Programmatic layout for the block screen
        val layout = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.VERTICAL
            gravity = android.view.Gravity.CENTER
            setBackgroundColor(android.graphics.Color.parseColor("#07070F"))
            setPadding(64, 64, 64, 64)
        }

        val icon = TextView(this).apply {
            text = "🛡️"
            textSize = 64f
            gravity = android.view.Gravity.CENTER
        }

        val title = TextView(this).apply {
            text = "App Blocked"
            textSize = 28f
            setTextColor(android.graphics.Color.WHITE)
            gravity = android.view.Gravity.CENTER
            typeface = android.graphics.Typeface.DEFAULT_BOLD
        }

        val subtitle = TextView(this).apply {
            text = "You're in a focus session.\nStay locked in — you've got this!"
            textSize = 16f
            setTextColor(android.graphics.Color.parseColor("#888899"))
            gravity = android.view.Gravity.CENTER
            setPadding(0, 16, 0, 48)
        }

        val backBtn = Button(this).apply {
            text = "Go Back"
            textSize = 16f
            setTextColor(android.graphics.Color.WHITE)
            setBackgroundColor(android.graphics.Color.parseColor("#FF6B35"))
            setPadding(48, 24, 48, 24)
            setOnClickListener {
                // Return to home screen
                val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_HOME)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                startActivity(homeIntent)
                finish()
            }
        }

        layout.addView(icon)
        layout.addView(title)
        layout.addView(subtitle)
        layout.addView(backBtn)
        setContentView(layout)
    }

    override fun onBackPressed() {
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)
        finish()
    }
}
