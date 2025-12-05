const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 8080;


const corsOptions = {
  origin: [
    'http://richard-frontend-website.s3-website-ap-southeast-1.amazonaws.com',
    'http://richard-frontend-website.s3-website-ap-southeast-1.amazonaws.com',
    'http://localhost:3000',
    'http://localhost:8080'
  ],
  credentials: true,
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept']
};

// CORS middleware
app.use(cors(corsOptions));
app.options('*', cors(corsOptions));

// Additional fallback CORS
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', 'http://richard-frontend-website.s3-website-ap-southeast-1.amazonaws.com');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept');
  res.header('Access-Control-Allow-Credentials', 'true');
  
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});

// Body parsing middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint for Elastic Beanstalk
app.get('/', (req, res) => {
  res.status(200).json({ 
    status: 'OK', 
    message: 'PharmaX API Server is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    version: '2.0.0',
    endpoints: [
      '/api/patients',
      '/api/maladies',
      '/api/medicaments', 
      '/api/consultations'
    ]
  });
});

// Additional health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK', 
    message: 'PharmaX Server is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// API Routes with safe fallbacks
let patientRoutes, maladyRoutes, medicamentRoutes, consultationRoutes;

try {
  patientRoutes = require('./routes/patients');
  maladyRoutes = require('./routes/maladies');
  medicamentRoutes = require('./routes/medicaments');
  consultationRoutes = require('./routes/consultations');
  console.log('✅ All route files loaded successfully');
} catch (err) {
  console.log('⚠️ Route files missing, using fallback routes:', err.message);
}

// Setup routes with fallbacks
if (patientRoutes) {
  app.use('/api/patients', patientRoutes);
} else {
  console.log('Using fallback patients routes');
  app.get('/api/patients', (req, res) => res.json([{ id: 1, name: 'John Doe', age: 30 }]));
  app.post('/api/patients', (req, res) => res.status(201).json({ id: Date.now(), ...req.body }));
  app.put('/api/patients/:id', (req, res) => res.json({ id: req.params.id, ...req.body }));
  app.delete('/api/patients/:id', (req, res) => res.json({ message: 'Patient deleted', id: req.params.id }));
}

if (maladyRoutes) {
  app.use('/api/maladies', maladyRoutes);
} else {
  console.log('Using fallback maladies routes');
  app.get('/api/maladies', (req, res) => res.json([{ id: 1, name: 'Common Cold', severity: 'mild' }]));
  app.post('/api/maladies', (req, res) => res.status(201).json({ id: Date.now(), ...req.body }));
  app.put('/api/maladies/:id', (req, res) => res.json({ id: req.params.id, ...req.body }));
  app.delete('/api/maladies/:id', (req, res) => res.json({ message: 'Malady deleted', id: req.params.id }));
}

if (medicamentRoutes) {
  app.use('/api/medicaments', medicamentRoutes);
} else {
  console.log('Using fallback medicaments routes');
  app.get('/api/medicaments', (req, res) => res.json([{ id: 1, name: 'Aspirin', dosage: '500mg' }]));
  app.post('/api/medicaments', (req, res) => res.status(201).json({ id: Date.now(), ...req.body }));
  app.put('/api/medicaments/:id', (req, res) => res.json({ id: req.params.id, ...req.body }));
  app.delete('/api/medicaments/:id', (req, res) => res.json({ message: 'Medicament deleted', id: req.params.id }));
}

if (consultationRoutes) {
  app.use('/api/consultations', consultationRoutes);
} else {
  console.log('Using fallback consultations routes');
  app.get('/api/consultations', (req, res) => res.json([{ id: 1, date: '2024-12-04', patient: 'John Doe' }]));
  app.post('/api/consultations', (req, res) => res.status(201).json({ id: Date.now(), ...req.body }));
  app.put('/api/consultations/:id', (req, res) => res.json({ id: req.params.id, ...req.body }));
  app.delete('/api/consultations/:id', (req, res) => res.json({ message: 'Consultation deleted', id: req.params.id }));
}

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({ 
    error: 'Internal server error', 
    message: err.message 
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ 
    error: 'Not Found', 
    message: `Route ${req.originalUrl} not found`,
    availableRoutes: ['/health', '/api/patients', '/api/maladies', '/api/medicaments', '/api/consultations']
  });
});



// Start server with error handling
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 PharmaX Server running on port ${PORT}`);
  console.log(`📍 Health check: http://localhost:${PORT}/health`);
  console.log(`🌐 CORS enabled for S3 frontend`);
  console.log(`🔄 Server started at ${new Date().toISOString()}`);
});

// Handle server errors
server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.log(`❌ Port ${PORT} is already in use`);
    process.exit(1);
  } else {
    console.error('❌ Server error:', err);
  }
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('❌ Uncaught Exception:', err);
  // Don't exit, just log the error
});

// Handle unhandled rejections
process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
  // Don't exit, just log the error
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('🛑 Received SIGTERM, shutting down gracefully');
  server.close(() => {
    console.log('✅ Server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('🛑 Received SIGINT, shutting down gracefully');
  server.close(() => {
    console.log('✅ Server closed');
    process.exit(0);
  });
});
