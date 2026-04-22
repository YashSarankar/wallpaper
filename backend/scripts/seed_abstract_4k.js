require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const axios = require('axios');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');
const { processAndUploadImage } = require('../services/imageService');
const { bucket } = require('../config/gcs');

const abstractWallpapers = [
    { "title": "Vibrant red and black pattern", "url": "https://images.pexels.com/photos/1493226/pexels-photo-1493226.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=3840&w=2160" },
    { "title": "Abstract painting bold blue and orange", "url": "https://images.pexels.com/photos/1690351/pexels-photo-1690351.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=3840&w=2160" },
    { "title": "Dynamic abstract acrylic painting", "url": "https://images.pexels.com/photos/2983141/pexels-photo-2983141.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=3840&w=2160" },
    { "title": "Colorful abstract painting", "url": "https://images.pexels.com/photos/1149019/pexels-photo-1149019.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=3840&w=2160" },
    { "title": "Black and white abstract curved lines", "url": "https://images.pexels.com/photos/3694708/pexels-photo-3694708.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=3840&w=2160" },
    { "title": "Vibrant fluid acrylic paint", "url": "https://images.pexels.com/photos/1428169/pexels-photo-1428169.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=3840&w=2160" },
    { "title": "Colorful paint swirls", "url": "https://images.pexels.com/photos/3109830/pexels-photo-3109830.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=3840&w=2160" },
    { "title": "Orange stripes dark background", "url": "https://images.pexels.com/photos/925711/pexels-photo-925711.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=3840&w=2160" },
    { "title": "Red and black swirls motion", "url": "https://images.pexels.com/photos/3045828/pexels-photo-3045828.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=3840&w=2160" },
    { "title": "Pink green and blue modern art", "url": "https://images.pexels.com/photos/2887710/pexels-photo-2887710.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=3840&w=2160" },
    { "title": "Black background multicolored swirl", "url": "https://images.unsplash.com/photo-1664640458531-3c7cca2a9323?q=80&w=3840&auto=format&fit=crop" },
    { "title": "White wall wavy lines", "url": "https://images.unsplash.com/photo-1558591710-4b4a1ae0f04d?q=80&w=3840&auto=format&fit=crop" },
    { "title": "Sun sky daytime abstract", "url": "https://images.unsplash.com/photo-1604079628040-94301bb21b91?q=80&w=3840&auto=format&fit=crop" },
    { "title": "Red and blue wallpaper", "url": "https://images.unsplash.com/photo-1567095761054-7a02e69e5c43?q=80&w=3840&auto=format&fit=crop" },
    { "title": "Purple white and orange light", "url": "https://images.unsplash.com/photo-1604076913837-52ab5629fba9?q=80&w=3840&auto=format&fit=crop" },
    { "title": "Abstract painting orange blue", "url": "https://images.unsplash.com/photo-1528459801416-a9e53bbf4e17?q=80&w=3840&auto=format&fit=crop" },
    { "title": "Multicolored abstract painting", "url": "https://images.unsplash.com/photo-1484589065579-248aad0d8b13?q=80&w=3840&auto=format&fit=crop" },
    { "title": "Pink and green abstract art", "url": "https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=3840&auto=format&fit=crop" },
    { "title": "White and black striped textile", "url": "https://images.unsplash.com/photo-1595411425732-e69c1abe2763?q=80&w=3840&auto=format&fit=crop" },
    { "title": "Purple and green abstract background", "url": "https://images.unsplash.com/photo-1567359781514-3b964e2b04d6?q=80&w=3840&auto=format&fit=crop" }
];

async function seedAbstract4K() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected.');

        const category = 'Abstract';

        console.log(`Clearing existing ${category} wallpapers to apply 4-layer optimization...`);
        const existing = await Wallpaper.find({ category });
        for (const doc of existing) {
            const urlsToDelete = [doc.imageUrl.original, doc.imageUrl.high, doc.imageUrl.mid, doc.imageUrl.low].filter(Boolean);
            for (const url of urlsToDelete) {
                const filePath = url.split(process.env.GCS_BUCKET_NAME + '/')[1];
                if (filePath) await bucket.file(filePath).delete().catch(() => { });
            }
            await Wallpaper.deleteOne({ _id: doc._id });
        }

        for (const item of abstractWallpapers) {
            console.log(`Processing: ${item.title} from ${item.url}`);
            try {
                // Fetch image from URL
                const response = await axios.get(item.url, { responseType: 'arraybuffer' });
                const buffer = Buffer.from(response.data);

                // Extract filename for originalName
                const originalName = path.basename(item.url.split('?')[0]);

                // Process and upload to GCS (generates original, mid, low, blurHash)
                const uploadResult = await processAndUploadImage(buffer, originalName);

                // Save to MongoDB
                const newWallpaper = new Wallpaper({
                    title: item.title,
                    category: category,
                    imageUrl: {
                        original: uploadResult.original,
                        mid: uploadResult.mid,
                        low: uploadResult.low,
                        blurHash: uploadResult.blurHash
                    },
                    type: 'static'
                });

                await newWallpaper.save();
                console.log(`Successfully added: ${item.title}`);
            } catch (err) {
                console.error(`Failed to process ${item.title}: ${err.message}`);
            }
        }

        console.log('Seeding completed!');
        process.exit(0);
    } catch (error) {
        console.error('Fatal Error:', error);
        process.exit(1);
    }
}

seedAbstract4K();
