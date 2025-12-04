const express = require('express');
const { corsMiddleware, additionalCorsMiddleware } = require('./middleware/corsMiddleware');
const { errorHandler, notFoundHandler } = require('./middleware/errorMiddleware');

// Import routes
const patientRoutes = require('./routes/patients');
const maladyRoutes = require('./routes/maladies');
const medicamentRoutes = require('./routes/medicaments');
const consultationRoutes = require('./routes/consultations');

const app = express();
const PORT = process.env.PORT || 8080;

// CORS middleware
app.use(corsMiddleware);
app.options('*', corsMiddleware);
app.use(additionalCorsMiddleware);

// Body parsing middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint for Elastic Beanstalk
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK', 
    message: 'PharmaX Server is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// API Routes
app.use('/api/patients', patientRoutes);
app.use('/api/maladies', maladyRoutes);
app.use('/api/medicaments', medicamentRoutes);
app.use('/api/consultations', consultationRoutes);

// Error handling middleware (must be after routes)
app.use(notFoundHandler);
app.use(errorHandler);



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
