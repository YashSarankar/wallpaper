const express = require('express');
const connectDB = require('./config/db');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Connect Database
connectDB();

// CORS Configuration - The "Security Door"
const allowedOrigins = [
    'http://localhost:5173', // Local Admin Panel
    'http://localhost:3000', // Local development
    process.env.ADMIN_PANEL_URL, // Your Live Render Admin URL
].filter(Boolean);

app.use(express.json({ extended: false }));

app.use(cors({
    origin: function (origin, callback) {
        // Allow mobile apps (no origin) and specific web URLs
        if (!origin || allowedOrigins.indexOf(origin) !== -1) {
            callback(null, true);
        } else {
            console.log('BLOCKED BY CORS:', origin);
            callback(new Error('Security Block: This origin is not allowed'));
        }
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

app.get('/', (req, res) => {
    res.send('Wallpaper Backend API is running...');
});

// Define Routes
app.use('/api/auth', require('./routes/auth'));
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
