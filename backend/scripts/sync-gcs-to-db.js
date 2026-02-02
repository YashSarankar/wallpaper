const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
const { bucket } = require('../config/gcs');
const Wallpaper = require('../models/Wallpaper');

async function syncGcsToDb() {
    try {
        console.log('Connecting to MongoDB...');
        // Match the user's new cluster and db name
        const MONGO_URI = process.env.MONGO_URI;

        await mongoose.connect(MONGO_URI);
        console.log('Connected to MongoDB.');

        console.log(`Scanning GCS Bucket: ${bucket.name}...`);
        const [files] = await bucket.getFiles({ prefix: 'wallpapers/original/' });

        console.log(`Found ${files.length} files in wallpapers/original/`);

        let addedCount = 0;
        let skippedCount = 0;

        for (const file of files) {
            if (file.name.endsWith('/')) continue; // Skip folders

            const fileName = file.name.split('/').pop();
            const originalUrl = `https://storage.googleapis.com/${bucket.name}/${file.name}`;

            // Check if this image (by original URL) already exists in DB
            const exists = await Wallpaper.findOne({ 'imageUrl.original': originalUrl });

            if (exists) {
                skippedCount++;
                continue;
            }

            // Create new entry
            const nameOnly = fileName.replace('.jpg', '').replace('.jpeg', '').split('-').pop();

            const newWallpaper = new Wallpaper({
                title: nameOnly || 'Imported Wallpaper',
                category: 'Imported', // You can change this later in admin panel
                imageUrl: {
                    original: originalUrl,
                    mid: originalUrl.replace('/original/', '/mid/'),
                    low: originalUrl.replace('/original/', '/low/')
                }
            });

            await newWallpaper.save();
            console.log(`Added: ${fileName}`);
            addedCount++;
        }

        console.log('---------------------------');
        console.log(`Sync Complete!`);
        console.log(`Added to DB: ${addedCount}`);
        console.log(`Already in DB: ${skippedCount}`);
        console.log('---------------------------');

        process.exit(0);
    } catch (err) {
        console.error('Sync failed:', err);
        process.exit(1);
    }
}

syncGcsToDb();
