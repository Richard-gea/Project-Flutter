const express = require('express');
const cors = require('cors');
const connectToMongoDB = require('./config/database');
const mongoose = require('mongoose');


const patientRoutes = require('./routes/patients');
const maladyRoutes = require('./routes/maladies');
const medicamentRoutes = require('./routes/medicaments');
const consultationRoutes = require('./routes/consultations');

const app = express();
const PORT = process.env.PORT || 3000;

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
app.use(express.json());

app.use('/api/patients', patientRoutes);
app.use('/api/maladies', maladyRoutes);
app.use('/api/medicaments', medicamentRoutes);
app.use('/api/consultations', consultationRoutes);



connectToMongoDB().then(() => {
  app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
  });
});

process.on('SIGINT', async () => {
  await mongoose.connection.close();
  process.exit(0);
});
