const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const urls = [
    'https://tse2.mm.bing.net/th/id/OIP.h58rEM5i3K8gFmkAau8_nAHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.hhN43pJkuQ4UHsppZeRp1AHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpaperbat.com/img/8640404-positive-wallpaper-for-mobile-phone.jpg',
    'https://img.lovepik.com/background/20211101/medium/lovepik-text-mobile-phone-wallpaper-background-image_400594158.jpg',
    'https://img.lovepik.com/background/20211030/medium/lovepik-text-phone-wallpaper-background-image_400469432.jpg',
    'https://wallpapers.com/images/hd/gamer-text-art-qs1emwma7ddzeftv.jpg',
    'https://wallpaperbat.com/img/9738293-black-text-iphone-wallpaper.jpg',
    'https://wallpaper.dog/large/20512441.jpg',
    'https://img.lovepik.com/background/20211030/medium/lovepik-text-mobile-phone-wallpaper-background-image_400378547.jpg',
    'https://wallpaper.dog/large/20512382.jpg',
    'https://tse3.mm.bing.net/th/id/OIP.OF_kO4O9mVMynYFXIdwJhQHaQC?w=1205&h=2610&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.TTFZy-tmB0rzS8kNiIUDhAHaFj?w=5464&h=4096&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapercave.com/wp/wp4000016.jpg',
    'https://wallpapers.com/images/hd/locked-text-wruhqs1pv9g776rh.jpg',
    'https://img.lovepik.com/background/20211101/medium/lovepik-text-mobile-phone-wallpaper-background-image_400560338.jpg',
    'https://wallpaperaccess.com/full/6285362.jpg',
    'https://tse1.mm.bing.net/th/id/OIP.31AGbEOYaVRXWmFtDX-VOgHaFj?w=5464&h=4096&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.U--m8cE4-puDYYhhTTS4JwHaNK?w=1440&h=2560&rs=1&pid=ImgDetMain&o=7&rm=3'
];

async function updateCategory() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Text';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        await Wallpaper.deleteMany({ category: category });

        const newWallpapers = urls.map((url, index) => ({
            title: `Typography ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new text wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Text category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating text category:', error);
        process.exit(1);
    }
}

updateCategory();
