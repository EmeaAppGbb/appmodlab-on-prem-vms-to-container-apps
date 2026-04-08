const express = require('express');
const router = express.Router();
const Prescription = require('../models/Prescription');

// Get all prescriptions
router.get('/', async (req, res) => {
    try {
        const prescriptions = await Prescription.find().sort({ createdAt: -1 });
        res.json(prescriptions);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get prescriptions by patient ID
router.get('/patient/:patientId', async (req, res) => {
    try {
        const prescriptions = await Prescription.find({ patientId: req.params.patientId });
        res.json(prescriptions);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get prescription by ID
router.get('/:id', async (req, res) => {
    try {
        const prescription = await Prescription.findById(req.params.id);
        if (!prescription) {
            return res.status(404).json({ error: 'Prescription not found' });
        }
        res.json(prescription);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Create new prescription
router.post('/', async (req, res) => {
    try {
        const prescription = new Prescription(req.body);
        await prescription.save();
        res.status(201).json(prescription);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Delete prescription
router.delete('/:id', async (req, res) => {
    try {
        const prescription = await Prescription.findByIdAndDelete(req.params.id);
        if (!prescription) {
            return res.status(404).json({ error: 'Prescription not found' });
        }
        res.json({ message: 'Prescription deleted successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
