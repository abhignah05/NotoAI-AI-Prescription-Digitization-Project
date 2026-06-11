const mongoose = require('mongoose');

const emrSchema = new mongoose.Schema({
  patientName: { type: String, required: false },
  doctorName: { type: String, required: false },
  prescriptionText: { type: String, required: true },
  emrData: { type: Object, required: true },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('EMR', emrSchema); 