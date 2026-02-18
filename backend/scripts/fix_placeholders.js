const mongoose = require('mongoose');
const path = require('path');
const dotenv = require('dotenv');

dotenv.config({ path: path.join(__dirname, '../.env') });

async function fixPlaceholders() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected.');

        // Use the explicit collection name 'Wallpapers'
        const Wallpaper = mongoose.model('Wallpaper', new mongoose.Schema({
            imageUrl: {
                original: String,
                mid: String,
                low: String
            }
        }), 'Wallpapers');

        const docs = await Wallpaper.find({ 'imageUrl.original': { $regex: /placehold\.co/ } });
        console.log(`Found ${docs.length} placeholders in 'Wallpapers' collection.`);

        let updatedCount = 0;
        for (const doc of docs) {
            if (!doc.imageUrl.original.includes('.png')) {
                doc.imageUrl.original = doc.imageUrl.original.replace('1080x1920', '1080x1920.png');
                doc.imageUrl.mid = doc.imageUrl.mid.replace('1080x1920', '1080x1920.png');
                doc.imageUrl.low = doc.imageUrl.low.replace('1080x1920', '1080x1920.png');
                await doc.save();
                updatedCount++;
            }
        }

        console.log(`Updated ${updatedCount} wallpapers.`);
        process.exit(0);
    } catch (error) {
        console.error('Error:', error);
        process.exit(1);
    }
}

fixPlaceholders();
