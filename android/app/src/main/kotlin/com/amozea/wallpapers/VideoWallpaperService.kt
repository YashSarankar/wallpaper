package com.amozea.wallpapers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.MediaPlayer
import android.service.wallpaper.WallpaperService
import android.view.SurfaceHolder
import android.util.Log
import android.os.Build

class VideoWallpaperService : WallpaperService() {
    override fun onCreateEngine(): Engine {
        return VideoEngine()
    }

    inner class VideoEngine : Engine() {
        private var mediaPlayer: MediaPlayer? = null
        private val TAG = "VideoWallpaperService"
        private var currentHolder: SurfaceHolder? = null
        private var videoUpdateReceiver: BroadcastReceiver? = null

        override fun onCreate(surfaceHolder: SurfaceHolder?) {
            super.onCreate(surfaceHolder)
            registerVideoUpdateReceiver()
        }

        private fun registerVideoUpdateReceiver() {
            videoUpdateReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    val newPath = intent?.getStringExtra("video_path")
                    if (newPath != null && currentHolder != null) {
                        Log.d(TAG, "Received broadcast to update video: $newPath")
                        playVideo(newPath, currentHolder!!)
                    }
                }
            }
            val filter = IntentFilter("com.amozea.wallpapers.UPDATE_VIDEO")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(videoUpdateReceiver, filter, Context.RECEIVER_EXPORTED)
            } else {
                registerReceiver(videoUpdateReceiver, filter)
            }
        }

        override fun onSurfaceCreated(holder: SurfaceHolder) {
            super.onSurfaceCreated(holder)
            currentHolder = holder
            Log.d(TAG, "onSurfaceCreated")
            val prefs = getSharedPreferences("wallpaper_prefs", Context.MODE_PRIVATE)
            val videoPath = prefs.getString("video_path", null)
            if (videoPath != null) {
                playVideo(videoPath, holder)
            }
        }

        private fun playVideo(path: String, holder: SurfaceHolder) {
            try {
                mediaPlayer?.release()
                mediaPlayer = MediaPlayer().apply {
                    setSurface(holder.surface)
                    setDataSource(path)
                    isLooping = true
                    setVideoScalingMode(MediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING)
                    prepare()
                    start()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error playing video: ${e.message}")
            }
        }

        override fun onVisibilityChanged(visible: Boolean) {
            if (visible) {
                mediaPlayer?.start()
            } else {
                mediaPlayer?.pause()
            }
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            super.onSurfaceDestroyed(holder)
            currentHolder = null
            mediaPlayer?.release()
            mediaPlayer = null
        }

        override fun onDestroy() {
            super.onDestroy()
            if (videoUpdateReceiver != null) {
                unregisterReceiver(videoUpdateReceiver)
            }
            mediaPlayer?.release()
            mediaPlayer = null
        }
    }
}
