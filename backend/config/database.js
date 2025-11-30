const mongoose = require('mongoose');
// config/database.js

const connectToMongoDB = async () => {
  const uri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/pharmax';

  console.log('🔌 Connecting to MongoDB:', uri);

  try {
    await mongoose.connect(uri);
    console.log('✅ Connected to MongoDB');
  } catch (err) {
    console.error('❌ MongoDB connection error:', err.message);
    throw err;
  }
};

module.exports = connectToMongoDB;



