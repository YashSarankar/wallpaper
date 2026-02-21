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
import java.io.File
import android.graphics.BitmapFactory
import android.graphics.Rect
import android.os.Build

class WallpaperPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel : MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.amozea.wallpapers/wallpaper")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "setWallpaper" -> {
                val path = call.argument<String>("path")
                val location = call.argument<Int>("location") ?: 3
                if (path != null) {
                    setStaticWallpaper(path, location, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Path missing", null)
                }
            }
            "setLiveWallpaper" -> {
                val path = call.argument<String>("path")
                if (path != null) {
                    setLiveWallpaper(path, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Path missing", null)
                }
            }
            "isLiveWallpaperActive" -> {
                result.success(isLiveWallpaperActive())
            }
            "openFile" -> {
                val path = call.argument<String>("path")
                if (path != null) {
                    openFile(path, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Path missing", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun isLiveWallpaperActive(): Boolean {
        val wm = WallpaperManager.getInstance(context)
        val info = wm.wallpaperInfo
        return info != null && info.packageName == context.packageName && info.serviceName == VideoWallpaperService::class.java.name
    }

    private fun setLiveWallpaper(path: String, result: Result) {
        try {
            // 1. Save path to SharedPreferences so the Service can find it
            val prefs = context.getSharedPreferences("wallpaper_prefs", Context.MODE_PRIVATE)
            prefs.edit().putString("live_wallpaper_path", path).apply()

            // 2. Open Wallpaper Picker
            val intent = Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER)
            intent.putExtra(WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
                ComponentName(context, VideoWallpaperService::class.java))
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)

            result.success(true)
        } catch (e: Exception) {
            result.error("LIVE_SET_ERROR", e.message, null)
        }
    }

    private fun openFile(path: String, result: Result) {
        try {
            val file = File(path)
            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "File does not exist: $path", null)
                return
            }

            val authority = "${context.packageName}.fileprovider"
            val uri = androidx.core.content.FileProvider.getUriForFile(context, authority, file)
            
            val intent = Intent(Intent.ACTION_VIEW)
            intent.setDataAndType(uri, "image/*")
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            
            context.startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("OPEN_ERROR", e.localizedMessage ?: "Unknown error", null)
        }
    }

    private fun setStaticWallpaper(path: String, location: Int, result: Result) {
        Thread {
            try {
                val wm = WallpaperManager.getInstance(context)
                val bitmap = BitmapFactory.decodeFile(path)

                if (bitmap == null) {
                    result.error("DECODE_ERROR", "Failed to decode image", null)
                    return@Thread
                }

                val metrics = context.resources.displayMetrics
                val screenWidth = metrics.widthPixels
                val screenHeight = metrics.heightPixels
                val bitmapWidth = bitmap.width
                val bitmapHeight = bitmap.height

                val screenAspect = screenWidth.toFloat() / screenHeight.toFloat()
                val bitmapAspect = bitmapWidth.toFloat() / bitmapHeight.toFloat()

                val cropRect: Rect
                if (bitmapAspect > screenAspect) {
                    val newWidth = (bitmapHeight * screenAspect).toInt()
                    val startX = (bitmapWidth - newWidth) / 2
                    cropRect = Rect(startX, 0, startX + newWidth, bitmapHeight)
                } else {
                    val newHeight = (bitmapWidth / screenAspect).toInt()
                    val startY = (bitmapHeight - newHeight) / 2
                    cropRect = Rect(0, startY, bitmapWidth, startY + newHeight)
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    if (location == 1 || location == 3) {
                        wm.setBitmap(bitmap, cropRect, true, WallpaperManager.FLAG_SYSTEM)
                    }
                    if (location == 2 || location == 3) {
                        wm.setBitmap(bitmap, cropRect, true, WallpaperManager.FLAG_LOCK)
                    }
                } else {
                    wm.setBitmap(bitmap)
                }
                result.success("Success")
            } catch (e: Exception) {
                result.error("SET_ERROR", e.message, null)
            }
        }.start()
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
