require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const axios = require('axios');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');
const { processAndUploadImage } = require('../services/imageService');

const wallpapers = [
    { title: 'Zigzag Abstract Road', url: 'https://wallpapers.com/images/hd/4k-ultra-hd-android-i27tpw3wb8d78n3z.jpg', category: 'Abstract' },
    { title: 'Tech Minimal Wave', url: 'https://wallpapers.com/images/hd/4k-ultra-hd-android-p0370yocrtvmk715.jpg', category: 'Abstract' },
    { title: 'Digital High-Quality Aura', url: 'https://wallpapers.com/images/hd/4k-ultra-hd-android-gmpqk21p61z4jq7u.jpg', category: 'Abstract' },
    { title: 'Android Fire Landscape', url: 'https://wallpapers.com/images/hd/4k-ultra-hd-android-kojdypqpwslxfp4g.jpg', category: 'Nature' },
    { title: 'Clarity Of 4K Blue', url: 'https://wallpapers.com/images/hd/4k-ultra-hd-android-gk7aoxn8i0aud2x2.jpg', category: 'Abstract' },
    { title: 'Starry Night Over Hills', url: 'https://wallpapers.com/images/hd/4k-ultra-hd-android-eg525p4uvigij5nf.jpg', category: 'Nature' },
    { title: 'Tropical Waterfall Flow', url: 'https://wallpapers.com/images/hd/4k-ultra-hd-android-wn6egx3jstwoq4gf.jpg', category: 'Nature' },
    { title: 'Crystal Clear Blue Sky', url: 'https://wallpapers.com/images/hd/4k-ultra-hd-android-eg2dla5uzz4ubnxe.jpg', category: 'Nature' },
    { title: '4K Android Visual Experience', url: 'https://wallpapers.com/images/hd/4k-ultra-hd-android-kpfyn6ldqr9owyvg.jpg', category: 'Abstract' },
    { title: 'White Flower Bloom', url: 'https://wallpapers.com/images/hd/4k-ultra-hd-android-58vx25si51qi67no.jpg', category: 'Nature' },
    { title: 'Ultra HD Possibilities', url: 'https://wallpapers.com/images/hd/4k-ultra-hd-android-x95njrnba2zgrtt3.jpg', category: 'Abstract' },
    { title: 'Red Rose Petals', url: 'https://wallpapers.com/images/hd/4k-ultra-hd-android-agcegc8qck8bct74.jpg', category: 'Nature' },
    { title: 'Crystal Water Droplets', url: 'https://wallpapers.com/images/hd/4k-ultra-hd-android-wvtomo716uaod98o.jpg', category: 'Nature' },
    { title: 'Eiffel Tower Sunset', url: 'https://wallpapers.com/images/hd/4k-ultra-hd-android-98pswuf3b4y51nrq.jpg', category: 'Travel' },
    { title: 'Golden Hour Coconut Trees', url: 'https://wallpapers.com/images/hd/4k-ultra-hd-android-tt6s0sc58iq5dqb7.jpg', category: 'Nature' },
    { title: 'Sunny Orange Slices', url: 'https://wallpapers.com/images/hd/4k-ultra-hd-android-fii00ebaqamtptu0.jpg', category: 'Nature' }
];

async function seedWallpapersCom() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected.');

        for (const item of wallpapers) {
            console.log(`Processing: ${item.title} [${item.category}] from ${item.url}`);
            try {
                // Fetch image from URL with User-Agent to avoid blocks
                const response = await axios.get(item.url, {
                    responseType: 'arraybuffer',
                    headers: {
                        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                        'Referer': 'https://wallpapers.com/'
                    }
                });
                const buffer = Buffer.from(response.data);

                // Extract filename
                const originalName = path.basename(item.url.split('?')[0]);

                // Process and upload to GCS (processAndUploadImage handles resizing and blurhash)
                const uploadResult = await processAndUploadImage(buffer, originalName);

                // Save to MongoDB
                const newWallpaper = new Wallpaper({
                    title: item.title,
                    category: item.category,
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

seedWallpapersCom();
