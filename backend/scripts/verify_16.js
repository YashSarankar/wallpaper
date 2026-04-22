require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const Wallpaper = require('../models/Wallpaper');
const axios = require('axios');
const sharp = require('sharp');

async function verify16() {
    await mongoose.connect(process.env.MONGO_URI);
    // Find the 16 TRUE 4K ones by checking the 'true_4k' in the path or just sorting by recent
    const recent = await Wallpaper.find({ 'imageUrl.original': /true_4k/ });
    console.log(`Verifying ${recent.length} "True 4K" wallpapers:`);
    for (let w of recent) {
        try {
            const resp = await axios.get(w.imageUrl.original, { responseType: 'arraybuffer' });
            const meta = await sharp(resp.data).metadata();
            console.log(`- ${w.title}: ${meta.width}x${meta.height} (GCS URL: ${w.imageUrl.original})`);
        } catch (e) {
            console.log(`- ${w.title}: ERROR`);
        }
    }
    process.exit();
}
verify16();
