const mongoose = require('mongoose');

const WallpaperSchema = new mongoose.Schema({
    title: {
        type: String,
        // required: true, // Optional: might not always have a title initially
    },
    category: {
        type: String,
        required: true,
        index: true,
    },
    imageUrl: {
        original: {
            type: String,
            required: true,
        },
        mid: {
            type: String,
            required: true,
        },
        low: {
            type: String,
            required: true,
        }
    },
    type: {
        type: String,
        enum: ['static', 'animated'],
        default: 'static',
    },
    videoUrl: {
        type: String,
    },
    createdAt: {
        type: Date,
        default: Date.now,
    },
});

module.exports = mongoose.model('Wallpaper', WallpaperSchema, 'Wallpapers');
