package com.amozea.wallpapers

import android.app.WallpaperManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class WallpaperPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel : MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.amozea.wallpapers/wallpaper_background")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "isLiveWallpaperActive" -> {
                try {
                    val wm = WallpaperManager.getInstance(context)
                    val info = wm.wallpaperInfo
                    val isActive = info != null && info.packageName == context.packageName
                    result.success(isActive)
                } catch (e: Exception) {
                    result.success(false)
                }
            }
            "updateLiveWallpaperSilent" -> {
                val path = call.argument<String>("path")
                if (path != null) {
                    try {
                        val prefs = context.getSharedPreferences("wallpaper_prefs", Context.MODE_PRIVATE)
                        prefs.edit().putString("video_path", path).apply()

                        val updateIntent = Intent("com.amozea.wallpapers.UPDATE_VIDEO")
                        updateIntent.putExtra("video_path", path)
                        context.sendBroadcast(updateIntent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UPDATE_ERROR", e.message, null)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "Path missing", null)
                }
            }
            "setStaticWallpaper" -> {
                val path = call.argument<String>("path")
                val location = call.argument<Int>("location") ?: 3 // Both by default
                if (path != null) {
                    setStaticWallpaper(path, location, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Path missing", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun setStaticWallpaper(path: String, location: Int, result: Result) {
        try {
            val wm = WallpaperManager.getInstance(context)
            val options = android.graphics.BitmapFactory.Options()
            val bitmap = android.graphics.BitmapFactory.decodeFile(path, options)

            if (bitmap == null) {
                result.error("DECODE_ERROR", "Failed to decode image", null)
                return
            }

            // Calculate crop hint (Centering)
            val metrics = context.resources.displayMetrics
            val screenWidth = metrics.widthPixels
            val screenHeight = metrics.heightPixels
            val bitmapWidth = bitmap.width
            val bitmapHeight = bitmap.height

            val screenAspect = screenWidth.toFloat() / screenHeight.toFloat()
            val bitmapAspect = bitmapWidth.toFloat() / bitmapHeight.toFloat()

            val cropRect: android.graphics.Rect
            if (bitmapAspect > screenAspect) {
                val newWidth = (bitmapHeight * screenAspect).toInt()
                val startX = (bitmapWidth - newWidth) / 2
                cropRect = android.graphics.Rect(startX, 0, startX + newWidth, bitmapHeight)
            } else {
                val newHeight = (bitmapWidth / screenAspect).toInt()
                val startY = (bitmapHeight - newHeight) / 2
                cropRect = android.graphics.Rect(0, startY, bitmapWidth, startY + newHeight)
            }

            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                if (location == 1 || location == 3) {
                    wm.setBitmap(bitmap, cropRect, true, WallpaperManager.FLAG_SYSTEM)
                }
                if (location == 2 || location == 3) {
                    wm.setBitmap(bitmap, cropRect, true, WallpaperManager.FLAG_LOCK)
                }
            } else {
                wm.setBitmap(bitmap)
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("SET_ERROR", e.message, null)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
