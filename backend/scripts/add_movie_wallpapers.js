const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const movieUrls = [
    'https://tse3.mm.bing.net/th/id/OIP.tHGXK7LMFkwed6fLRpGnSAHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpaperaccess.com/full/11866527.jpg',
    'https://wallpaperaccess.com/full/11866715.jpg',
    'https://wallpaperaccess.com/full/11866717.jpg',
    'https://tse2.mm.bing.net/th/id/OIP.wwBbIgn_-krcCNO7beAH-AHaNK?w=950&h=1689&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.DGxvi0W9DmpPEpFJ8A0M4gHaFj?w=1920&h=1440&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.n9BdlSlpw_OKg-po2e-g-AHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://3dandroidwallpaper.com/wp-content/uploads/2018/01/Animated-Movies-Android-Wallpaper-HD.jpg',
    'https://tse4.mm.bing.net/th/id/OIP.fUcTdzlRU2ZrlJkB-W-2KgHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapers.com/images/hd/neon-colorful-spiral-3d-android-phone-glcxib6z5behjh59.jpg',
    'https://wallpapers.com/images/hd/red-reflecting-ball-3d-android-phone-7jc0usemtzbsut77.jpg',
    'https://wallpapershome.com/images/pages/pic_v/25994.jpg',
    'https://tse3.mm.bing.net/th/id/OIP.UUF2-KkEfCzTrlF0zEfMtQHaMd?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.Sd10Fd9Rz8bCd2UyeU15QQHaNX?w=1000&h=1805&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpaperaccess.com/full/8998211.jpg',
    'https://tse1.mm.bing.net/th/id/OIP.TnIW0LEiMwffBskGYhaVPAHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP._VUJ7NiJYiNIXfE46JPIdgHaNK?w=900&h=1600&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.eCofy_aJKzoTK1Kzyek38wHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.S8oOwt08f54USKETEhSmoAHaL2?w=1200&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.razdZ-EysN3T4EnMkUiZMgHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.x_mOz8fcCg2EmsNXEbYaDgHaNL?w=1536&h=2732&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.i-GQCiBf480jU1m4JLro6QHaKj?rs=1&pid=ImgDetMain&o=7&rm=3'
];

async function addMovies() {
    try {
        console.log('Connecting to MongoDB...');
        if (!process.env.MONGO_URI) {
            throw new Error('MONGO_URI is not defined in .env file');
        }
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Movies';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        const deleteResult = await Wallpaper.deleteMany({ category: category });
        console.log(`Deleted ${deleteResult.deletedCount} old wallpapers.`);

        const newWallpapers = movieUrls.map((url, index) => ({
            title: `Movie Classic ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            }
        }));

        console.log(`Inserting ${newWallpapers.length} new movie wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Movie category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating movies:', error);
        process.exit(1);
    }
}

addMovies();
