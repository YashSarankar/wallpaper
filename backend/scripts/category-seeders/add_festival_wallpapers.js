const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const festivalUrls = [
    'https://tse3.mm.bing.net/th/id/OIP.iyThJGxCICeadkXo_Z-jmAHaNG?w=725&h=1282&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.RfEa_eIoSR7rikayUXi2XAHaJ8?w=1000&h=1343&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://img.freepik.com/premium-photo/exploding-spectrum-create-vibrant-explosion-confetti-fireworks-multitude-colors_839035-774524.jpg',
    'https://images.stockcake.com/public/1/e/7/1e7ae40c-32a6-4258-a6bf-ba17bae4987f_large/fireworks-night-celebration-stockcake.jpg',
    'https://preview.redd.it/coronation-fireworks-x100f-v0-estar8llneya1.jpg?width=1080&crop=smart&auto=webp&s=e72d3eb3e45c5a4cadb283f1b559bec4bd42174f',
    'https://img.freepik.com/premium-photo/live-music-vibes-friends-dancing-concert_1280275-74885.jpg',
    'https://img.freepik.com/premium-photo/background-featuring-crowd-party-with-music-notes-mirrors-ai-generated-image_853163-14336.jpg',
    'https://img.freepik.com/premium-photo/umbrella-dance-neon-rain-vivid-celebration_145406-2906.jpg'
];

async function addFestivalWallpapers() {
    try {
        console.log('Connecting to MongoDB...');
        if (!process.env.MONGO_URI) {
            throw new Error('MONGO_URI is not defined in .env file');
        }
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Festival';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        const deleteResult = await Wallpaper.deleteMany({ category: category });
        console.log(`Deleted ${deleteResult.deletedCount} old wallpapers.`);

        const newWallpapers = festivalUrls.map((url, index) => ({
            title: `Festival Vibe ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new festival wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Festival category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating festival category:', error);
        process.exit(1);
    }
}

addFestivalWallpapers();
