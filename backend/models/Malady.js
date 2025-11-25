const mongoose = require('mongoose');

const maladySchema = new mongoose.Schema({
  maladyName: {
    type: String,
    required: [true, 'Malady name is required'],
    unique: true,
    trim: true
  },
  isDeleted: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Malady', maladySchema);
