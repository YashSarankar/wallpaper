package com.amozea.wallpapers

import android.media.MediaPlayer
import android.service.wallpaper.WallpaperService
import android.view.SurfaceHolder
import android.content.Context
import android.util.Log

class VideoWallpaperService : WallpaperService() {
    override fun onCreateEngine(): Engine {
        return VideoEngine()
    }

    inner class VideoEngine : Engine() {
        private var mediaPlayer: MediaPlayer? = null
        private val TAG = "VideoWallpaperService"

        override fun onSurfaceCreated(holder: SurfaceHolder) {
            super.onSurfaceCreated(holder)
            Log.d(TAG, "onSurfaceCreated")
            try {
                val prefs = getSharedPreferences("wallpaper_prefs", Context.MODE_PRIVATE)
                val videoPath = prefs.getString("video_path", null)
                
                if (videoPath != null) {
                    mediaPlayer = MediaPlayer().apply {
                        setSurface(holder.surface)
                        setDataSource(videoPath)
                        isLooping = true
                        setVideoScalingMode(MediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING)
                        prepare()
                        start()
                    }
                } else {
                    Log.e(TAG, "Video path is null in SharedPreferences")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error initializing MediaPlayer: ${e.message}")
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
            mediaPlayer?.release()
            mediaPlayer = null
        }

        override fun onDestroy() {
            super.onDestroy()
            mediaPlayer?.release()
            mediaPlayer = null
        }
    }
}
