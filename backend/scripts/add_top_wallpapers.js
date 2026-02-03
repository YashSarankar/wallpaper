const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const urls = [
    'https://tse1.mm.bing.net/th/id/OIP._jACEVpT0xyvwddhdAY5BgHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.eYsVESN3CNkR6C-VKkw7vQHaNK?w=2160&h=3840&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.jt7Xq8lHmP8dyTB6ZNYsvQHaNK?w=2160&h=3840&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.aLYIAODjx4I4fydl7QoQTAHaNK?w=2160&h=3840&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.jpaifXFFgAtRJBBWPucHygHaNK?w=2160&h=3840&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.b2qIuZo78_T6aXxEvsMiJQHaNW?w=1212&h=2184&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.9e4B_FODQmPEDrKU46TnbgHaNK?w=2160&h=3840&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.SakCGk-vCI-dxjfMUqQgRAHaNK?w=950&h=1689&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.By2Up0sEvrS0Rtdf6EQJCwHaLH?w=3504&h=5256&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.Mn4FmmE1AVglw494IfVzLQHaL2?w=1000&h=1600&rs=1&pid=ImgDetMain&o=7&rm=3'
];

async function updateCategory() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Top';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        await Wallpaper.deleteMany({ category: category });

        const newWallpapers = urls.map((url, index) => ({
            title: `Premium Top ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new top wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Top category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating top category:', error);
        process.exit(1);
    }
}

updateCategory();
