const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const urls = [
    'https://tse4.mm.bing.net/th/id/OIP.oqvyOao_Doa9hERoBQulnAHaMX?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.sX_FAM5w13tCSTTLZ6zPPwHaNK?w=1440&h=2560&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapers.com/images/hd/3d-phone-magic-forest-swamp-ls5txmbeew2bbzgv.jpg',
    'https://tse2.mm.bing.net/th/id/OIP.wD7avNQeMpT4FrPxaz_amwHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.54mFYxN100kCYfKcHCoArwHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.6fQZSO2ueEimo5K3unM7vwHaJ4?w=768&h=1024&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.XmuWwr6BjA80mdU6IUekOwHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.JhGIsaZiZh-mMTkvkVeQZAHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapers.com/images/hd/fantasy-phone-800-x-1316-r6rdhk3onk0rjvto.jpg',
    'https://tse1.mm.bing.net/th/id/OIP.FqiMmSdwXh898n6cvzFnSQHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://w0.peakpx.com/wallpaper/231/356/HD-wallpaper-nature-3d-digital-drawings-fantasy-flowers-green-waterfall.jpg',
    'https://tse4.mm.bing.net/th/id/OIP.q8yxThQ4-5CCSCHcIjKrLQHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapers.com/images/hd/fantasy-phone-q90wybe57qmclo2o.jpg',
    'https://tse1.mm.bing.net/th/id/OIP.bUj3st_qXT7d_rUB7evFUwHaNK?w=720&h=1280&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.7lxqFp2NKvI98dhM9z5E_AHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://i.pinimg.com/736x/a3/e6/07/a3e60751ea07b9b1c1d5edb8c939a451.jpg',
    'https://tse3.mm.bing.net/th/id/OIP.nM6GZUQPL7jCoZorjtntDgHaJN?w=600&h=746&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://as2.ftcdn.net/v2/jpg/05/93/07/37/1000_F_593073739_09vdFJxWPGuCZ2IAWFF5NbA88lwksG58.jpg',
    'https://wallpapercat.com/w/full/b/0/1/71320-1125x2436-samsung-hd-dragon-wallpaper-image.jpg',
    'https://wallpaperaccess.com/full/4815483.jpg',
    'https://tse4.mm.bing.net/th/id/OIP.ACAuOCSmBAbvMRfjqfLaDwHaNK?w=1440&h=2560&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.ZYDw0S88bVoIHPaZTNscAAHaLH?w=506&h=760&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.JgM28UnvExaiDxaEgVJKZwHaPN?w=623&h=1280&rs=1&pid=ImgDetMain&o=7&rm=3'
];

async function updateCategory() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Fantasy';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        await Wallpaper.deleteMany({ category: category });

        const newWallpapers = urls.map((url, index) => ({
            title: `Fantasy Realm ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new fantasy wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Fantasy category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating fantasy category:', error);
        process.exit(1);
    }
}

updateCategory();
