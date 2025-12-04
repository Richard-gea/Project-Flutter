const mongoose = require('mongoose');
// config/database.js

const connectToMongoDB = async () => {
  const uri = process.env.MONGO_URI || 'mongodb://localhost:27017/pharmax';

  console.log('🔌 Connecting to MongoDB:', uri);

  try {
    await mongoose.connect(uri, {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });
    console.log('✅ Connected to MongoDB');
  } catch (err) {
    console.error('❌ MongoDB connection error:', err.message);
    console.log('⚠️ Continuing without database connection...');
    // Don't crash the app if MongoDB fails
    return false;
  }
  return true;
};

module.exports = connectToMongoDB;



