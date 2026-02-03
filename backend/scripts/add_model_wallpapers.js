const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const modelUrls = [
    'https://www.pixelstalk.net/wp-content/uploads/images6/3D-Phone-Wallpaper-HD-Free-download.jpg',
    'https://wallpapercave.com/wp/wp7128873.jpg',
    'https://tse1.mm.bing.net/th/id/OIP.dejd9buzs81A9lcUqkx6hQHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.145oQXUlxgYLkCSXEmbQFAAAAA?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpaperaccess.com/full/3025032.jpg',
    'https://wallpapers.com/images/hd/textured-white-object-mobile-3d-f2jj4ipg6hw1wple.jpg',
    'https://www.pixelstalk.net/wp-content/uploads/images6/New-3D-Background-For-Mobile.jpg',
    'https://tse4.mm.bing.net/th/id/OIP.z4DAUnr-9F7gdowhOfY0TAHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://img.freepik.com/free-photo/modern-smartphone-with-live-abstract-wallpaper-coming-out-screen_23-2151033607.jpg',
    'https://tse2.mm.bing.net/th/id/OIP.tofA1EL9a8Ojc34VVgWHCQHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapercave.com/wp/wp2662085.jpg',
    'https://wallpapers.com/images/hd/3d-phone-pink-purple-bubbles-6xqqgold8utezuuh.jpg'
];

async function addModelWallpapers() {
    try {
        console.log('Connecting to MongoDB...');
        if (!process.env.MONGO_URI) {
            throw new Error('MONGO_URI is not defined in .env file');
        }
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Model';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        const deleteResult = await Wallpaper.deleteMany({ category: category });
        console.log(`Deleted ${deleteResult.deletedCount} old wallpapers.`);

        const newWallpapers = modelUrls.map((url, index) => ({
            title: `Model 3D ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new model wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Model category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating model category:', error);
        process.exit(1);
    }
}

addModelWallpapers();
