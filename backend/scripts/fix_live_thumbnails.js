const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');
const axios = require('axios');
const dotenv = require('dotenv');
const ffmpegPath = require('ffmpeg-static');
const ffmpeg = require('fluent-ffmpeg');
const Wallpaper = require('../models/Wallpaper');
const { processAndUploadImage } = require('../services/imageService');

// Set ffmpeg path
ffmpeg.setFfmpegPath(ffmpegPath);

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });

const TMP_PATH = path.join(__dirname, '../tmp');

// Ensure tmp directory exists
if (!fs.existsSync(TMP_PATH)) {
    fs.mkdirSync(TMP_PATH, { recursive: true });
}

async function downloadVideo(url, targetPath) {
    const writer = fs.createWriteStream(targetPath);
    const response = await axios({
        url,
        method: 'GET',
        responseType: 'stream'
    });

    response.data.pipe(writer);

    return new Promise((resolve, reject) => {
        writer.on('finish', resolve);
        writer.on('error', reject);
    });
}

async function generateThumbnail(videoPath, thumbnailName) {
    return new Promise((resolve, reject) => {
        ffmpeg(videoPath)
            .screenshots({
                timestamps: [2], // Take screenshot at 2 seconds
                filename: thumbnailName,
                folder: TMP_PATH,
                size: '1080x?'
            })
            .on('end', () => {
                resolve(path.join(TMP_PATH, thumbnailName));
            })
            .on('error', (err) => {
                reject(err);
            });
    });
}

async function fixThumbnails() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected.');

        const query = {
            type: 'animated',
            'imageUrl.original': /placehold/
        };

        const wallpapers = await Wallpaper.find(query);
        console.log(`Found ${wallpapers.length} wallpapers needing thumbnails.`);

        for (const wallpaper of wallpapers) {
            try {
                console.log(`\nProcessing: ${wallpaper.title}...`);

                if (!wallpaper.videoUrl) {
                    console.error(`Skipping ${wallpaper.title}: No video URL.`);
                    continue;
                }

                const videoExt = path.extname(wallpaper.videoUrl.split('?')[0]) || '.mp4';
                const tempVideoPath = path.join(TMP_PATH, `temp-${wallpaper._id}${videoExt}`);
                const thumbnailFilename = `thumb-${wallpaper._id}.jpg`;

                // 1. Download video
                console.log('Downloading video...');
                await downloadVideo(wallpaper.videoUrl, tempVideoPath);

                // 2. Generate Thumbnail
                console.log('Generating thumbnail...');
                const thumbPath = await generateThumbnail(tempVideoPath, thumbnailFilename);
                const thumbBuffer = fs.readFileSync(thumbPath);

                // 3. Process and upload
                console.log('Uploading thumbnail sizes...');
                const imageUrls = await processAndUploadImage(thumbBuffer, thumbnailFilename);

                // 4. Update DB
                wallpaper.imageUrl = imageUrls;
                await wallpaper.save();

                console.log(`Successfully updated: ${wallpaper.title}`);

                // Cleanup
                fs.unlinkSync(tempVideoPath);
                fs.unlinkSync(thumbPath);

            } catch (err) {
                console.error(`Failed to process ${wallpaper.title}:`, err.message);
            }
        }

        console.log('\nAll thumbnails updated successfully.');
        process.exit(0);
    } catch (error) {
        console.error('Error:', error);
        process.exit(1);
    }
}

fixThumbnails();
