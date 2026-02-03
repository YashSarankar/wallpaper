const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const urls = [
    'https://tse4.mm.bing.net/th/id/OIP.OzI_PC7CRMNr4h4Z8zgiewHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.DzhU69bawpSyUSyCxGmjNgHaNK?w=1242&h=2208&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.hkjMCnblFRqTlnyQFhbmYQHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.oR80CDWpEfDA065dATVScgHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.LC0Jv3TvvE7bmVjiAuQZbQHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.EhGy0k1_G6JAyO5FE0IgkAHaNK?w=1242&h=2208&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://th.bing.com/th/id/R.899aba685cc068212b246df5c9284018?rik=Kqos72gAplIU7g&riu=http%3a%2f%2fgetwallpapers.com%2fwallpaper%2ffull%2fa%2f6%2f4%2f1131922-widescreen-abstract-pattern-wallpaper-1080x1920-for-mac.jpg&ehk=WP60n4wKo4GMqw3eeMRNZV%2b7v6SGCailyH5tQ2F551I%3d&risl=&pid=ImgRaw&r=0',
    'https://assets.hongkiat.com/uploads/abstract-mobile-wallpapers/preview/abstract-wallpaper-15.jpg',
    'https://wallpaperbat.com/img/432606-abstract-phone-wallpaper-collection-195.jpg',
    'https://wallpapercave.com/wp/wp13111779.jpg',
    'https://wallpapercave.com/wp/wp3526764.jpg',
    'https://tse2.mm.bing.net/th/id/OIP.KC5yIL0jeb4fb8mnrlOvKAHaQC?w=1125&h=2436&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://assets.hongkiat.com/uploads/abstract-mobile-wallpapers/preview/abstract-wallpaper-25.jpg'
];

async function updateCategory() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Abstract';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        await Wallpaper.deleteMany({ category: category });

        const newWallpapers = urls.map((url, index) => ({
            title: `Abstract Art ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new abstract wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Abstract category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating abstract category:', error);
        process.exit(1);
    }
}

updateCategory();
