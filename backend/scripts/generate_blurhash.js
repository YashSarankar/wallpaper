/**
 * Backfill script: generates BlurHash for all existing wallpapers that don't have one.
 * Run with: node scripts/generate_blurhash.js
 */
const mongoose = require('mongoose');
const path = require('path');
const dotenv = require('dotenv');
const https = require('https');
const http = require('http');
const sharp = require('sharp');
const { encode } = require('blurhash');

dotenv.config({ path: path.join(__dirname, '../.env') });

const Wallpaper = require('../models/Wallpaper');

async function downloadBuffer(url) {
    return new Promise((resolve, reject) => {
        const protocol = url.startsWith('https') ? https : http;
        protocol.get(url, (res) => {
            const chunks = [];
            res.on('data', chunk => chunks.push(chunk));
            res.on('end', () => resolve(Buffer.concat(chunks)));
            res.on('error', reject);
        }).on('error', reject);
    });
}

async function generateBlurHash(buffer) {
    const { data, info } = await sharp(buffer)
        .resize(32, 32, { fit: 'inside' })
        .ensureAlpha()
        .raw()
        .toBuffer({ resolveWithObject: true });

    return encode(new Uint8ClampedArray(data), info.width, info.height, 4, 3);
}

async function run() {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB.');

    // Find all wallpapers that are missing a blurHash
    const wallpapers = await Wallpaper.find({
        $or: [
            { 'imageUrl.blurHash': { $exists: false } },
            { 'imageUrl.blurHash': null },
            { 'imageUrl.blurHash': '' },
        ]
    });

    console.log(`Found ${wallpapers.length} wallpapers missing blurHash.`);

    let success = 0;
    let failed = 0;

    for (const wp of wallpapers) {
        const url = wp.imageUrl?.low || wp.imageUrl?.mid || wp.imageUrl?.original;
        if (!url || !url.startsWith('http')) {
            console.warn(`Skipping ${wp._id}: no valid URL`);
            failed++;
            continue;
        }

        try {
            process.stdout.write(`Processing ${wp._id}... `);
            const buffer = await downloadBuffer(url);
            const hash = await generateBlurHash(buffer);

            await Wallpaper.updateOne(
                { _id: wp._id },
                { $set: { 'imageUrl.blurHash': hash } }
            );

            console.log(`Done → ${hash}`);
            success++;
        } catch (e) {
            console.error(`FAILED: ${e.message}`);
            failed++;
        }
    }

    console.log(`\nFinished! ${success} updated, ${failed} failed.`);
    process.exit(0);
}

run().catch(err => {
    console.error(err);
    process.exit(1);
});
