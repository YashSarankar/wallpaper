const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const urls = [
    'https://tse2.mm.bing.net/th/id/OIP.nHH4QdGvhYUtZKMBIMWB9AHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.V3wzaBIZmoP4fT1Hfs1esgHaQD?w=1301&h=2820&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.qsXUOnUeXZl58ghzcAc_xwHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.t3DPYKWh05CZQM1nlasMXAHaQD?w=1080&h=2340&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://e0.pxfuel.com/wallpapers/964/911/desktop-wallpaper-animated-mobile-phone-gif-high-resolution-is-1-for-mobile.jpg',
    'https://tse1.mm.bing.net/th/id/OIP.UXHZytYpseRhFmltXh9-YQHaNK?w=2160&h=3840&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://cdn.wallpapersafari.com/40/91/SqmYw0.gif',
    'https://tse3.mm.bing.net/th/id/OIP.FPqTE9sEEOici5fFQmYfigHaMz?w=1200&h=2074&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.AR4mTX_L1p-zz0WLzFDWKgHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.NjQwT_bHYa1MLFmHT-9s2gHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapercave.com/wp/wp6099114.jpg',
    'https://tse2.mm.bing.net/th/id/OIP.2UpskRChiuPiO8ju-9-QQgHaNK?w=1441&h=2560&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.BgEC1wdLmf5gvMn-ZkNztgHaPO?w=1440&h=2960&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.NDT1I2S_pMiny9AcLLjXSAHaPN?w=779&h=1600&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.K_zJnId5_noy-Od0PYwP0wHaNK?w=1440&h=2560&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapers.com/images/hd/amoled-android-fantasy-planet-ctoqbrp7cxojlp5f.jpg',
    'https://wallpapercave.com/wp/wp5574264.jpg',
    'https://tse1.mm.bing.net/th/id/OIP.pBvyDpi-iH2_eLnozf2k-wHaPo?w=1440&h=3040&rs=1&pid=ImgDetMain&o=7&rm=3'
];

async function updateCategory() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Amoled';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        await Wallpaper.deleteMany({ category: category });

        const newWallpapers = urls.map((url, index) => ({
            title: `Pure AMOLED ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new amoled wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Amoled category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating amoled category:', error);
        process.exit(1);
    }
}

updateCategory();
