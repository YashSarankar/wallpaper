const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const categories = [
    'Amoled',
    'Nature',
    'Stock',
    'Black',
    'Cars & Bike',
    'Model',
    'Fitness',
    'God',
    'Festival',
    'Abstract',
    'Anime',
    'Romantic Vibe',
    'Fantasy',
    'Top Wallpaper',
    'Superhero',
    'Travel',
    'Movies',
    'Food',
    'Text',
    'Game'
];

async function seedDatabase() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const seedWallpapers = [];

        for (const category of categories) {
            console.log(`Generating 10 images for category: ${category}...`);
            for (let i = 1; i <= 10; i++) {
                // We use keyword-based placeholder services to get diverse images
                // lorempixel, loremflickr, or unsplash source can work.
                // Using loremflickr with a lock ensures unique but consistent images during a single run.
                const keyword = category.toLowerCase().replace('&', '').replace(' ', ',');
                const baseUrl = `https://loremflickr.com/1080/1920/${keyword}?lock=${i}`;

                seedWallpapers.push({
                    title: `${category} Premium ${i}`,
                    category: category,
                    imageUrl: {
                        original: baseUrl,
                        mid: baseUrl, // In a real app these would be pre-resized
                        low: baseUrl
                    },
                    createdAt: new Date(Date.now() - Math.floor(Math.random() * 1000000000)) // Random past dates for better sorting
                });
            }
        }

        console.log(`Inserting ${seedWallpapers.length} wallpapers into database...`);
        // We delete existing only if you want a clean start, but user asked to ADD.
        // Let's just add them.
        await Wallpaper.insertMany(seedWallpapers);

        console.log('Successfully seeded database with 10 images per category!');
        process.exit(0);
    } catch (error) {
        console.error('Error seeding database:', error);
        process.exit(1);
    }
}

seedDatabase();
