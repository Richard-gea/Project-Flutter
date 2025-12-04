// Global error handler middleware
const errorHandler = (err, req, res, next) => {
  console.error('Server error:', err);
  
  // Default error response
  let status = 500;
  let message = 'Internal server error';
  
  // Handle specific error types
  if (err.name === 'ValidationError') {
    status = 400;
    message = 'Validation error';
  } else if (err.name === 'CastError') {
    status = 400;
    message = 'Invalid ID format';
  } else if (err.code === 11000) {
    status = 409;
    message = 'Duplicate key error';
  }
  
  res.status(status).json({ 
    error: message, 
    message: err.message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
};

// 404 handler middleware
const notFoundHandler = (req, res) => {
  res.status(404).json({ 
    error: 'Not Found', 
    message: `Route ${req.originalUrl} not found`,
    availableRoutes: [
      '/health',
      '/api/patients',
      '/api/maladies', 
      '/api/medicaments',
      '/api/consultations'
    ]
  });
};

module.exports = {
  errorHandler,
  notFoundHandler
};