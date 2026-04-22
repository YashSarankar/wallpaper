require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const axios = require('axios');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');
const { processAndUploadImage } = require('../services/imageService');

const wallpapers = [
    {
        "title": "Bloodborne ",
        "url": "https://wallpapers.com/images/hd/bloodborne-android-gaming-3dzy787qs3yffnzj.jpg",
        "category": "Gaming"
    },
    {
        "title": "Solaire Of Astora",
        "url": "https://wallpapers.com/images/hd/solaire-of-astora-android-gaming-026wfcxq4bh9z8jt.jpg",
        "category": "Gaming"
    },
    {
        "title": "Darth Vader",
        "url": "https://wallpapers.com/images/hd/darth-vader-android-gaming-gl7gp0g2waatnh95.jpg",
        "category": "Gaming"
    },
    {
        "title": "Street Fighter V",
        "url": "https://wallpapers.com/images/hd/street-fighter-v-android-gaming-l0wg22a8jybvf5ni.jpg",
        "category": "Gaming"
    },
    {
        "title": "Battleground (PUBG)",
        "url": "https://wallpapers.com/images/hd/battleground-android-gaming-gfk6s3ug1lo6lmtg.jpg",
        "category": "Gaming"
    },
    {
        "title": "Call of Duty Ghost",
        "url": "https://wallpapers.com/images/hd/ghost-android-gaming-bclst7xjvinabo8h.jpg",
        "category": "Gaming"
    },
    {
        "title": "Fortnite Rogue",
        "url": "https://wallpapers.com/images/hd/fortnite-roque-android-gaming-odcw5tia9z8xyfwo.jpg",
        "category": "Gaming"
    },
    {
        "title": "Teemo (LoL)",
        "url": "https://wallpapers.com/images/hd/teemo-android-gaming-9971y0ts41swloiw.jpg",
        "category": "Gaming"
    },
    {
        "title": "Fortnite Battle Royale",
        "url": "https://wallpapers.com/images/hd/fortnite-battle-royale-android-gaming-wrlcibeiapk3jfkz.jpg",
        "category": "Gaming"
    },
    {
        "title": "Skeleton Knight",
        "url": "https://wallpapers.com/images/hd/skeleton-knight-android-gaming-7igpwzor5q1zp9ml.jpg",
        "category": "Gaming"
    },
    {
        "title": "Moss VR",
        "url": "https://wallpapers.com/images/hd/moss-android-gaming-1mzlldg4hovh36ea.jpg",
        "category": "Gaming"
    },
    {
        "title": "Battlefield 1",
        "url": "https://wallpapers.com/images/hd/battlefield-1-android-gaming-sqm8b43rs7wg7i9b.jpg",
        "category": "Gaming"
    },
    {
        "title": "Assassin's Creed",
        "url": "https://wallpapers.com/images/hd/assassin-s-creed-android-gaming-iykyl7u2lkggp7gr.jpg",
        "category": "Gaming"
    },
    {
        "title": "Wild Hunt Logo",
        "url": "https://wallpapers.com/images/hd/wild-hunt-logo-android-gaming-wi7eycfubdd5qkvt.jpg",
        "category": "Gaming"
    },
    {
        "title": "Mortal Kombat Sub Zero",
        "url": "https://wallpapers.com/images/hd/sub-zero-android-gaming-xrzacbuo5wthlh6g.jpg",
        "category": "Gaming"
    },
    {
        "title": "Witcher 3 Wild Hunt",
        "url": "https://wallpapers.com/images/hd/witcher-3-wild-hunt-android-gaming-z9tuy8o7x9t7l5wf.jpg",
        "category": "Gaming"
    },
    {
        "title": "Crysis 3",
        "url": "https://wallpapers.com/images/hd/crysis-3-android-gaming-qw6gy1le9ngifk2a.jpg",
        "category": "Gaming"
    },
    {
        "title": "God Eater 2",
        "url": "https://wallpapers.com/images/hd/god-eater-2-android-gaming-bh94u6mukqa4phyt.jpg",
        "category": "Gaming"
    },
    {
        "title": "Android Gaming Setup",
        "url": "https://wallpapers.com/images/hd/android-gaming-background-rufnb4kxf9z5wxdf.jpg",
        "category": "Gaming"
    },
    {
        "title": "Counter Strike GO",
        "url": "https://wallpapers.com/images/hd/android-counter-strike-global-offensive-background-zqzdpx7mo5cyo6r6.jpg",
        "category": "Gaming"
    }
];

async function seedGamingWallpapers() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected.');

        for (const item of wallpapers) {
            console.log(`Processing: ${item.title} [${item.category}] from ${item.url}`);
            try {
                const response = await axios.get(item.url, {
                    responseType: 'arraybuffer',
                    headers: {
                        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                        'Referer': 'https://wallpapers.com/'
                    }
                });
                const buffer = Buffer.from(response.data);
                const originalName = path.basename(item.url);

                const uploadResult = await processAndUploadImage(buffer, originalName);

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

        console.log('Gaming seeding completed!');
        process.exit(0);
    } catch (error) {
        console.error('Fatal Error:', error);
        process.exit(1);
    }
}

seedGamingWallpapers();
