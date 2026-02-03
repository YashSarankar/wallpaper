const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const urls = [
    'https://tse3.mm.bing.net/th/id/OIP.WjjZSya_D-3IQisL9QugxQHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.egWzJOvPQujZT8cJUDYeAAHaQC?w=887&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.55U57_-xASXddnGzQcWDyAHaPO?w=1440&h=2960&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.Q7KCxjHs9ysTTKLC03enXgHaQC?w=1125&h=2436&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.RlNDkMVc7T-K8KkgkDFe1gHaQd?w=1080&h=2400&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://i.pinimg.com/736x/38/44/53/38445373273fea08b10981334c42d7c1.jpg',
    'https://tse1.mm.bing.net/th/id/OIP.X13Zpx1LmtnYRF14gvvw5wHaMR?w=1280&h=2120&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.w3CyZvt-ZRoBq-GvJcRJVwHaNK?w=2160&h=3840&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://w0.peakpx.com/wallpaper/953/729/HD-wallpaper-nikto-codm-cod-mobile-gaming-thumbnail.jpg',
    'https://tse1.mm.bing.net/th/id/OIP.MxNzQW39lYF05t12lqsP1QHaKX?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.r_IdCbXwW0Dn6IaJjrczcwHaLH?w=768&h=1152&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapers.com/images/file/pixel-3-battlefield-3-background-qj30d6dojciz62pg.jpg',
    'https://tse2.mm.bing.net/th/id/OIP.VqOUnAN-67c5zhiOPIOQ-wHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.qOPNTWtPVP8IGKmH00EtdQHaNK?rs=1&pid=ImgDetMain&o=7&rm=3'
];

async function updateCategory() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Game';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        await Wallpaper.deleteMany({ category: category });

        const newWallpapers = urls.map((url, index) => ({
            title: `Pro Gamer ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new game wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Game category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating game category:', error);
        process.exit(1);
    }
}

updateCategory();
