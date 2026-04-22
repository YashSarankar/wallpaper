require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const Wallpaper = require('../models/Wallpaper');
const axios = require('axios');
const sharp = require('sharp');

async function auditResolutions() {
    await mongoose.connect(process.env.MONGO_URI);
    const wallpapers = await Wallpaper.find({ type: 'static' });

    console.log(`Auditing ${wallpapers.length} static wallpapers...`);
    let lowResCount = 0;

    for (const w of wallpapers) {
        try {
            const resp = await axios.get(w.imageUrl.original, { responseType: 'arraybuffer' });
            const meta = await sharp(resp.data).metadata();
            const isLowRes = (meta.width < 3000 && meta.height < 3000);
            if (isLowRes) {
                console.log(`[LOW RES] ${w.title} (${w.category}): ${meta.width}x${meta.height}`);
                lowResCount++;
            } else {
                console.log(`[OK] ${w.title}: ${meta.width}x${meta.height}`);
            }
        } catch (e) {
            console.log(`[ERROR] ${w.title}: ${e.message}`);
        }
    }

    console.log(`\nAudit complete! ${lowResCount} low-res wallpapers found.`);
    process.exit();
}

auditResolutions();
