const { bucket } = require('../config/gcs');
const sharp = require('sharp');
const path = require('path');

// Helper to upload a buffer to GCS
const uploadBuffer = (buffer, filename) => {
    return new Promise((resolve, reject) => {
        console.log(`Uploading to GCS: ${filename}...`);
        const blob = bucket.file(filename);
        const blobStream = blob.createWriteStream({
            resumable: false,
            // predefinedAcl: 'publicRead', // Removed because bucket has Uniform Access enabled
            metadata: {
                contentType: 'image/jpeg',
            }
        });

        blobStream.on('error', (err) => {
            console.error(`GCS Upload Error (${filename}):`, err);
            reject(err);
        });

        blobStream.on('finish', () => {
            const publicUrl = `https://storage.googleapis.com/${bucket.name}/${blob.name}`;
            console.log(`Uploaded: ${filename} -> ${publicUrl}`);
            resolve(publicUrl);
        });

        blobStream.end(buffer);
    });
};

exports.processAndUploadImage = async (fileBuffer, originalName) => {
    const timestamp = Date.now();
    const cleanName = path.parse(originalName).name.replace(/\s+/g, '_').replace(/[^a-zA-Z0-9_]/g, '');

    // We will convert to JPEG for consistency
    const baseName = `${timestamp}-${cleanName}`;

    // 1. Original (High Quality)
    const originalBuffer = await sharp(fileBuffer)
        .jpeg({ quality: 90 })
        .toBuffer();
    const originalPath = `wallpapers/original/${baseName}.jpg`;

    // 2. Mid (Medium Quality - e.g., for full screen mobile view but optimized)
    const midBuffer = await sharp(fileBuffer)
        .resize({ width: 1080, withoutEnlargement: true }) // Standard mobile width
        .jpeg({ quality: 75 })
        .toBuffer();
    const midPath = `wallpapers/mid/${baseName}.jpg`;

    // 3. Low (Low Quality - e.g., for thumbnails)
    const lowBuffer = await sharp(fileBuffer)
        .resize({ width: 300, withoutEnlargement: true })
        .jpeg({ quality: 60 })
        .toBuffer();
    const lowPath = `wallpapers/low/${baseName}.jpg`;

    // Parallel upload
    const [original, mid, low] = await Promise.all([
        uploadBuffer(originalBuffer, originalPath),
        uploadBuffer(midBuffer, midPath),
        uploadBuffer(lowBuffer, lowPath)
    ]);

    return { original, mid, low };
};
