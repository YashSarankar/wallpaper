const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');
const ffmpegPath = require('ffmpeg-static');
const ffmpeg = require('fluent-ffmpeg');
const Wallpaper = require('../models/Wallpaper');
const { uploadVideo, processAndUploadImage } = require('../services/imageService');

// Set ffmpeg path
ffmpeg.setFfmpegPath(ffmpegPath);

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });

const ASSETS_PATH = path.join(__dirname, '../../assets');
const TMP_PATH = path.join(__dirname, '../tmp');

// Ensure tmp directory exists
if (!fs.existsSync(TMP_PATH)) {
    fs.mkdirSync(TMP_PATH, { recursive: true });
}

async function generateThumbnail(videoPath, thumbnailName) {
    return new Promise((resolve, reject) => {
        ffmpeg(videoPath)
            .screenshots({
                timestamps: [2], // Take screenshot at 2 seconds
                filename: thumbnailName,
                folder: TMP_PATH,
                size: '1080x?' // Set width to 1080, maintain aspect ratio
            })
            .on('end', () => {
                resolve(path.join(TMP_PATH, thumbnailName));
            })
            .on('error', (err) => {
                reject(err);
            });
    });
}

async function seedLiveWallpapers() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected.');

        const files = fs.readdirSync(ASSETS_PATH);
        const videoFiles = files.filter(f => f.endsWith('.mp4'));

        console.log(`Found ${videoFiles.length} video files.`);

        for (const filename of videoFiles) {
            try {
                // Generate a clean title from filename
                const title = filename
                    .split('.')[0]
                    .split('-')
                    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
                    .join(' ');

                console.log(`\nProcessing: ${title}...`);

                // 1. Read the video file and upload to GCS
                const filePath = path.join(ASSETS_PATH, filename);
                const buffer = fs.readFileSync(filePath);

                console.log('Uploading video to Google Cloud Storage...');
                const videoUrl = await uploadVideo(buffer, filename, 'video/mp4');
                console.log(`Video URL: ${videoUrl}`);

                // 2. Generate Thumbnail from video
                console.log('Generating thumbnail from video...');
                const thumbnailFilename = `${path.parse(filename).name}-thumb.jpg`;
                const thumbPath = await generateThumbnail(filePath, thumbnailFilename);
                const thumbBuffer = fs.readFileSync(thumbPath);

                // 3. Process and upload thumbnail in different sizes
                console.log('Uploading thumbnail sizes to GCS...');
                const imageUrls = await processAndUploadImage(thumbBuffer, thumbnailFilename);

                // Cleanup temp thumbnail
                fs.unlinkSync(thumbPath);

                // 4. Determine category
                let category = 'Abstract'; // Default
                if (filename.includes('bmw') || filename.includes('drive') || filename.includes('toyota')) {
                    category = 'Cars & Bike';
                } else if (filename.includes('luffy') || filename.includes('zenitsu') || filename.includes('gojo') || filename.includes('goku') || filename.includes('vegeta')) {
                    category = 'Anime';
                } else if (filename.includes('movie') || filename.includes('john-wick') || filename.includes('kylo-ren') || filename.includes('stranger-things')) {
                    category = 'Movies';
                } else if (filename.includes('nature') || filename.includes('forest') || filename.includes('desert') || filename.includes('islands')) {
                    category = 'Nature';
                }

                // 5. Save to MongoDB
                const newWallpaper = new Wallpaper({
                    title: title,
                    category: category,
                    type: 'animated',
                    videoUrl: videoUrl,
                    imageUrl: imageUrls,
                    createdAt: new Date()
                });

                await newWallpaper.save();
                console.log(`Successfully added to DB: ${title}`);
            } catch (err) {
                console.error(`Failed to process ${filename}:`, err.message);
            }
        }

        console.log('\nAll live wallpapers seeded successfully.');
        process.exit(0);
    } catch (error) {
        console.error('Connection Error:', error);
        process.exit(1);
    }
}

seedLiveWallpapers();
