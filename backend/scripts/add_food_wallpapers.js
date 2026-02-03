const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const foodUrls = [
    'https://img.freepik.com/premium-photo/delicious-burger_950428-6409.jpg',
    'https://wallpaper.dog/large/968946.jpg',
    'https://wallpaperaccess.com/full/3234876.jpg',
    'https://wallpaperaccess.com/full/4657576.jpg',
    'https://wallpaper.dog/large/10964262.jpg',
    'https://wallpaperaccess.com/full/4657578.jpg',
    'https://wallpaper.dog/large/10964533.jpg',
    'https://wallpapers.com/images/hd/purple-ball-fruits-3d-android-phone-4lofansgf1qhqpfq.jpg',
    'https://img.freepik.com/premium-photo/delicious-berger-floating-air-berger-food-professional-photography-studio-lighting-studio_630789-3513.jpg',
    'https://tse3.mm.bing.net/th/id/OIP.gsLxCC5hW5Tq02_2NAkyiAHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.dgOOCaCj2H1N3YuoZot8PAHaF7?w=1000&h=800&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapers.com/images/featured/android-food-background-kdlopyedptv050s7.jpg',
    'https://wallpapers.com/images/hd/apple-eating-android-usm8cbgi6vtqysjs.jpg'
];

async function addFoodWallpapers() {
    try {
        console.log('Connecting to MongoDB...');
        if (!process.env.MONGO_URI) {
            throw new Error('MONGO_URI is not defined in .env file');
        }
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Food';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        const deleteResult = await Wallpaper.deleteMany({ category: category });
        console.log(`Deleted ${deleteResult.deletedCount} old wallpapers.`);

        const newWallpapers = foodUrls.map((url, index) => ({
            title: `Gourmet ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new food wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Food category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating food category:', error);
        process.exit(1);
    }
}

addFoodWallpapers();
