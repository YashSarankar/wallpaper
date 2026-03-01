require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const Wallpaper = require('../models/Wallpaper');
const { bucket } = require('../config/gcs');
const axios = require('axios');
const sharp = require('sharp');
const fs = require('fs');

async function checkSizes() {
    console.log('Starting...');
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected to mongo');
        const wallpapers = await Wallpaper.find({ type: 'static' }).limit(5);
        console.log('Found wallpapers:', wallpapers.length);
        let out = '';
        for (let w of wallpapers) {
            try {
                const res = await axios.get(w.imageUrl.original, { responseType: 'arraybuffer' });
                const metadata = await sharp(res.data).metadata();
                out += `${w._id} ${metadata.width} x ${metadata.height}\n`;
                console.log(w._id, metadata.width, metadata.height);
            } catch (e) {
                out += `Error ${w._id}\n`;
                console.log('error', w._id, e.message);
            }
        }
        fs.writeFileSync('sizes_out.txt', out);
        console.log('Done');
    } catch (err) {
        console.log('error globally', err);
        fs.writeFileSync('sizes_out.txt', 'Error connecting: ' + err.message);
    }
    process.exit();
}

checkSizes();
