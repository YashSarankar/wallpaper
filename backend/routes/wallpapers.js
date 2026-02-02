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

// @route   GET /api/wallpapers/storage-sync
// @desc    Get all files directly from GCS bucket
router.get('/storage-sync', auth, async (req, res) => {
    try {
        console.log(`Manual Sync requested for bucket: ${bucket ? bucket.name : 'NULL'}`);
        if (!bucket) {
            return res.status(500).json({ error: 'GCS Bucket not initialized' });
        }

        const [files] = await bucket.getFiles();
        console.log(`Total files found in bucket: ${files.length}`);

        // Let's log the first 5 file names to see the structure
        files.slice(0, 5).forEach(f => console.log(` - File: ${f.name}`));

        // Filter for files in 'original' folder 
        const originalFiles = files.filter(f => f.name.includes('/original/') && !f.name.endsWith('/'));
        console.log(`Filtered 'original' files: ${originalFiles.length}`);

        const wallpapersFromGCS = originalFiles.map(file => {
            const fileName = file.name.split('/').pop();
            return {
                _id: file.name,
                title: fileName.replace('.jpg', '').replace('.jpeg', ''),
                category: 'GCS Storage',
                imageUrl: {
                    original: `https://storage.googleapis.com/${bucket.name}/${file.name}`,
                    mid: `https://storage.googleapis.com/${bucket.name}/${file.name.replace('/original/', '/mid/')}`,
                    low: `https://storage.googleapis.com/${bucket.name}/${file.name.replace('/original/', '/low/')}`
                },
                isStorageOnly: true
            };
        });

        res.json(wallpapersFromGCS);
    } catch (err) {
        console.error('CRITICAL SYNC ERROR:', err);
        res.status(500).json({
            msg: 'GCS Sync failed',
            error: err.message,
            bucket: bucket ? bucket.name : 'NULL'
        });
    }
});

// @route   GET /api/wallpapers
// @desc    Get all wallpapers
// @access  Public
router.get('/', async (req, res) => {
    try {
        const wallpapers = await Wallpaper.find().sort({ createdAt: -1 });
        res.json(wallpapers);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
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
        console.error(err);
        res.status(500).send('Server Error');
    }
});

// @route   POST /api/wallpapers
// @desc    Add a new wallpaper (supports file upload)
// @access  Private
router.post('/', [auth, upload.single('image')], async (req, res) => {
    try {
        const { title, category } = req.body;
        console.log(`POST /api/wallpapers - Title: ${title}, Category: ${category}`);

        let imageUrl = req.body.imageUrl; // If passing JSON URLs directly

        // If file is provided, process it
        if (req.file) {
            console.log(`File received: ${req.file.originalname}, Size: ${req.file.size}`);
            const uploadedUrls = await processAndUploadImage(req.file.buffer, req.file.originalname);
            imageUrl = uploadedUrls;
        }

        if (!imageUrl) {
            return res.status(400).json({ msg: 'Image is required (either file or imageUrl object)' });
        }

        // Ensure imageUrl has the correct structure if passed manually
        // If it came from uploadService, it definitely has { original, mid, low }

        const newWallpaper = new Wallpaper({
            title,
            category,
            imageUrl
        });

        const wallpaper = await newWallpaper.save();
        res.json(wallpaper);
    } catch (err) {
        console.error('Upload Route Error:', err);
        res.status(500).json({
            msg: 'Server processing error',
            error: err.message,
            stack: process.env.NODE_ENV === 'production' ? null : err.stack
        });
    }
});

// @route   DELETE api/wallpapers/:id
// @desc    Delete a wallpaper
// @access  Private
router.delete('/:id', auth, async (req, res) => {
    try {
        const id = req.params.id;

        // If the ID looks like a GCS path (contains 'wallpapers/')
        if (id.includes('wallpapers/')) {
            console.log(`Deleting file directly from GCS: ${id}`);
            const file = bucket.file(id);
            const [exists] = await file.exists();
            if (exists) {
                await file.delete();
                // Also try to delete mid and original versions
                try {
                    await bucket.file(id.replace('/low/', '/mid/')).delete();
                    await bucket.file(id.replace('/low/', '/original/')).delete();
                } catch (e) { /* ignore if mid/original don't exist */ }
            }
            return res.json({ msg: 'GCS File removed' });
        }

        const wallpaper = await Wallpaper.findById(id);

        if (!wallpaper) {
            return res.status(404).json({ msg: 'Wallpaper not found' });
        }

        // Try to delete GCS files if they exist in the wallpaper object
        if (wallpaper.imageUrl && wallpaper.imageUrl.low) {
            const lowPath = wallpaper.imageUrl.low.split('.com/')[1].split('/').slice(1).join('/');
            // ... complex path logic can be added, but DB delete is primary
        }

        await wallpaper.deleteOne();

        res.json({ msg: 'Wallpaper removed' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

module.exports = router;
