package com.imeiconnect.touchbase_flutter

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.imeiconnect.touchbase_flutter/notifications"
    private var methodChannel: MethodChannel? = null
    private var pendingNavigation: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getPendingNavigation" -> {
                    result.success(pendingNavigation)
                    pendingNavigation = null
                }
                else -> result.notImplemented()
            }
        }

        // Check if app was launched from a notification tap (cold start)
        checkNotificationIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        checkNotificationIntent(intent)
        // Warm start — Flutter is already running, push directly
        val nav = pendingNavigation
        if (nav != null) {
            methodChannel?.invokeMethod("navigateTo", nav)
            pendingNavigation = null
        }
    }

    private fun checkNotificationIntent(intent: Intent?) {
        val navigateTo = intent?.getStringExtra("navigate_to")
        if (navigateTo != null) {
            pendingNavigation = navigateTo
            intent?.removeExtra("navigate_to")
        }
    }
}