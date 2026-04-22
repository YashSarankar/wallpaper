const { bucket } = require('../config/gcs');
const sharp = require('sharp');
const path = require('path');

// Helper to upload a buffer to GCS
const uploadBuffer = (buffer, filename, contentType = 'image/jpeg') => {
    return new Promise((resolve, reject) => {
        console.log(`Uploading to GCS: ${filename}...`);
        const blob = bucket.file(filename);
        const blobStream = blob.createWriteStream({
            resumable: false,
            metadata: {
                contentType: contentType,
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

/**
 * Generates a BlurHash string from an image buffer.
 * Uses a tiny 32x32 intermediate to keep encode time under 10ms even on CPU.
 */
const generateBlurHash = async (fileBuffer) => {
    try {
        const { encode } = require('blurhash');
        // Downscale to tiny size for fast encoding
        const { data, info } = await sharp(fileBuffer)
            .resize(32, 32, { fit: 'inside' })
            .ensureAlpha()
            .raw()
            .toBuffer({ resolveWithObject: true });

        // Components: 4x3 is the sweet spot (Instagram uses this)
        const hash = encode(new Uint8ClampedArray(data), info.width, info.height, 4, 3);
        return hash;
    } catch (e) {
        console.error('BlurHash generation failed:', e.message);
        return null;
    }
};

exports.processAndUploadImage = async (fileBuffer, originalName) => {
    const timestamp = Date.now();
    const cleanName = path.parse(originalName).name.replace(/\s+/g, '_').replace(/[^a-zA-Z0-9_]/g, '');

    // We will convert to JPEG for consistency
    const baseName = `${timestamp}-${cleanName}`;

    // 4K Original (High Quality - 100% for 4K feel)
    const originalBuffer = await sharp(fileBuffer)
        .jpeg({ quality: 100 })
        .toBuffer();
    const originalPath = `wallpapers/original/${baseName}.jpg`;

    // High (Optimized 1440p PORTRAIT CROP for modern high-end Android displays)
    // This is the "Gold Standard" solution: by cropping to 20:9 on the server,
    // we eliminate the need for the device to up-scale landscape-to-portrait.
    const highBuffer = await sharp(fileBuffer)
        .resize({
            width: 1440,
            height: 3200,
            fit: 'cover',
            position: 'centre'
        })
        .jpeg({ quality: 95 })
        .toBuffer();
    const highPath = `wallpapers/high/${baseName}.jpg`;

    // Mid (Medium Quality - e.g., for full screen mobile view but optimized)
    const midBuffer = await sharp(fileBuffer)
        .resize({ width: 1080, withoutEnlargement: true }) // Standard mobile width
        .jpeg({ quality: 75 })
        .toBuffer();
    const midPath = `wallpapers/mid/${baseName}.jpg`;

    // Low (Low Quality - e.g., for thumbnails)
    const lowBuffer = await sharp(fileBuffer)
        .resize({ width: 300, withoutEnlargement: true })
        .jpeg({ quality: 60 })
        .toBuffer();
    const lowPath = `wallpapers/low/${baseName}.jpg`;

    // BlurHash from the original
    const blurHash = await generateBlurHash(fileBuffer);

    // Parallel upload
    const [original, high, mid, low] = await Promise.all([
        uploadBuffer(originalBuffer, originalPath, 'image/jpeg'),
        uploadBuffer(highBuffer, highPath, 'image/jpeg'),
        uploadBuffer(midBuffer, midPath, 'image/jpeg'),
        uploadBuffer(lowBuffer, lowPath, 'image/jpeg')
    ]);

    return { original, high, mid, low, blurHash };
};

exports.uploadVideo = async (fileBuffer, originalName, mimetype) => {
    const timestamp = Date.now();
    const cleanName = path.parse(originalName).name.replace(/\s+/g, '_').replace(/[^a-zA-Z0-9_]/g, '');
    const extension = path.extname(originalName) || '.mp4';
    const filename = `wallpapers/videos/${timestamp}-${cleanName}${extension}`;

    return await uploadBuffer(fileBuffer, filename, mimetype);
};
