const express = require('express');
const connectDB = require('./config/db');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Connect Database
connectDB();

// Init Middleware
app.use(express.json({ extended: false }));
app.use(cors());

app.get('/', (req, res) => {
    res.send('Wallpaper Backend API is running...');
});

// Define Routes
app.use('/api/wallpapers', require('./routes/wallpapers'));

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Global Error Handler:', err);
    res.status(500).json({ error: err.message || 'Something went wrong on the server' });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => console.log(`Server started on port ${PORT}`));
