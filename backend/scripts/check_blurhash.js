/**
 * Quick check: how many wallpapers have blurHash in MongoDB right now
 */
const mongoose = require('mongoose');
const path = require('path');
const dotenv = require('dotenv');

dotenv.config({ path: path.join(__dirname, '../.env') });

async function check() {
    console.log('MONGO_URI:', process.env.MONGO_URI?.substring(0, 40) + '...');
    await mongoose.connect(process.env.MONGO_URI);

    const db = mongoose.connection.db;
    const collection = db.collection('Wallpapers');

    const total = await collection.countDocuments();
    const withHash = await collection.countDocuments({ 'imageUrl.blurHash': { $exists: true, $ne: null, $ne: '' } });
    const withoutHash = total - withHash;

    // Show a sample document
    const sample = await collection.findOne({ 'imageUrl.blurHash': { $exists: true } });

    console.log(`\nTotal wallpapers: ${total}`);
    console.log(`With blurHash:    ${withHash}`);
    console.log(`Without blurHash: ${withoutHash}`);

    if (sample) {
        console.log('\nSample document imageUrl:');
        console.log(JSON.stringify(sample.imageUrl, null, 2));
    } else {
        console.log('\nNO documents with blurHash found!');
        // Show raw structure of one doc
        const raw = await collection.findOne({});
        console.log('\nRaw imageUrl from first doc:');
        console.log(JSON.stringify(raw?.imageUrl, null, 2));
    }

    process.exit(0);
}

check().catch(e => { console.error(e); process.exit(1); });
