const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
const Admin = require('../models/Admin');

async function createAdmin() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);

        const username = 'admin';
        const password = 'SuperSecretAdminPassword123'; // CHANGE THIS

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Check if admin already exists
        let admin = await Admin.findOne({ username });
        if (admin) {
            console.log('Admin already exists, updating password...');
            admin.password = hashedPassword;
        } else {
            admin = new Admin({
                username,
                password: hashedPassword
            });
        }

        await admin.save();
        console.log('-----------------------------------');
        console.log('Admin account ready!');
        console.log(`Username: ${username}`);
        console.log(`Password: ${password}`);
        console.log('-----------------------------------');

        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

createAdmin();
