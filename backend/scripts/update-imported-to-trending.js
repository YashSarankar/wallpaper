const mongoose = require('mongoose');
const connectDB = require('../config/db');
const Wallpaper = require('../models/Wallpaper');
require('dotenv').config();

const updateImportedToTrending = async () => {
    try {
        // Connect to Database
        await connectDB();

        console.log('Searching for wallpapers with category "imported"...');

        // Find and update all wallpapers with category "imported" to "Trending"
        // Using case-insensitive search just in case
        const result = await Wallpaper.updateMany(
            { category: { $regex: /^imported$/i } },
            { $set: { category: 'Trending' } }
        );

        console.log(`Success! Updated ${result.modifiedCount} wallpapers from "imported" to "Trending".`);

        process.exit(0);
    } catch (err) {
        console.error('Update failed:', err.message);
        process.exit(1);
    }
};

updateImportedToTrending();
