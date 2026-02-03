const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
const { storage, bucket } = require('../config/gcs');

async function fixPermissions() {
    try {
        console.log(`Checking bucket: ${bucket.name}...`);

        // 1. Try to make the entire bucket public (Uniform bucket-level access)
        try {
            await bucket.iam.getPolicy();
            await bucket.iam.setPolicy({
                bindings: [
                    {
                        role: 'roles/storage.objectViewer',
                        members: ['allUsers'],
                    },
                ],
            });
            console.log('✅ Bucket-level "allUsers" access granted.');
        } catch (e) {
            console.log('⚠️ Could not set bucket-level policy. Trying individual files...');
        }

        // 2. Make all existing files public
        console.log('Fetching files list...');
        const [files] = await bucket.getFiles({ prefix: 'wallpapers/' });

        console.log(`Found ${files.length} files. Making them public...`);

        for (const file of files) {
            try {
                await file.makePublic();
                console.log(`✅ Made public: ${file.name}`);
            } catch (err) {
                console.error(`❌ Failed to make public: ${file.name} - ${err.message}`);
            }
        }

        console.log('\nDone! If you still see 403, please check the console for "Public Access Prevention".');
        process.exit(0);
    } catch (err) {
        console.error('Permission fix failed:', err);
        process.exit(1);
    }
}

fixPermissions();
