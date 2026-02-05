const mongoose = require('mongoose');

const connectDB = async () => {
    try {
        const uri = process.env.MONGO_URI;
        if (!uri) {
            console.error('CRITICAL: MONGO_URI is not defined in environment variables!');
            process.exit(1);
        }

        console.log(`Attempting to connect to MongoDB... (Target: ${uri.split('@')[1] || 'Localhost'})`);
        const conn = await mongoose.connect(uri);

        console.log(`MongoDB Connected: ${conn.connection.host}`);
    } catch (err) {
        console.error(`CRITICAL MongoDB Connection Error: ${err.message}`);
        console.error(err);
        // Don't exit process, let the server start so we can see logs
    }
};

module.exports = connectDB;
