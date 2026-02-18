const express = require('express');
const router = express.Router();
const Wallpaper = require('../models/Wallpaper');
const multer = require('multer');
const { processAndUploadImage, uploadVideo } = require('../services/imageService');
const { bucket } = require('../config/gcs');
const auth = require('../middleware/auth');

// Multer config for memory storage
const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: 50 * 1024 * 1024, // 50MB limit for videos
    },
});

const wallpaperUpload = upload.fields([
    { name: 'image', maxCount: 1 },
    { name: 'video', maxCount: 1 }
]);

// @route   GET /api/wallpapers
// @desc    Get all wallpapers
// @access  Public
router.get('/', async (req, res) => {
    try {
        const wallpapers = await Wallpaper.find().sort({ createdAt: -1 });
        res.json(wallpapers);
    } catch (err) {
        console.error('FETCH WALLPAPERS ERROR:', err.message);
        res.status(500).json({
            msg: 'Server Error fetching wallpapers',
            error: err.message
        });
    }
});

// @route   GET /api/wallpapers/category/:category
// @desc    Get wallpapers by category
// @access  Public
router.get('/category/:category', async (req, res) => {
    try {
        const wallpapers = await Wallpaper.find({ category: req.params.category }).sort({ createdAt: -1 });
        res.json(wallpapers);
    } catch (err) {
        console.error('FETCH BY CATEGORY ERROR:', err.message);
        res.status(500).json({
            msg: 'Server Error fetching category',
            error: err.message
        });
    }
});

// @route   POST /api/wallpapers
// @desc    Add a new wallpaper (supports file upload)
// @access  Private
router.post('/', auth, wallpaperUpload, async (req, res) => {
    try {
        const { title, category, type } = req.body;
        let imageUrl = req.body.imageUrl;
        let videoUrl = req.body.videoUrl;

        // Handle Image Upload
        if (req.files && req.files.image) {
            imageUrl = await processAndUploadImage(req.files.image[0].buffer, req.files.image[0].originalname);
        }

        // Handle Video Upload
        if (req.files && req.files.video) {
            videoUrl = await uploadVideo(req.files.video[0].buffer, req.files.video[0].originalname, req.files.video[0].mimetype);
        }

        if (!imageUrl) {
            return res.status(400).json({ msg: 'Image (or preview image) is required' });
        }

        const newWallpaper = new Wallpaper({
            title,
            category,
            imageUrl,
            type: type || 'static',
            videoUrl
        });

        const wallpaper = await newWallpaper.save();
        res.json(wallpaper);
    } catch (err) {
        console.error('UPLOAD ERROR:', err);
        res.status(500).json({ msg: 'Server processing error', error: err.message });
    }
});

// @route   DELETE api/wallpapers/:id
// @access  Private
router.delete('/:id', auth, async (req, res) => {
    try {
        const id = req.params.id;

        const wallpaper = await Wallpaper.findById(id);
        if (!wallpaper) {
            return res.status(404).json({ msg: 'Wallpaper not found' });
        }

        // Cleanup GCS files
        if (wallpaper.imageUrl && wallpaper.imageUrl.low) {
            try {
                const lowPath = wallpaper.imageUrl.low.split('.com/')[1].split('/').slice(1).join('/');
                const midPath = lowPath.replace('/low/', '/mid/');
                const originalPath = lowPath.replace('/low/', '/original/');

                const deletePromises = [
                    bucket.file(lowPath).delete().catch(() => { }),
                    bucket.file(midPath).delete().catch(() => { }),
                    bucket.file(originalPath).delete().catch(() => { }),
                ];

                if (wallpaper.videoUrl) {
                    const videoPath = wallpaper.videoUrl.split('.com/')[1].split('/').slice(1).join('/');
                    deletePromises.push(bucket.file(videoPath).delete().catch(() => { }));
                }

                await Promise.all(deletePromises);
            } catch (e) {
                console.error('GCS Cleanup Error:', e.message);
            }
        }

        await wallpaper.deleteOne();
        res.json({ msg: 'Wallpaper removed' });
    } catch (err) {
        console.error('DELETE WALLPAPER ERROR:', err.message);
        res.status(500).json({
            msg: 'Server Error deleting wallpaper',
            error: err.message
        });
    }
});

// @route   POST api/wallpapers/bulk-delete
// @access  Private
router.post('/bulk-delete', auth, async (req, res) => {
    try {
        const { ids } = req.body;
        if (!ids || !Array.isArray(ids) || ids.length === 0) {
            return res.status(400).json({ msg: 'No IDs provided' });
        }

        const wallpapers = await Wallpaper.find({ _id: { $in: ids } });

        // Cleanup GCS files for each wallpaper
        for (const wallpaper of wallpapers) {
            if (wallpaper.imageUrl && wallpaper.imageUrl.low) {
                try {
                    const lowPath = wallpaper.imageUrl.low.split('.com/')[1].split('/').slice(1).join('/');
                    const midPath = lowPath.replace('/low/', '/mid/');
                    const originalPath = lowPath.replace('/low/', '/original/');

                    const deletePromises = [
                        bucket.file(lowPath).delete().catch(() => { }),
                        bucket.file(midPath).delete().catch(() => { }),
                        bucket.file(originalPath).delete().catch(() => { }),
                    ];

                    if (wallpaper.videoUrl) {
                        const videoPath = wallpaper.videoUrl.split('.com/')[1].split('/').slice(1).join('/');
                        deletePromises.push(bucket.file(videoPath).delete().catch(() => { }));
                    }

                    await Promise.all(deletePromises);
                } catch (e) {
                    console.error('GCS Cleanup Error (Bulk):', e.message);
                }
            }
        }

        await Wallpaper.deleteMany({ _id: { $in: ids } });
        res.json({ msg: `${ids.length} wallpapers removed` });
    } catch (err) {
        console.error('BULK DELETE ERROR:', err.message);
        res.status(500).json({
            msg: 'Server Error in bulk delete',
            error: err.message
        });
    }
});

module.exports = router;
