const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const urls = [
    'https://wallpapers.com/images/hd/3d-phone-pink-purple-bubbles-6xqqgold8utezuuh.jpg',
    'https://i.pinimg.com/originals/a8/41/ff/a841ffa1546ab0839e635d3f6f23d176.jpg',
    'https://tse3.mm.bing.net/th/id/OIP.HVJPtCwGsSOzEsVoWQC45QHaHa?w=2932&h=2932&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.FlFCMrtBWfRYUk3yviXa_QHaNK?w=736&h=1308&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.X0WSrUYzWXkq4sP3anE9GAHaQD?w=900&h=1950&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpaperbat.com/img/9765315-hypercar-iphone-wallpaper.jpg',
    'https://i.pinimg.com/736x/f2/32/ca/f232ca5fc6b32370fea7c30348c88043.jpg',
    'https://i.pinimg.com/originals/f4/ad/96/f4ad96deeaf04168c95a849f1663d148.jpg',
    'https://i.pinimg.com/1200x/f5/f7/93/f5f7936fb7b05fc1726df2187832d3ca.jpg',
    'https://tse3.mm.bing.net/th/id/OIP.L1Gx9_5m-Frv_EHn3oZTSgHaPp?w=1205&h=2545&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapers.com/images/hd/dirt-bike-in-the-city-9kpalzc73av965su.jpg',
    'https://tse3.mm.bing.net/th/id/OIP.bIgrv9R-Ub_wu1vScKcSIQAAAA?w=351&h=626&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://img.freepik.com/premium-photo/motion-blurred-highway-ride-biker-red-motorcycle-captivates-frontal-perspective-vertical-mobi_896558-17591.jpg',
    'https://tse3.mm.bing.net/th/id/OIP.NLUF9sNhIo2R5aSP4RKBygHaEo?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.GEijC5bzq9JYkFfjObFZCgHaNL?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.wx4IcRX-vN-qj6XowV6drQAAAA?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpaperbat.com/img/14507542-cartoon-car-iphone-wallpaper.jpg',
    'https://tse3.mm.bing.net/th/id/OIP.qwcRIfKC-B0_bNNQu08DSQHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.VUB0oRy_YiUGIkd_sf-AXAHaNK?w=720&h=1280&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.Piux2IsF_nkfLYjofEokMgAAAA?rs=1&pid=ImgDetMain&o=7&rm=3'
];

async function updateCategory() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected.');

        const category = 'Cars & Bike';

        console.log(`Clearing old wallpapers for category: ${category}`);
        await Wallpaper.deleteMany({ category });

        const newWallpapers = urls.map((url, i) => ({
            title: `${category} Premium ${i + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Done!');
        process.exit(0);
    } catch (error) {
        console.error('Error:', error);
        process.exit(1);
    }
}

updateCategory();
