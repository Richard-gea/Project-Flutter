const mongoose = require('mongoose');

const consultationSchema = new mongoose.Schema({
  patient_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: [true, 'Patient ID is required']
  },
  malady_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Malady',
    required: [true, 'Malady ID is required']
  },
  medicament_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Medicament',
    required: [true, 'Medicament ID is required']
  },
  date: {
    type: Date,
    default: Date.now
  },

  isDeleted: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Consultation', consultationSchema);
