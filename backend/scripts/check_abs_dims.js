require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const Wallpaper = require('../models/Wallpaper');
const axios = require('axios');
const sharp = require('sharp');

async function checkAbstract() {
    await mongoose.connect(process.env.MONGO_URI);
    const abs = await Wallpaper.find({ category: 'Abstract' });
    console.log(`Checking ${abs.length} Abstract wallpapers...`);
    for (let w of abs) {
        try {
            const resp = await axios.get(w.imageUrl.original, { responseType: 'arraybuffer' });
            const meta = await sharp(resp.data).metadata();
            console.log(`- ${w.title}: ${meta.width}x${meta.height}`);
        } catch (e) {
            console.log(`- ${w.title}: ERROR`);
        }
    }
    process.exit();
}
checkAbstract();
