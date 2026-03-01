require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const axios = require('axios');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');
const { processAndUploadImage } = require('../services/imageService');

const abstractWallpapers = [
    { title: 'Abstract 1', url: 'https://wallpaperaccess.com/full/1234567.jpg' },
    { title: 'Abstract 2', url: 'https://images.unsplash.com/abstract-amoled-4k-dark.jpg' },
    { title: 'Abstract 3', url: 'https://wallpapers.com/amoled-swirls-4k.jpg' },
    { title: 'Abstract 4', url: 'https://hdqwalls.com/dark-abstract-8k.jpg' },
    { title: 'Abstract 5', url: 'https://4kwallpapers.com/black-blue-4k-vertical.jpg' },
    { title: 'Vibrant Geometric 1', url: 'https://wallpaperaccess.com/geometric-abstract-4k-android.jpg' },
    { title: 'Vibrant Geometric 2', url: 'https://images.pexels.com/abstract-geo-8k-vertical.jpg' },
    { title: 'Vibrant Geometric 3', url: 'https://wallpapers.com/color-metal-4k.jpg' },
    { title: 'Vibrant Geometric 4', url: 'https://hdqwalls.com/red-blue-circuit-4k.jpg' },
    { title: 'Vibrant Geometric 5', url: 'https://4kwallpapers.com/polygonal-abstract-5k.jpg' },
    { title: 'Fluid 1', url: 'https://wallpaperaccess.com/fluid-art-4k.jpg' },
    { title: 'Fluid 2', url: 'https://images.unsplash.com/blue-liquid-4k-mobile.jpg' },
    { title: 'Fluid 3', url: 'https://wallpapers.com/purple-swirl-liquid-8k.jpg' },
    { title: 'Fluid 4', url: 'https://hdqwalls.com/teal-fluid-waves-4k.jpg' },
    { title: 'Fluid 5', url: 'https://4kwallpapers.com/metallic-waves-4k-android.jpg' },
    { title: 'Neon 1', url: 'https://wallpaperaccess.com/neon-glow-4k-amoled.jpg' },
    { title: 'Neon 2', url: 'https://images.pexels.com/rainbow-gradient-vertical-4k.jpg' },
    { title: 'Neon 3', url: 'https://wallpapers.com/pink-amoled-swirls-4k.jpg' },
    { title: 'Neon 4', url: 'https://hdqwalls.com/glossy-purple-4k.jpg' },
    { title: 'Neon 5', url: 'https://4kwallpapers.com/neon-pink-circle-8k.jpg' },
    { title: 'Colorful Paint 1', url: 'https://wallpaperaccess.com/paint-strands-4k.jpg' },
    { title: 'Colorful Paint 2', url: 'https://images.unsplash.com/minimalist-gradient-4k-vertical.jpg' },
    { title: 'Colorful Paint 3', url: 'https://wallpapers.com/vibrant-fluid-5k.jpg' },
    { title: 'Colorful Paint 4', url: 'https://hdqwalls.com/colorful-waves-4k-android.jpg' },
    { title: 'Colorful Paint 5', url: 'https://4kwallpapers.com/orange-streaks-4k.jpg' },
    { title: 'Bonus 1', url: 'https://wallpaperaccess.com/glossy-abstract-4k.jpg' },
    { title: 'Bonus 2', url: 'https://images.pexels.com/geometric-cubes-4k.jpg' },
    { title: 'Bonus 3', url: 'https://wallpapers.com/blue-red-angular-4k.jpg' },
    { title: 'Bonus 4', url: 'https://hdqwalls.com/colorful-shapes-gradient-4k.jpg' },
    { title: 'Bonus 5', url: 'https://4kwallpapers.com/paint-shapes-8k-vertical.jpg' }
];

async function seedAbstract4K() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected.');

        const category = 'Abstract';

        for (const item of abstractWallpapers) {
            console.log(`Processing: ${item.title} from ${item.url}`);
            try {
                // Fetch image from URL
                const response = await axios.get(item.url, { responseType: 'arraybuffer' });
                const buffer = Buffer.from(response.data);

                // Extract filename for originalName
                const originalName = path.basename(item.url.split('?')[0]);

                // Process and upload to GCS (generates original, mid, low, blurHash)
                const uploadResult = await processAndUploadImage(buffer, originalName);

                // Save to MongoDB
                const newWallpaper = new Wallpaper({
                    title: item.title,
                    category: category,
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
            }
        }

        console.log('Seeding completed!');
        process.exit(0);
    } catch (error) {
        console.error('Fatal Error:', error);
        process.exit(1);
    }
}

seedAbstract4K();
