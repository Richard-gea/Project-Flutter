const express = require('express');
const cors = require('cors');
const connectToMongoDB = require('./config/database');

const patientRoutes = require('./routes/patients');
const maladyRoutes = require('./routes/maladies');
const medicamentRoutes = require('./routes/medicaments');
const consultationRoutes = require('./routes/consultations');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
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
