const mongoose = require('mongoose');
const axios = require('axios');
const path = require('path');
const dotenv = require('dotenv');
const Wallpaper = require('../models/Wallpaper');
const { processAndUploadImage } = require('../services/imageService');

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });

const urls = [
    {
        url: 'https://tse1.mm.bing.net/th/id/OIP.eXqeuUWeg2kxGq0V8GLDGQHaO0?w=1080&h=2160&rs=1&pid=ImgDetMain&o=7&rm=3',
        title: 'Premium Sport Car Night'
    },
    {
        url: 'https://www.ixpap.com/images/2024/01/Lamborghini-Aventador-Wallpaper-8-768x1662.jpg',
        title: 'Lamborghini Aventador Gold'
    },
    {
        url: 'https://tse3.mm.bing.net/th/id/OIP.vveFZ42IkiZE3jOVVJr8_gHaOy?w=751&h=1500&rs=1&pid=ImgDetMain&o=7&rm=3',
        title: 'Classic Muscle Car'
    }
];

const category = 'Cars & Bike';

async function downloadAndUpload() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected.');

        for (const item of urls) {
            console.log(`\nProcessing: ${item.title}...`);
            try {
                // 1. Download the image
                const response = await axios.get(item.url, { responseType: 'arraybuffer' });
                const buffer = Buffer.from(response.data, 'binary');
                const originalName = item.url.split('/').last || 'manual_upload.jpg';

                // 2. Process and Upload to GCS
                console.log('Uploading to Google Cloud Storage...');
                const imageUrls = await processAndUploadImage(buffer, originalName);

                // 3. Save to MongoDB
                const newWallpaper = new Wallpaper({
                    title: item.title,
                    category: category,
                    imageUrl: imageUrls,
                    createdAt: new Date()
                });

                await newWallpaper.save();
                console.log(`Successfully added: ${item.title}`);
                console.log(`Original URL: ${imageUrls.original}`);
            } catch (err) {
                console.error(`Failed to process ${item.title}:`, err.message);
            }
        }

        console.log('\nAll tasks completed.');
        process.exit(0);
    } catch (error) {
        console.error('Connection Error:', error);
        process.exit(1);
    }
}

downloadAndUpload();
