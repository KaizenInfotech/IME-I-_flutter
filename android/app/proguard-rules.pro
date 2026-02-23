# Firebase Messaging — prevent R8 from stripping classes needed for push notifications
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Firebase Messaging Service
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.iid.** { *; }

# Flutter Firebase Messaging plugin
-keep class io.flutter.plugins.firebase.messaging.** { *; }

# Keep Flutter local notifications plugin
-keep class com.dexterous.** { *; }

# Keep Gson (used by Firebase)
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }