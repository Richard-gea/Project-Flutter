const express = require('express');
const cors = require('cors');

// Optional imports - don't fail if missing
let patientRoutes, maladyRoutes, medicamentRoutes, consultationRoutes;

try {
  patientRoutes = require('./routes/patients');
  maladyRoutes = require('./routes/maladies');
  medicamentRoutes = require('./routes/medicaments');
  consultationRoutes = require('./routes/consultations');
} catch (err) {
  console.log('⚠️ Some route files not found, using fallback routes');
}

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
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept']
}));

// Handle preflight requests explicitly
app.options('*', cors());

app.use(express.json());

// Additional CORS middleware as fallback
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', 'http://richard-frontend-website.s3-website.eu-north-1.amazonaws.com');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept');
  res.header('Access-Control-Allow-Credentials', 'true');
  
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});

// Health check endpoint for Elastic Beanstalk
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK', 
    message: 'PharmaX Server is running',
    timestamp: new Date().toISOString()
  });
});

// Setup routes with fallbacks
if (patientRoutes) {
  app.use('/api/patients', patientRoutes);
} else {
  app.get('/api/patients', (req, res) => {
    res.json([{ id: 1, name: 'John Doe', age: 30 }]);
  });
}

if (maladyRoutes) {
  app.use('/api/maladies', maladyRoutes);
} else {
  app.get('/api/maladies', (req, res) => {
    res.json([{ id: 1, name: 'Common Cold', severity: 'mild' }]);
  });
}

if (medicamentRoutes) {
  app.use('/api/medicaments', medicamentRoutes);
} else {
  app.get('/api/medicaments', (req, res) => {
    res.json([{ id: 1, name: 'Aspirin', dosage: '500mg' }]);
  });
}

if (consultationRoutes) {
  app.use('/api/consultations', consultationRoutes);
} else {
  app.get('/api/consultations', (req, res) => {
    res.json([{ id: 1, date: '2024-12-04', patient: 'John Doe' }]);
  });
}



// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 PharmaX Server running on port ${PORT}`);
  console.log(`📍 Health check: http://localhost:${PORT}/health`);
  console.log(`🌐 CORS enabled for S3 frontend`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('🛑 Received SIGTERM, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('🛑 Received SIGINT, shutting down gracefully');
  process.exit(0);
});
