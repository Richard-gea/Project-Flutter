const mongoose = require('mongoose');

const connectToMongoDB = async () => {
  const uri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/pharmax';

  await mongoose.connect(uri);   // ✅ no useNewUrlParser / useUnifiedTopology

  console.log('✅ Connected to MongoDB');
};

module.exports = connectToMongoDB;

