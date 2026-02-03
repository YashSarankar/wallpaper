const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const godUrls = [
    'https://w0.peakpx.com/wallpaper/124/7/HD-wallpaper-ganesh-ji-bhagwan-ke-animated-lord-ganesha-hindu-god-ganpati-bappa-devotional.jpg',
    'https://w0.peakpx.com/wallpaper/353/653/HD-wallpaper-hindu-god-vishnu-vishwaroop.jpg',
    'https://wallpaperbat.com/img/8625971-hindu-gods-iphone-wallpaper-hd.jpg',
    'https://img.freepik.com/premium-photo/hindu-god-shiva-illustartion_862994-4527.jpg',
    'https://w0.peakpx.com/wallpaper/19/592/HD-wallpaper-lord-krishna-animated-sun-background-lord-god.jpg',
    'https://www.imageshine.in/uploads/gallery/Hindu-God-HD-Mobile-Wallpaper-Free-Download.jpg',
    'https://w0.peakpx.com/wallpaper/945/13/HD-wallpaper-lord-krishna-animation-lord-krishna-religious-hindu-god-god-cartoon.jpg',
    'https://tse1.mm.bing.net/th/id/OIP.jKphAeFyVHeCpq8dVHJKagHaHa?w=2000&h=2000&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.zat2QzlJl7ummHAFkicl8gHaEK?w=1280&h=720&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://asset.gecdesigns.com/img/wallpapers/animated-cute-ganpati-hd-image-for-ganesh-chaturthi-festival-sr05092401-cover.webp',
    'https://img.freepik.com/premium-photo/hindu-god-shiva-illustartion_862994-4523.jpg',
    'https://tse2.mm.bing.net/th/id/OIP.xwVTObvDiHr0CMKK18cL_QHaJQ?w=1024&h=1280&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://e0.pxfuel.com/wallpapers/543/763/desktop-wallpaper-lord-krishna-cloud-art-hindu-bhagwan-india-god.jpg',
    'https://www.imageshine.in/uploads/gallery/Lord-Mobile-Wallpapers.jpg',
    'https://iphoneswallpapers.com/wp-content/uploads/2023/04/God-Shiva-Neon-Colours-iPhone-Wallpaper-HD.jpg',
    'https://wallpapers.com/images/hd/god-mobile-shiva-hindu-god-artwork-kttesew18310mui6.jpg',
    'https://www.imageshine.in/uploads/gallery/attitude-Mobile-wallpaper-of-hindu-gods.jpg',
    'https://www.imageshine.in/uploads/gallery/Bhagwan-ke-full-HD-Mobile-Wallpaper.jpg',
    'https://iphoneswallpapers.com/wp-content/uploads/2023/04/Vishnu-God-iPhone-Wallpaper-HD.jpg',
    'https://st5.depositphotos.com/3934335/64732/i/450/depositphotos_647325356-stock-illustration-admire-majestic-portrait-shiva-hindu.jpg',
    'https://tse1.mm.bing.net/th/id/OIP.WogRMhi7QdBxYGg6bv43NAHaF7?w=1280&h=1024&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.ZBaFsS9KKDejVRGEgm_ctwHaEo?w=1920&h=1200&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.X4gNTTQX7DEZhxjiQ8AY4wAAAA?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://w0.peakpx.com/wallpaper/539/15/HD-wallpaper-lord-rama-animated-lord-ram-animated-god-jai-shri-ram.jpg',
    'https://w0.peakpx.com/wallpaper/743/887/HD-wallpaper-lordsiva-mahadeva-praying.jpg',
    'https://wallpaper.dog/large/20671838.jpg',
    'https://tse2.mm.bing.net/th/id/OIP.biEKS_sIAjfT_QkzQhTk9AHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.WotV7Kg1U0_woMGROSOoVgHaKX?w=857&h=1200&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapersok.com/images/file/glowing-artworkof-lord-hanuman-cr32sh0gyu9gexf9.jpg'
];

async function addGodWallpapers() {
    try {
        console.log('Connecting to MongoDB...');
        if (!process.env.MONGO_URI) {
            throw new Error('MONGO_URI is not defined in .env file');
        }
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'God';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        const deleteResult = await Wallpaper.deleteMany({ category: category });
        console.log(`Deleted ${deleteResult.deletedCount} old wallpapers.`);

        const newWallpapers = godUrls.map((url, index) => ({
            title: `Devotional ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new god wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated God category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating god category:', error);
        process.exit(1);
    }
}

addGodWallpapers();
