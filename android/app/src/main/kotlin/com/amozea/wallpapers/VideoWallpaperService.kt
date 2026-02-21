package com.amozea.wallpapers

import android.media.MediaPlayer
import android.service.wallpaper.WallpaperService
import android.view.SurfaceHolder
import android.content.Context
import android.util.Log
import java.io.File

class VideoWallpaperService : WallpaperService() {
    override fun onCreateEngine(): Engine {
        return VideoEngine()
    }

    inner class VideoEngine : Engine() {
        private var mediaPlayer: MediaPlayer? = null
        private val TAG = "VideoWallpaperService"
        private var currentPath: String? = null

        override fun onVisibilityChanged(visible: Boolean) {
            if (visible) {
                // When returning to preview, check if we need to load a NEW video
                val latestPath = getLatestPath()
                if (latestPath != currentPath) {
                    playVideo()
                } else {
                    mediaPlayer?.start()
                }
            } else {
                mediaPlayer?.pause()
            }
        }

        override fun onSurfaceCreated(holder: SurfaceHolder) {
            super.onSurfaceCreated(holder)
            playVideo()
        }

        override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
            super.onSurfaceChanged(holder, format, width, height)
            // Just ensure it's playing on the correct surface
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            super.onSurfaceDestroyed(holder)
            releasePlayer()
        }

        override fun onDestroy() {
            super.onDestroy()
            releasePlayer()
        }

        private fun releasePlayer() {
            mediaPlayer?.stop()
            mediaPlayer?.release()
            mediaPlayer = null
            currentPath = null
        }

        private fun getLatestPath(): String? {
            val prefs = getSharedPreferences("wallpaper_prefs", Context.MODE_PRIVATE)
            return prefs.getString("live_wallpaper_path", null)
        }

        private fun playVideo() {
            val videoPath = getLatestPath()
            
            if (videoPath == null || !File(videoPath).exists()) {
                Log.e(TAG, "Video path is null or file does not exist: $videoPath")
                return
            }

            try {
                mediaPlayer?.release()
                currentPath = videoPath
                
                mediaPlayer = MediaPlayer().apply {
                    setSurface(surfaceHolder.surface)
                    setDataSource(videoPath)
                    setLooping(true)
                    setVolume(0f, 0f) // Silent
                    prepare()
                    start()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error playing video wallpaper", e)
            }
        }
    }
}
