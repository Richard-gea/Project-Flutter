const express = require('express');
const cors = require('cors');
const connectToMongoDB = require('./config/database');
const mongoose = require('mongoose');


const patientRoutes = require('./routes/patients');
const maladyRoutes = require('./routes/maladies');
const medicamentRoutes = require('./routes/medicaments');
const consultationRoutes = require('./routes/consultations');

const app = express();
const PORT = process.env.PORT || 8080;

app.use(cors({
  origin: [
    'http://richard-frontend-website.s3-website.eu-north-1.amazonaws.com',
    'https://richard-frontend-website.s3-website.eu-north-1.amazonaws.com',
    'http://localhost:3000',
    'http://localhost:8080'
  ],
  credentials: true,
  optionsSuccessStatus: 200
}));
app.use(express.json());

// Health check endpoint for Elastic Beanstalk
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK', 
    message: 'PharmaX Server is running',
    timestamp: new Date().toISOString()
  });
});

app.use('/api/patients', patientRoutes);
app.use('/api/maladies', maladyRoutes);
app.use('/api/medicaments', medicamentRoutes);
app.use('/api/consultations', consultationRoutes);



// Start server regardless of database connection
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 PharmaX Server running on port ${PORT}`);
  console.log(`📍 Health check: http://localhost:${PORT}/health`);
});

// Try to connect to MongoDB (optional)
connectToMongoDB().catch(err => {
  console.log('⚠️ MongoDB not available, using mock data');
});

process.on('SIGINT', async () => {
  await mongoose.connection.close();
  process.exit(0);
});
