const { Storage } = require('@google-cloud/storage');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

// Instantiate a storage client
const storageOptions = {};
if (process.env.GOOGLE_APPLICATION_CREDENTIALS_JSON) {
    // For production (Render/Heroku), we can pass the JSON string directly
    storageOptions.credentials = JSON.parse(process.env.GOOGLE_APPLICATION_CREDENTIALS_JSON);
} else {
    // For local development
    storageOptions.keyFilename = process.env.GOOGLE_APPLICATION_CREDENTIALS;
}

const storage = new Storage(storageOptions);

const bucketName = process.env.GCS_BUCKET_NAME;
const bucket = storage.bucket(bucketName);

module.exports = { storage, bucket };
