const mongoose = require('mongoose');

const medicamentSchema = new mongoose.Schema({
  medicamentName: {
    type: String,
    required: [true, 'Medicament name is required'],
    trim: true
  },
  malady_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Malady',
    required: [true, 'Malady ID is required']
  },
  isDeleted: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Medicament', medicamentSchema);
