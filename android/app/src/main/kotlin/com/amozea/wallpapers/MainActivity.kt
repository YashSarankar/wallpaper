package com.amozea.wallpapers

import android.app.WallpaperManager
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.StrictMode
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.amozea.wallpapers/wallpaper"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setWallpaper") {
                val path = call.argument<String>("path")
                val location = call.argument<Int>("location")

                if (path != null && location != null) {
                    setWallpaper(path, location, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Path or location missing", null)
                }
            } else if (call.method == "openFile") {
                val path = call.argument<String>("path")
                if (path != null) {
                    openFile(path, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Path missing", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun setWallpaper(path: String, location: Int, result: MethodChannel.Result) {
        Thread {
            try {
                val wallpaperManager = WallpaperManager.getInstance(context)
                val bitmap = BitmapFactory.decodeFile(path)

                if (bitmap == null) {
                    runOnUiThread {
                        result.error("DECODE_ERROR", "Failed to decode image", null)
                    }
                    return@Thread
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    // 1 = Home, 2 = Lock, 3 = Both
                    if (location == 1 || location == 3) {
                        wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM)
                    }
                    if (location == 2 || location == 3) {
                        wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
                    }
                } else {
                    wallpaperManager.setBitmap(bitmap)
                }

                runOnUiThread {
                    Toast.makeText(context, "Wallpaper set successfully", Toast.LENGTH_SHORT).show()
                    result.success("Success")
                }
            } catch (e: IOException) {
                runOnUiThread {
                    result.error("IO_ERROR", e.message, null)
                }
            }
        }.start()
    }

    private fun openFile(path: String, result: MethodChannel.Result) {
        try {
            val file = File(path)
            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "File does not exist: $path", null)
                return
            }

            // Using context.packageName to fix potential authority mismatch
            val authority = "${context.packageName}.fileprovider"
            val uri = FileProvider.getUriForFile(context, authority, file)
            
            val intent = Intent(Intent.ACTION_VIEW)
            intent.setDataAndType(uri, "image/*")
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            
            // Explicitly check if there's an app that can handle this intent
            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
                result.success(true)
            } else {
                // Fallback for some devices where resolveActivity returns null but it can still open
                try {
                    startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("NO_APP_FOUND", "No app found to open this image type", null)
                }
            }
        } catch (e: Exception) {
            result.error("OPEN_ERROR", e.localizedMessage ?: "Unknown error", null)
        }
    }
}
