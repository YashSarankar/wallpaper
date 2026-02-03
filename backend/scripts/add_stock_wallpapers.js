const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const stockUrls = [
    'https://wallpaperaccess.com/full/2938511.jpg',
    'https://wallpapers.com/images/hd/animated-phone-iphgl3ndfhwfmdpd.jpg',
    'https://wallpapers.com/images/hd/animated-phone-d46w7xoic7bkbms7.jpg',
    'https://tse1.mm.bing.net/th/id/OIP.n9DTr8gUjf1RDZrrdAq_qAHaMW?w=480&h=800&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://i.pinimg.com/736x/65/ae/97/65ae97b499dce37091d913826e320fb7--cell-phone-wallpapers-bugs.jpg',
    'https://wallpaperaccess.com/full/3229827.jpg',
    'https://wallpapers.com/images/hd/animated-phone-0yll8yy4zi8cle7t.jpg',
    'https://wallpapers.com/images/hd/animated-phone-z821yflz5bdrn28p.jpg',
    'https://wallpapers.com/images/hd/animated-phone-p4pmr88fp5j8q1c5.jpg',
    'https://wallpapers.com/images/hd/animated-phone-nbjy01ujyv6oxtyu.jpg',
    'https://www.pixelstalk.net/wp-content/uploads/2016/10/iPhone-animated-moving-wallpapers-mobile-free-download.jpg',
    'https://www.itl.cat/pngfile/big/4-48657_animated-nature-wallpaper-for-mobile-phones-mobile-scenery.jpg',
    'https://tse4.mm.bing.net/th/id/OIP.ss4MlIb37VcLfMjRlHNm-QHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.0UtEXAAYizrUciP8RquhYgHaM9?w=768&h=1344&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.6KvJAbO4mVNg27KvZl2O8AHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://3.bp.blogspot.com/-oRE47O2udKY/T5BPqn5GxCI/AAAAAAAAHjQ/aKheesojulI/s1600/Latest+Mobile+Wallpapers+For+HTC+Sensation+Cell+Phone+HTC+Sensation+Themes.jpg'
];

async function addStockWallpapers() {
    try {
        console.log('Connecting to MongoDB...');
        if (!process.env.MONGO_URI) {
            throw new Error('MONGO_URI is not defined in .env file');
        }
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Stock';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        const deleteResult = await Wallpaper.deleteMany({ category: category });
        console.log(`Deleted ${deleteResult.deletedCount} old wallpapers.`);

        const newWallpapers = stockUrls.map((url, index) => ({
            title: `Stock Original ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new stock wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Stock category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating stock category:', error);
        process.exit(1);
    }
}

addStockWallpapers();
