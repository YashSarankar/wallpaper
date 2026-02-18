require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const Admin = require('../models/Admin');

const createAdmin = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected to MongoDB...');

        const username = 'admin';
        const password = 'password123';
        const hashedPassword = await bcrypt.hash(password, 10);

        const existingAdmin = await Admin.findOne({ username });

        if (existingAdmin) {
            console.log('Admin already exists. Resetting password...');
            existingAdmin.password = hashedPassword;
            await existingAdmin.save();
            console.log('Password reset successfully!');
        } else {
            const admin = new Admin({
                username,
                password: hashedPassword
            });
            await admin.save();
            console.log('Admin created successfully!');
        }

        console.log('--- CREDENTIALS ---');
        console.log('Username:', username);
        console.log('Password:', password);
        console.log('-------------------');
        process.exit(0);
    } catch (err) {
        console.error('Error creating admin:', err.message);
        process.exit(1);
    }
};

createAdmin();
