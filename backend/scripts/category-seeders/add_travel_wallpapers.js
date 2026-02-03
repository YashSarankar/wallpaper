const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const urls = [
    'https://tse1.mm.bing.net/th/id/OIP.qok3tMDQtMtJ574KghfcIwHaQD?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.gkwyVb2fkmC9x7L9P-L3hwHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.qJdnfXVs-Nl8Y2tSXXNSYwHaNK?w=715&h=1271&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.-NpaikkKOhVNVb0mQPZBwgHaNK?w=900&h=1600&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.VJHAOpc0LoW2IlW3A6R4CQHaNK?w=950&h=1689&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.vF8DuLgVbm4K0Ug2BbhLJAHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.TcJZ8nRM9LYzSGF4O0UQhAHaNK?w=736&h=1308&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpaper.dog/large/20505293.jpg',
    'https://tse4.mm.bing.net/th/id/OIP.Gd6eEoBp1HHuc9Y7NrfbLwHaQB?w=1125&h=2435&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapercave.com/wp/wp5053495.jpg',
    'https://tse1.mm.bing.net/th/id/OIP.fCWBexsawkILF498Ym5M2wHaNK?w=1242&h=2208&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapercave.com/wp/wp5053460.jpg',
    'https://tse3.mm.bing.net/th/id/OIP.PnCKXVZK1q0aQafUGYRCMAHaNK?w=675&h=1200&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.W8ps0uZM4W3RZ4qU87nH4AHaMW?w=768&h=1280&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpaperbat.com/img/315598-best-travel-iphone-11-wallpaper-hd.jpg',
    'https://tse2.mm.bing.net/th/id/OIP.LD0U95rjbaNJhepSKPiV0QHaMx?w=1001&h=1727&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapers.com/images/hd/iphone-travel-1guxi6kl4ynphzti.jpg',
    'https://tse4.mm.bing.net/th/id/OIP.-wQO4De8GaxWwoHE84QlMAHaNL?w=736&h=1309&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.rE74xIE9IZZI__eKJHKNzgHaPo?w=720&h=1520&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.KzrZh9nzJxdVcW0dFaccMwHaQC?w=650&h=1407&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.sWDBha5F_e4Nu1xLYpjr1gHaQC?w=650&h=1407&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.fhAsCkLYU6oCzpBH2yWOMAHaQC?w=650&h=1407&rs=1&pid=ImgDetMain&o=7&rm=3'
];

async function updateCategory() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Travel';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        await Wallpaper.deleteMany({ category: category });

        const newWallpapers = urls.map((url, index) => ({
            title: `Wanderlust ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new travel wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Travel category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating travel category:', error);
        process.exit(1);
    }
}

updateCategory();
