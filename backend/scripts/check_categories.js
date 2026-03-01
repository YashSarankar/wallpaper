require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const Wallpaper = require('../models/Wallpaper');

async function checkCategories() {
    await mongoose.connect(process.env.MONGO_URI);
    const categories = await Wallpaper.distinct('category');
    console.log('Categories currently in DB:');
    console.log(categories.join(', '));
    process.exit();
}

checkCategories();
