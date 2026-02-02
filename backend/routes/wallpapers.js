const express = require('express');
const router = express.Router();
const Wallpaper = require('../models/Wallpaper');
const multer = require('multer');
const { processAndUploadImage } = require('../services/imageService');

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
// @access  Public
router.post('/', upload.single('image'), async (req, res) => {
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
        console.error(err);
        res.status(500).send('Server Error');
    }
});

// @route   DELETE api/wallpapers/:id
// @desc    Delete a wallpaper
// @access  Public (Should be private in production)
router.delete('/:id', async (req, res) => {
    try {
        const wallpaper = await Wallpaper.findById(req.params.id);

        if (!wallpaper) {
            return res.status(404).json({ msg: 'Wallpaper not found' });
        }

        // Optional: Delete files from GCS as well
        // We'll skip complex GCS deletion for now to ensure DB cleanup works first,
        // but the DB entry will be gone from the app instantly.

        await wallpaper.deleteOne();

        res.json({ msg: 'Wallpaper removed' });
    } catch (err) {
        console.error(err.message);
        if (err.kind === 'ObjectId') {
            return res.status(404).json({ msg: 'Wallpaper not found' });
        }
        res.status(500).send('Server Error');
    }
});

module.exports = router;
