# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.internal.**
-keep public class com.google.android.gms.** { public *; }

# OkHttp & Network (R8/ProGuard fix for Conscrypt)
-dontwarn org.conscrypt.**
-keep class org.conscrypt.** { *; }
-dontwarn okhttp3.**
-keep class okhttp3.** { *; }

# Async Wallpaper
-keep class com.codenameakshay.async_wallpaper.** { *; }

# Play Core (Flutter Deferred Components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
