const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const urls = [
    'https://tse3.mm.bing.net/th/id/OIP.bFQNzNqAaoPzO4WFtKRhlQHaQC?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.OTMHLEBGszBdB-nRwtJuMAHaNK?w=2160&h=3840&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://cdn.wallpapersafari.com/10/88/91a6Zu.jpg',
    'https://tse1.explicit.bing.net/th/id/OIP.yaRcMcQYPzzrOoAOjhQAxQHaL2?w=1000&h=1600&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://i.pinimg.com/originals/46/b8/e0/46b8e09c92936b87e461d1425e1a2adb.jpg',
    'https://i.pinimg.com/736x/16/84/45/1684458564214eb9ec08638db0740965.jpg',
    'https://tse2.mm.bing.net/th/id/OIP.rg_SnYseD4RM4W1qKnML7gHaPp?w=757&h=1600&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://i.pinimg.com/736x/aa/0c/7f/aa0c7f606192e10dc47932cf9b5bb390.jpg',
    'https://free-3dtextureshd.com/wp-content/uploads/2025/02/407-4.jpg.webp',
    'https://tse2.mm.bing.net/th/id/OIP.WAc8RA0bp1IbPzhXwnyqswHaHa?w=1536&h=1536&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.1FS3JNYWu4a7l1oh7dIXBQHaJN?w=828&h=1029&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://i.pinimg.com/750x/27/21/b7/2721b79193e955f0d7b511ec378693aa.jpg',
    'https://i.pinimg.com/736x/a4/19/48/a41948e612b26215764705310a728ad9.jpg',
    'https://wallpapers.com/images/hd/animated-phone-okhav1h0bif0c6pq.jpg'
];

async function updateCategory() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Anime';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        await Wallpaper.deleteMany({ category: category });

        const newWallpapers = urls.map((url, index) => ({
            title: `Anime World ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new anime wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Anime category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating anime category:', error);
        process.exit(1);
    }
}

updateCategory();
