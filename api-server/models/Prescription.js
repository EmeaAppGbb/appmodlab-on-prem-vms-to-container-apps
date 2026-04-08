const mongoose = require('mongoose');

const prescriptionSchema = new mongoose.Schema({
    patientId: { type: String, required: true },
    patientName: { type: String },
    vetId: { type: String, required: true },
    vetName: { type: String },
    medication: { type: String, required: true },
    dosage: { type: String, required: true },
    frequency: { type: String, required: true },
    duration: { type: String },
    instructions: { type: String },
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Prescription', prescriptionSchema);
