const { Storage } = require('@google-cloud/storage');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

// Instantiate a storage client
const storageOptions = {};
console.log('Initializing GCS Storage...');

if (process.env.GOOGLE_APPLICATION_CREDENTIALS_JSON) {
    try {
        console.log('Using GOOGLE_APPLICATION_CREDENTIALS_JSON from env...');
        storageOptions.credentials = JSON.parse(process.env.GOOGLE_APPLICATION_CREDENTIALS_JSON);
        console.log(`GCS Credentials parsed. Project ID: ${storageOptions.credentials.project_id}`);
    } catch (err) {
        console.error('FAILED to parse GOOGLE_APPLICATION_CREDENTIALS_JSON:', err.message);
    }
} else {
    console.log('Using local keyFilename for GCS...');
    storageOptions.keyFilename = process.env.GOOGLE_APPLICATION_CREDENTIALS;
}

const storage = new Storage(storageOptions);

const bucketName = process.env.GCS_BUCKET_NAME;
console.log(`Targeting GCS Bucket: ${bucketName || 'NOT DEFINED'}`);

let bucket = null;
if (!bucketName) {
    console.error('CRITICAL: GCS_BUCKET_NAME is not defined!');
} else {
    bucket = storage.bucket(bucketName);
}

module.exports = { storage, bucket };
