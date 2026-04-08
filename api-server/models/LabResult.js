const mongoose = require('mongoose');

const labResultSchema = new mongoose.Schema({
    patientId: { type: String, required: true },
    patientName: { type: String },
    testType: { type: String, required: true },
    testDate: { type: Date, default: Date.now },
    results: { type: String },
    filePath: { type: String },
    vetId: { type: String },
    vetName: { type: String },
    notes: { type: String },
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('LabResult', labResultSchema);
