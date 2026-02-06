const express = require('express');
const router = express.Router();
const Wallpaper = require('../models/Wallpaper');
const multer = require('multer');
const { processAndUploadImage } = require('../services/imageService');
const { bucket } = require('../config/gcs');
const auth = require('../middleware/auth');

// Multer config for memory storage
const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: 10 * 1024 * 1024, // 10MB limit
    },
});

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
router.post('/', [auth, upload.single('image')], async (req, res) => {
    try {
        const { title, category } = req.body;
        let imageUrl = req.body.imageUrl;

        if (req.file) {
            imageUrl = await processAndUploadImage(req.file.buffer, req.file.originalname);
        }

        if (!imageUrl) {
            return res.status(400).json({ msg: 'Image is required' });
        }

        const newWallpaper = new Wallpaper({ title, category, imageUrl });
        const wallpaper = await newWallpaper.save();
        res.json(wallpaper);
    } catch (err) {
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

                await Promise.all([
                    bucket.file(lowPath).delete().catch(() => { }),
                    bucket.file(midPath).delete().catch(() => { }),
                    bucket.file(originalPath).delete().catch(() => { }),
                ]);
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

                    await Promise.all([
                        bucket.file(lowPath).delete().catch(() => { }),
                        bucket.file(midPath).delete().catch(() => { }),
                        bucket.file(originalPath).delete().catch(() => { }),
                    ]);
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
