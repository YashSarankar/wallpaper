const mongoose = require('mongoose');

const ConfigSchema = new mongoose.Schema({
    min_version: {
        type: String,
        default: '1.0.0',
    },
    update_url: {
        type: String,
        default: 'https://play.google.com/store/apps/details?id=com.amozea.wallpapers',
    },
    update_message: {
        type: String,
        default: 'A new version of Amozea is available. Please update to continue.',
    },
    force_update: {
        type: Boolean,
        default: false,
    },
    updatedAt: {
        type: Date,
        default: Date.now,
    },
});

module.exports = mongoose.model('Config', ConfigSchema, 'Config');
