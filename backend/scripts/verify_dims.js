require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const Wallpaper = require('../models/Wallpaper');
const sharp = require('sharp');
const axios = require('axios');

async function checkActualDimensions() {
    await mongoose.connect(process.env.MONGO_URI);
    const sample = await Wallpaper.find({}).sort({ createdAt: -1 }).limit(5);

    console.log('Checking last 5 added wallpapers:');
    for (let w of sample) {
        try {
            const response = await axios.get(w.imageUrl.original, { responseType: 'arraybuffer' });
            const meta = await sharp(response.data).metadata();
            console.log(`- ${w.title}: ${meta.width}x${meta.height} (URL: ${w.imageUrl.original})`);
        } catch (e) {
            console.log(`- ${w.title}: ERROR checking dimensions (${e.message})`);
        }
    }
    process.exit();
}

checkActualDimensions();
