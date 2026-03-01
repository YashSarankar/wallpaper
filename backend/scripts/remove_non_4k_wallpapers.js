require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const Wallpaper = require('../models/Wallpaper');
const { bucket } = require('../config/gcs');
const axios = require('axios');
const sharp = require('sharp');
const fs = require('fs');

async function removeNon4kWallpapers() {
    console.log('Connecting to database...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Targeting GCS Bucket:', process.env.GCS_BUCKET_NAME);

    // Fetch static wallpapers. Since some might not have 'type' explicitly saved,
    // we also include documents where 'videoUrl' does not exist.
    const wallpapers = await Wallpaper.find({
        $or: [
            { type: 'static' },
            { type: { $exists: false } },
            { type: null }
        ],
        videoUrl: { $exists: false }
    });

    console.log(`Found ${wallpapers.length} static wallpapers. Checking resolutions...`);

    let removedCount = 0;
    let keptCount = 0;
    let errorCount = 0;

    const extractGcsPath = (url) => {
        // e.g., "https://storage.googleapis.com/my-wallpaper-app-bucket/wallpapers/original/1770051810028-n1.jpg"
        // Needs "wallpapers/original/1770051810028-n1.jpg"
        if (!url) return null;
        const parts = url.split(`${process.env.GCS_BUCKET_NAME}/`);
        return parts.length > 1 ? parts[1] : null;
    };

    for (let i = 0; i < wallpapers.length; i++) {
        const w = wallpapers[i];
        try {
            const originalUrl = w.imageUrl.original;
            if (!originalUrl) continue;

            // Fetch the image to buffer to check metadata
            const res = await axios.get(originalUrl, { responseType: 'arraybuffer' });
            const metadata = await sharp(res.data).metadata();

            // 4K resolution check (allowing a small margin of error)
            // Typically 4K portrait is >=2160x3840
            const is4k = (metadata.width >= 2100 && metadata.height >= 3800) ||
                (metadata.height >= 2100 && metadata.width >= 3800);

            if (is4k) {
                console.log(`[KEEP] ${originalUrl.split('/').pop()} - ${metadata.width}x${metadata.height}`);
                keptCount++;
            } else {
                console.log(`[DELETE] ${originalUrl.split('/').pop()} - ${metadata.width}x${metadata.height}`);

                // Delete the image files from GCS
                const gcsUrls = [w.imageUrl.original, w.imageUrl.mid, w.imageUrl.low];
                for (let url of gcsUrls) {
                    const filePath = extractGcsPath(url);
                    if (filePath) {
                        try {
                            await bucket.file(filePath).delete();
                            console.log(`  -> Deleted from GCS: ${filePath}`);
                        } catch (gcsErr) {
                            if (gcsErr.code !== 404) {
                                console.error(`  -> Failed to delete from GCS: ${filePath}`, gcsErr.message);
                            }
                        }
                    }
                }

                // Delete the record from the database
                await Wallpaper.deleteOne({ _id: w._id });
                removedCount++;
            }
        } catch (e) {
            console.error(`[ERROR] Processing ${w._id}: ${e.message}`);
            errorCount++;
        }
    }

    console.log('--- SUMMARY ---');
    console.log(`Total checked: ${wallpapers.length}`);
    console.log(`Kept 4K Wallpapers: ${keptCount}`);
    console.log(`Removed Non-4K Wallpapers: ${removedCount}`);
    console.log(`Skipped due to error: ${errorCount}`);

    process.exit();
}

removeNon4kWallpapers().catch(err => {
    console.error('Fatal Script Error:', err);
    process.exit(1);
});
