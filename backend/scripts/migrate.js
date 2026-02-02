const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');
const axios = require('axios');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

const Wallpaper = require('../models/Wallpaper');
const { processAndUploadImage } = require('../services/imageService');

const MIGRATION_FILE = path.join(__dirname, '../../assets/wallpapers.json');

async function migrate() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected.');

        const rawData = fs.readFileSync(MIGRATION_FILE, 'utf8');
        const data = JSON.parse(rawData);

        for (const category of data.categories) {
            console.log(`Processing category: ${category.name}`);
            for (const wp of category.wallpapers) {
                // Check if already exists by original URL (optional)
                const exists = await Wallpaper.findOne({ 'imageUrl.original': { $regex: wp.url.split('?')[0] } });
                if (exists) {
                    console.log(`Skipping existing wallpaper: ${wp.id}`);
                    continue;
                }

                try {
                    console.log(`Downloading ${wp.id}: ${wp.url}`);
                    const response = await axios.get(wp.url, { responseType: 'arraybuffer' });
                    const buffer = Buffer.from(response.data, 'binary');

                    console.log(`Processing and uploading to GCS...`);
                    const imageUrls = await processAndUploadImage(buffer, `${wp.id}.jpg`);

                    const newWallpaper = new Wallpaper({
                        title: wp.id,
                        category: category.name,
                        imageUrl: imageUrls
                    });

                    await newWallpaper.save();
                    console.log(`Saved ${wp.id} successfully.`);
                } catch (err) {
                    console.error(`Failed to process ${wp.id}: ${err.message}`);
                }
            }
        }

        console.log('Migration complete.');
        process.exit(0);
    } catch (err) {
        console.error('Migration failed:', err);
        process.exit(1);
    }
}

migrate();
