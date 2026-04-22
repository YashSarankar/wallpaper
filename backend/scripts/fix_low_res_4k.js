require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const axios = require('axios');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');
const { processAndUploadImage } = require('../services/imageService');
const { bucket } = require('../config/gcs');

const new4kUrls = [
    { "id": "25777", "url": "https://4kwallpapers.com/images/wallpapers/itachi-uchiha-moon-3840x2160-25777.jpg", "title": "Itachi Uchiha Moon", "category": "Anime" },
    { "id": "25784", "url": "https://4kwallpapers.com/images/wallpapers/mv-agusta-rush-3840x2160-25784.jpg", "title": "MV Agusta Rush", "category": "Cars & Bike" },
    { "id": "25566", "url": "https://4kwallpapers.com/images/wallpapers/daredevil-born-3840x2160-25566.jpg", "title": "Daredevil Born Again", "category": "Superhero" },
    { "id": "25734", "url": "https://4kwallpapers.com/images/wallpapers/samsung-galaxy-tab-3840x2160-25734.jpg", "title": "Samsung Galaxy Tab", "category": "Abstract" },
    { "id": "25676", "url": "https://4kwallpapers.com/images/wallpapers/apple-ramadan-5k-3840x2160-25676.jpg", "title": "Apple Ramadan", "category": "Anime" },
    { "id": "25771", "url": "https://4kwallpapers.com/images/wallpapers/novitec-ferrari-3840x2160-25771.jpg", "title": "Novitec Ferrari", "category": "Cars & Bike" },
    { "id": "25788", "url": "https://4kwallpapers.com/images/wallpapers/scream-7-ghostface-3840x2160-25788.jpg", "title": "Scream 7 Ghostface", "category": "Movies" },
    { "id": "25817", "url": "https://4kwallpapers.com/images/wallpapers/project-hail-mary-3840x2160-25817.jpg", "title": "Project Hail Mary", "category": "Nature" },
    { "id": "25716", "url": "https://4kwallpapers.com/images/wallpapers/battlefield-6-3840x2160-25716.jpg", "title": "Battlefield 6", "category": "Anime" },
    { "id": "25736", "url": "https://4kwallpapers.com/images/wallpapers/marumofubiyori-3840x2160-25736.jpg", "title": "Marumofubiyori", "category": "Abstract" },
    { "id": "25735", "url": "https://4kwallpapers.com/images/wallpapers/ben-reilly-spider-3840x2160-25735.jpg", "title": "Ben Reilly Spider-Man", "category": "Superhero" },
    { "id": "25754", "url": "https://4kwallpapers.com/images/wallpapers/jennifer-pierce-3840x2160-25754.jpg", "title": "Jennifer Pierce", "category": "Superhero" },
    { "id": "25732", "url": "https://4kwallpapers.com/images/wallpapers/one-piece-live-action-3840x2160-25732.jpg", "title": "One Piece Live Action", "category": "Anime" },
    { "id": "25590", "url": "https://4kwallpapers.com/images/wallpapers/toy-story-5-3840x2160-25590.jpg", "title": "Toy Story 5", "category": "Movies" },
    { "id": "25595", "url": "https://4kwallpapers.com/images/wallpapers/lisa-blackpink-3840x2160-25595.jpg", "title": "Lisa Blackpink", "category": "Stock" },
    { "id": "25547", "url": "https://4kwallpapers.com/images/wallpapers/battlefield-6-3840x2160-25547.jpg", "title": "Battlefield 6 Alternate", "category": "Anime" }
];

async function fixLowResWallpapers() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected.');

        for (const item of new4kUrls) {
            console.log(`\n--- Fixing: ${item.title} ---`);

            // 1. Delete old metadata and GCS files if they exist
            // (We'll look for existing ones by ID suffix or title)
            const existing = await Wallpaper.find({
                $or: [
                    { title: new RegExp(item.title, 'i') },
                    { 'imageUrl.original': new RegExp(item.id, 'i') }
                ]
            });

            for (const doc of existing) {
                console.log(`Deleting existing doc: ${doc._id} (${doc.title})`);
                try {
                    // Try to delete from GCS
                    const urlsToDelete = [doc.imageUrl.original, doc.imageUrl.high, doc.imageUrl.mid, doc.imageUrl.low].filter(Boolean);
                    for (const url of urlsToDelete) {
                        const filePath = url.split(bucket.name + '/')[1];
                        if (filePath) {
                            await bucket.file(filePath).delete().catch(() => { });
                        }
                    }
                } catch (e) {
                    console.log(`GCS deletion failed for ${doc._id}, skipping files...`);
                }
                await Wallpaper.deleteOne({ _id: doc._id });
            }

            // 2. Download and process the TRUE 4K version
            console.log(`Downloading TRUE 4K: ${item.url}`);
            try {
                const response = await axios.get(item.url, {
                    responseType: 'arraybuffer',
                    headers: {
                        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                        'Referer': 'https://4kwallpapers.com/'
                    }
                });
                const buffer = Buffer.from(response.data);
                const originalName = `${item.id}_true_4k.jpg`;

                const uploadResult = await processAndUploadImage(buffer, originalName);

                const newWallpaper = new Wallpaper({
                    title: item.title,
                    category: item.category,
                    imageUrl: {
                        original: uploadResult.original,
                        high: uploadResult.high,
                        mid: uploadResult.mid,
                        low: uploadResult.low,
                        blurHash: uploadResult.blurHash
                    },
                    type: 'static'
                });

                await newWallpaper.save();
                console.log(`Successfully added TRUE 4K: ${item.title}`);
            } catch (err) {
                console.error(`Failed to process ${item.title}: ${err.message}`);
            }
        }

        console.log('\nFixing completed!');
        process.exit(0);
    } catch (error) {
        console.error('Fatal Error:', error);
        process.exit(1);
    }
}

fixLowResWallpapers();
