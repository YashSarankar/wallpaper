package com.amozea.wallpapers

import android.app.WallpaperManager
import android.content.Intent
import android.graphics.BitmapFactory
import android.graphics.Rect
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.StrictMode
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.activity.enableEdgeToEdge
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.amozea.wallpapers/wallpaper"

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }

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
                val wallpaperManager = WallpaperManager.getInstance(this@MainActivity)
                val bitmap = BitmapFactory.decodeFile(path)

                if (bitmap == null) {
                    runOnUiThread {
                        result.error("DECODE_ERROR", "Failed to decode image", null)
                    }
                    return@Thread
                }

                // Calculate crop hint to center the image
                val metrics = resources.displayMetrics
                val screenWidth = metrics.widthPixels
                val screenHeight = metrics.heightPixels
                
                val bitmapWidth = bitmap.width
                val bitmapHeight = bitmap.height

                val screenAspect = screenWidth.toFloat() / screenHeight.toFloat()
                val bitmapAspect = bitmapWidth.toFloat() / bitmapHeight.toFloat()

                val cropRect: Rect

                if (bitmapAspect > screenAspect) {
                     // Image is wider than screen, crop width
                     val newWidth = (bitmapHeight * screenAspect).toInt()
                     val startX = (bitmapWidth - newWidth) / 2
                     cropRect = Rect(startX, 0, startX + newWidth, bitmapHeight)
                } else {
                     // Image is taller than screen, crop height
                     val newHeight = (bitmapWidth / screenAspect).toInt()
                     val startY = (bitmapHeight - newHeight) / 2
                     cropRect = Rect(0, startY, bitmapWidth, startY + newHeight)
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    // 1 = Home, 2 = Lock, 3 = Both
                    if (location == 1 || location == 3) {
                        wallpaperManager.setBitmap(bitmap, cropRect, true, WallpaperManager.FLAG_SYSTEM)
                    }
                    if (location == 2 || location == 3) {
                        wallpaperManager.setBitmap(bitmap, cropRect, true, WallpaperManager.FLAG_LOCK)
                    }
                } else {
                    wallpaperManager.setBitmap(bitmap)
                }

                runOnUiThread {
                    Toast.makeText(this@MainActivity, "Wallpaper set successfully", Toast.LENGTH_SHORT).show()
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

            // Using packageName to fix potential authority mismatch
            val authority = "${this@MainActivity.packageName}.fileprovider"
            val uri = FileProvider.getUriForFile(this@MainActivity, authority, file)
            
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
