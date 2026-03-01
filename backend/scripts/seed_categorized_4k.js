require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const axios = require('axios');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');
const { processAndUploadImage } = require('../services/imageService');

const newWallpapers = [
    { title: 'Daredevil Born Again', url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25777.jpg', category: 'Superhero' },
    { title: 'Shadow Eminence', url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25784.jpg', category: 'Anime' },
    { title: 'Iron Man Armor', url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25566.jpg', category: 'Superhero' },
    { title: 'Pink Abstract Flow', url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25734.jpg', category: 'Abstract' },
    { title: 'Solo Leveling Sung Jinwoo', url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25676.jpg', category: 'Anime' },
    { title: 'Kawasaki Ninja Duo', url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25771.jpeg', category: 'Cars & Bike' },
    { title: 'Ghostface Scream', url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25788.jpg', category: 'Movies' },
    { title: 'Astronaut Cosmos', url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25817.jpg', category: 'Nature' },
    { title: 'Goku Ultra Instinct', url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25716.jpg', category: 'Anime' },
    { title: 'Blue Pink Abstract', url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25736.png', category: 'Abstract' },
    { title: 'Neon Abstract Wave', url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25735.jpg', category: 'Abstract' },
    { title: 'Spider-Man Noir', url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25754.jpg', category: 'Superhero' },
    { title: 'Color Burst Abstract', url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25732.jpg', category: 'Abstract' },
    { title: 'Naruto & Sasuke Final', url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25590.jpg', category: 'Anime' },
    { title: 'Luffy Gear 5', url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25595.jpg', category: 'Anime' },
    { title: 'Lisa Blackpink', url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25547.jpg', category: 'Stock' }
];

async function seedCategorizedWallpapers() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected.');

        for (const item of newWallpapers) {
            console.log(`Processing: ${item.title} [${item.category}] from ${item.url}`);
            try {
                // Fetch image from URL with User-Agent to avoid blocks
                const response = await axios.get(item.url, {
                    responseType: 'arraybuffer',
                    headers: {
                        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                        'Referer': 'https://4kwallpapers.com/'
                    }
                });
                const buffer = Buffer.from(response.data);

                // Extract filename
                const originalName = path.basename(item.url.split('?')[0]);

                // Process and upload to GCS
                const uploadResult = await processAndUploadImage(buffer, originalName);

                // Save to MongoDB
                const newWallpaper = new Wallpaper({
                    title: item.title,
                    category: item.category,
                    imageUrl: {
                        original: uploadResult.original,
                        mid: uploadResult.mid,
                        low: uploadResult.low,
                        blurHash: uploadResult.blurHash
                    },
                    type: 'static'
                });

                await newWallpaper.save();
                console.log(`Successfully added: ${item.title}`);
            } catch (err) {
                console.error(`Failed to process ${item.title}: ${err.message}`);
                if (err.response) {
                    console.error(`Status: ${err.response.status}`);
                }
            }
        }

        console.log('Seeding completed!');
        process.exit(0);
    } catch (error) {
        console.error('Fatal Error:', error);
        process.exit(1);
    }
}

seedCategorizedWallpapers();
