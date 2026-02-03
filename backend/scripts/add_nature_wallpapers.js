const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const urls = [
    'https://tse4.mm.bing.net/th/id/OIP.eyCMjc9lhYf3BW7x9zVjWAHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.kcBdLozwNqTKf3yLMzaoKgHaNK?w=610&h=1084&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://th.bing.com/th/id/R.a3db85e6aa46656d3425ebbc403e109c?rik=UvfpC9PRSQUShw&riu=http%3a%2f%2f4.bp.blogspot.com%2f-QxZgeVGaBzE%2fT7TP5E0r_8I%2fAAAAAAAAD8Q%2ft9q4to-x_lk%2fs1600%2fnature%2bmobile%2bwallpapers%2banimated%2b3d%2bgifs%2bfree%2bdoanload%2bbeautiful%2blandscape%2bwaterfall%2bnature%2bmobile%2bscreensaver%2b3d%2bgif%2banimation%2bgraphic%2bphoto%2bclipart%2becards%2banimated%2bpictures%2bavatars%2bicons%2blove%2bplanet.gif&ehk=wvr9VsLEH%2bgqvygEaLnsn%2fKphgbkeIQmPTs8k01JEvc%3d&risl=&pid=ImgRaw&r=0',
    'https://s-media-cache-ak0.pinimg.com/originals/e9/c4/96/e9c4963596ca9e2f99bbb65432034498.jpg',
    'https://image.winudf.com/v2/image/Y29tLkZpcmVmbGllc1dMUFBfc2NyZWVuXzFfMTUzODA5MzgyMF8wNDY/screen-1.webp?fakeurl=1&type=.webp',
    'https://www.pngmagic.com/product_images/stunning-nature-mobile-wallpaper-in-hd_NcQ.jpeg',
    'https://image.lexica.art/full_jpg/b8dee419-0469-4a86-82b1-f50d58dc8efe',
    'https://i.pinimg.com/736x/0a/99/2f/0a992f7d07eb43728ef22f7837473d7a.jpg',
    'https://tse1.mm.bing.net/th/id/OIP.RQaGMMTGn9Q9yV6VdH8ngAHaNK?w=360&h=640&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://imgcdn.stablediffusionweb.com/2024/4/27/d5ced049-e26d-4425-b231-56489e8b5051.jpg'
];

async function updateCategory() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Nature';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        await Wallpaper.deleteMany({ category: category });

        const newWallpapers = urls.map((url, index) => ({
            title: `Nature Beauty ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new nature wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Nature category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating nature category:', error);
        process.exit(1);
    }
}

updateCategory();
