const mongoose = require('mongoose');

const connectDB = async () => {
    try {
        // Mongoose 9+ simplifies connection, no options needed for standard use
        const conn = await mongoose.connect(process.env.MONGO_URI);

        console.log(`MongoDB Connected: ${conn.connection.host}`);
    } catch (err) {
        console.error(`Error: ${err.message}`);
        process.exit(1);
    }
};

module.exports = connectDB;
