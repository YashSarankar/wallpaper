const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const romanticUrls = [
    'https://w0.peakpx.com/wallpaper/173/895/HD-wallpaper-hearts-animation-animated-heart-love.jpg',
    'https://tse1.mm.bing.net/th/id/OIP.kVSZuK3rH-oiMBtj45eZEQHaPN?w=623&h=1280&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.jDWWISwzb_CXv_ugV3nZQgHaNK?w=1440&h=2560&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.CBf2EAIF36uPcJKSq4ZWrAHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.pf4ECB6XdApYX39k3C8nVwAAAA?w=340&h=550&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.vFxnWWTIHUVA8rh8UaPVoAHaQC?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://i.pinimg.com/736x/b5/1c/82/b51c829e1d8e1f567caf43bb7e443caa.jpg',
    'https://tse3.mm.bing.net/th/id/OIP.AoYSgUtsUvzzUXt4RLu1fAAAAA?w=453&h=489&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://img.freepik.com/premium-photo/digital-art-valentines-day-scene-with-couple-love-dia-dos-namorados_932604-938.jpg',
    'https://wallpapercave.com/wp/wp12050954.jpg',
    'https://tse4.mm.bing.net/th/id/OIP.zOFMEALnEwmoJXJ3Jm_nwgHaJQ?w=1080&h=1350&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapers.com/images/hd/animated-phone-9rardhlpj2ox2n0x.jpg',
    'https://w0.peakpx.com/wallpaper/210/1005/HD-wallpaper-eternal-love-romantic-kiss-couple-in-love-i-love-you-i-love-u.jpg',
    'https://tse2.mm.bing.net/th/id/OIP.5mYUUGgycjU7GoPsao0KywHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.explicit.bing.net/th/id/OIP.FFC8R5cngCRvu28fzl9QcAHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://i.pinimg.com/736x/ae/e4/07/aee40704360efbec30198d9ea8a66e14.jpg',
    'https://tse4.mm.bing.net/th/id/OIP.15lhRzeHYPD4d7xo2iQHvgHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://w0.peakpx.com/wallpaper/229/701/HD-wallpaper-love-couple-animated-anime-beautiful-romantic-rose-sweet.jpg'
];

async function addRomanticWallpapers() {
    try {
        console.log('Connecting to MongoDB...');
        if (!process.env.MONGO_URI) {
            throw new Error('MONGO_URI is not defined in .env file');
        }
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Romantic Vibe';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        const deleteResult = await Wallpaper.deleteMany({ category: category });
        console.log(`Deleted ${deleteResult.deletedCount} old wallpapers.`);

        const newWallpapers = romanticUrls.map((url, index) => ({
            title: `Eternal Love ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new romantic wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Romantic Vibe category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating romantic category:', error);
        process.exit(1);
    }
}

addRomanticWallpapers();
