const cors = require('cors');

const corsOptions = {
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
};

const corsMiddleware = cors(corsOptions);

// Additional CORS middleware as fallback
const additionalCorsMiddleware = (req, res, next) => {
  res.header('Access-Control-Allow-Origin', 'http://richard-frontend-website.s3-website.eu-north-1.amazonaws.com');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept');
  res.header('Access-Control-Allow-Credentials', 'true');
  
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
};

module.exports = {
  corsMiddleware,
  additionalCorsMiddleware
};