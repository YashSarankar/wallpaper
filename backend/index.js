const express = require('express');
const connectDB = require('./config/db');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Connect Database
connectDB();
// test
// Init Middleware
app.use(express.json({ extended: false }));
app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

app.get('/', (req, res) => {
    res.send('Wallpaper Backend API is running...');
});

// Define Routes
app.use('/api/wallpapers', require('./routes/wallpapers'));

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('SERVER CRASH:', {
        message: err.message,
        stack: err.stack,
        path: req.path,
        method: req.method
    });
    res.status(500).json({
        msg: 'The server encountered an error processing your request',
        error: err.message,
        path: req.path
    });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => console.log(`Server started on port ${PORT}`));
