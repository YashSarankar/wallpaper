require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const Wallpaper = require('../models/Wallpaper');

async function checkCounts() {
    await mongoose.connect(process.env.MONGO_URI);
    const categories = await Wallpaper.distinct('category');
    console.log('Wallpapers per category:');
    for (let cat of categories) {
        const count = await Wallpaper.countDocuments({ category: cat });
        console.log(`- ${cat}: ${count}`);
    }
    process.exit();
}

checkCounts();
