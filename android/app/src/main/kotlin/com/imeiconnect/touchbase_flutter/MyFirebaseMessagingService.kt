package com.imeiconnect.touchbase_flutter

import android.app.ActivityManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.Build
import android.text.Html
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import kotlin.random.Random

/**
 * Purely native FCM service — extends FirebaseMessagingService directly
 * (NOT FlutterFirebaseMessagingService) so it has ZERO Flutter/Dart dependency.
 *
 * Mirrors IME(I) App's MyFirebaseMessagingService.java exactly:
 * receives data messages, creates notification via NotificationCompat,
 * shows it via NotificationManager. Works even when app is killed.
 */
class MyFirebaseMessagingService : FirebaseMessagingService() {

    companion object {
        private const val TAG = "MyFCMService"
        private const val CHANNEL_ID = "IME(I)-iConnect"
        private const val CHANNEL_NAME = "IME(I)-iConnect"
    }

    override fun onMessageReceived(message: RemoteMessage) {
        Log.d(TAG, "onMessageReceived: ${message.messageId}")
        Log.d(TAG, "data: ${message.data}")

        try {
            val data = message.data
            // Only show native notification when app is NOT in foreground.
            // Foreground notifications are handled by Dart (app.dart onMessage).
            if (data.isNotEmpty() && !isAppInForeground()) {
                showNotification(data)
            }
        } catch (e: Exception) {
            Log.e(TAG, "onMessageReceived error: ${e.message}", e)
        }
    }

    override fun onNewToken(token: String) {
        Log.d(TAG, "FCM token refreshed: $token")
    }

    private fun isAppInForeground(): Boolean {
        val appProcessInfo = ActivityManager.RunningAppProcessInfo()
        ActivityManager.getMyMemoryState(appProcessInfo)
        return appProcessInfo.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
    }

    /**
     * Create and show a notification — mirrors IME(I) App's createNotification().
     */
    private fun showNotification(data: Map<String, String>) {
        val messageText = data["Message"] ?: return
        val plainText = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            Html.fromHtml(messageText, Html.FROM_HTML_MODE_LEGACY).toString().trim()
        } else {
            @Suppress("DEPRECATION")
            Html.fromHtml(messageText).toString().trim()
        }

        if (plainText.isEmpty()) return

        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Create notification channel (Android 8+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            )
            channel.description = CHANNEL_NAME
            channel.enableVibration(true)
            channel.vibrationPattern = longArrayOf(1000, 0, 1000, 0, 1000)
            notificationManager.createNotificationChannel(channel)
        }

        // PendingIntent to open the app on tap
        var pendingIntent: PendingIntent? = null
        try {
            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            if (launchIntent != null) {
                launchIntent.addFlags(
                    android.content.Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    android.content.Intent.FLAG_ACTIVITY_SINGLE_TOP
                )
                // Tell Flutter to navigate to notifications screen on tap
                launchIntent.putExtra("navigate_to", "notifications")
                val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                } else {
                    PendingIntent.FLAG_UPDATE_CURRENT
                }
                pendingIntent = PendingIntent.getActivity(this, 0, launchIntent, flags)
            }
        } catch (e: Exception) {
            Log.e(TAG, "PendingIntent creation failed: ${e.message}", e)
        }

        // Build notification matching IME(I) App
        val largeIconBitmap = BitmapFactory.decodeResource(resources, R.drawable.ic_launcher_big)

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
        builder.setContentTitle(CHANNEL_NAME)
        builder.setContentText(plainText)
        builder.setStyle(NotificationCompat.BigTextStyle().bigText(plainText))
        builder.setSmallIcon(R.drawable.ic_launcher_big)
        builder.setLargeIcon(largeIconBitmap)
        builder.color = Color.parseColor("#00AEEF")
        builder.priority = NotificationCompat.PRIORITY_HIGH
        builder.setVibrate(longArrayOf(1000, 0, 1000, 0, 1000))
        builder.setAutoCancel(true)
        if (pendingIntent != null) {
            builder.setContentIntent(pendingIntent)
        }

        val notificationId = Random.nextInt(1, 100)
        notificationManager.notify(notificationId, builder.build())
        Log.d(TAG, "Native notification shown: id=$notificationId, text=$plainText")
    }
}