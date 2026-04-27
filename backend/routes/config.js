const express = require('express');
const router = express.Router();
const Config = require('../models/Config');

// @route   GET api/config
// @desc    Get remote config
// @access  Public
router.get('/', async (req, res) => {
    try {
        let config = await Config.findOne();
        
        // If no config exists, return default values to prevent crash
        if (!config) {
            return res.json({
                min_version: '1.0.0',
                update_url: 'https://play.google.com/store/apps/details?id=com.amozea.wallpapers',
                update_message: 'A new version of Amozea is available. Please update to continue.',
                force_update: false
            });
        }
        
        res.json(config);
    } catch (err) {
        console.error('Config fetch error:', err.message);
        res.status(500).send('Server Error');
    }
});

module.exports = router;
