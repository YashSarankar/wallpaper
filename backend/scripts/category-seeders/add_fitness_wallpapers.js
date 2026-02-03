const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const urls = [
    'https://wallpapers.com/images/hd/fitness-motivation-iphone-xychzpi1yen7e9ta.jpg',
    'https://tse3.mm.bing.net/th/id/OIP.5wJol_M5GPw-3gSN5SkruAHaKw?w=1000&h=1453&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://img.freepik.com/free-vector/simple-dark-gym-motivational-mobile-wallpaper_23-2149442206.jpg?w=2000',
    'https://wallpaperaccess.com/full/8071006.jpg',
    'https://tse4.mm.bing.net/th/id/OIP.xTvbToiBU6E7KmE2zQbeugHaN4?w=1047&h=1963&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.MXURjZCDSLcoKQRrRkRkeQHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://w0.peakpx.com/wallpaper/644/105/HD-wallpaper-fitness-gym-motivation.jpg',
    'https://wallpaperbat.com/img/150023-workout-picture-download-free-image-stock-photo.jpg',
    'https://tse1.mm.bing.net/th/id/OIP.nahXTqXV42Gc-vXXV_RxQwHaNQ?w=1072&h=1918&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapercave.com/wp/wp8867144.jpg',
    'https://i.pinimg.com/originals/21/77/b9/2177b9b7b14d201d3085deea147de1c0.png',
    'https://img.freepik.com/free-photo/fit-individual-doing-sport_23-2151764307.jpg',
    'https://tse1.explicit.bing.net/th/id/OIP.AEYBOB2XbOPAb6M-vILLQwHaNL?w=750&h=1334&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapers.com/images/hd/gym-iphone-okflipus8tp9cmcr.jpg',
    'https://wallpaperaccess.com/full/3278140.png',
    'https://tse1.explicit.bing.net/th/id/OIP.i_GFzDNMJaW96llnDr0t5QHaNK?w=720&h=1280&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.Acy_tlEUNcMRXp-0-EKLKgHaN2?w=744&h=1392&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://th.bing.com/th/id/R.28417c623033841b00e065642ac2ad6c?rik=PeE5f0nRxNJ4eQ&riu=http%3a%2f%2fm.gettywallpapers.com%2fwp-content%2fuploads%2f2022%2f07%2fGYM-Wallpaper.jpg&ehk=daLTDAFbfW1ysS0Gl6uJY2DIM5u%2bCkVEgjTgWf%2btK0k%3d&risl=&pid=ImgRaw&r=0',
    'https://wallpaperaccess.com/full/7855019.jpg',
    'https://i.pinimg.com/originals/14/ae/50/14ae50aadea0db38722c5dd3635c4d58.png'
];

async function updateCategory() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Fitness';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        await Wallpaper.deleteMany({ category: category });

        const newWallpapers = urls.map((url, index) => ({
            title: `Fitness Motivation ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new fitness wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Fitness category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating fitness category:', error);
        process.exit(1);
    }
}

updateCategory();
