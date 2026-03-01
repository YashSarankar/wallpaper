require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const Wallpaper = require('../models/Wallpaper');

async function check() {
    await mongoose.connect(process.env.MONGO_URI);
    const count = await Wallpaper.countDocuments();
    const countStatic = await Wallpaper.countDocuments({ type: 'static' });
    const countNull = await Wallpaper.countDocuments({ type: null });
    const sample = await Wallpaper.findOne();
    console.log('Total:', count, 'Static:', countStatic, 'Null:', countNull);
    console.log('Sample:', sample);
    process.exit();
}

check();
