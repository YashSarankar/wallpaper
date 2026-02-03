const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const blackUrls = [
    'https://i.pinimg.com/736x/7d/9e/d0/7d9ed06aaf80c07dd6743ef98e204847.jpg',
    'https://wallpaperaccess.com/full/824083.jpg',
    'https://tse3.mm.bing.net/th/id/OIP.12YmTfZERHZ3a1w966-tswHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpaper-mania.com/wp-content/uploads/2018/09/High_resolution_wallpaper_background_ID_77701765953.jpg',
    'https://tse3.mm.bing.net/th/id/OIP.gZIW9wEDOkBtChHW4XKpjgHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpaperaccess.com/full/4665834.png',
    'https://wallpaperaccess.com/full/1194544.jpg',
    'https://wallpapers.com/images/hd/black-and-white-iphone-horizon-wai4jdu3gim4ebyy.jpg',
    'https://wallpapers.com/images/hd/black-and-white-patterns-iphone-2021-cef0bqhxmu26jlgj.jpg',
    'https://wallpapercave.com/wp/wp6532867.jpg',
    'https://th.bing.com/th/id/R.8f44f62d6d9ea592addf95224fd16abd?rik=vXW%2fsgFIScgy5Q&riu=http%3a%2f%2fcdn.wallpapersafari.com%2f32%2f96%2fad15Kf.jpg&ehk=ioZJ4yMaPkNrJguiN%2b80LZpJSXpjQY4m3ck7ik4FU9E%3d&risl=&pid=ImgRaw&r=0',
    'https://tse3.mm.bing.net/th/id/OIP.Y2_gK_TuAwAaCwKkzuqEhAHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapercave.com/wp/wp12603943.jpg',
    'https://tse4.mm.bing.net/th/id/OIP.Ydy7to4eI2Ex9SnFU9D0qwHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://3.bp.blogspot.com/-DSHgsxeS3u8/VlG35Wh4LPI/AAAAAAAAAf0/vWTBELUQnNc/s1600/black%2Biphone%2B6%2Bhd%2Bwallpapers%2Bfree%2Bdownload%2B6.jpg',
    'https://cdn.wallpapersafari.com/89/45/HtS4Lu.jpg',
    'https://tse4.mm.bing.net/th/id/OIP.kAejPxDRvfLufYckDwB7rwHaNL?w=750&h=1334&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://cdn.wallpapersafari.com/15/7/XVvOib.jpg',
    'https://wallpapers.com/images/hd/full-moon-on-black-iphone-6-plus-9i8dsfch4anwttxx.jpg',
    'https://tse3.mm.bing.net/th/id/OIP.R9hcOf-iV1bK0dWuANIWGQHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.a8jSp9nYiidpoRcV7t6QEgHaNK?w=918&h=1632&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.zpKFcx1IsCUz6rLR_RDlHAHaNK?w=1242&h=2208&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.jCkaBmGl4diNk7Z-RQKQJQHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapers.com/images/featured/black-iphone-6-plus-deaiy3sam24tbqux.jpg'
];

async function addBlackWallpapers() {
    try {
        console.log('Connecting to MongoDB...');
        if (!process.env.MONGO_URI) {
            throw new Error('MONGO_URI is not defined in .env file');
        }
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Black';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        const deleteResult = await Wallpaper.deleteMany({ category: category });
        console.log(`Deleted ${deleteResult.deletedCount} old wallpapers.`);

        const newWallpapers = blackUrls.map((url, index) => ({
            title: `Pure Black ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new black wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Black category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating black category:', error);
        process.exit(1);
    }
}

addBlackWallpapers();
