const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
    patientId: { type: String, required: true },
    patientName: { type: String, required: true },
    vetId: { type: String, required: true },
    vetName: { type: String, required: true },
    appointmentDate: { type: Date, required: true },
    appointmentType: { type: String, required: true },
    status: { type: String, default: 'Scheduled' },
    reason: { type: String },
    notes: { type: String },
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Appointment', appointmentSchema);
