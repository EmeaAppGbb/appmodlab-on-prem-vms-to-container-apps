const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const LabResult = require('../models/LabResult');

// Configure multer for file uploads (legacy SMB share simulation)
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = '/app/shared-documents/lab-results';
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueName = `${Date.now()}-${file.originalname}`;
        cb(null, uniqueName);
    }
});

const upload = multer({ storage });

// Get all lab results
router.get('/', async (req, res) => {
    try {
        const labResults = await LabResult.find().sort({ createdAt: -1 });
        res.json(labResults);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get lab results by patient ID
router.get('/patient/:patientId', async (req, res) => {
    try {
        const labResults = await LabResult.find({ patientId: req.params.patientId });
        res.json(labResults);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Upload lab result file
router.post('/upload', upload.single('file'), async (req, res) => {
    try {
        const labResult = new LabResult({
            patientId: req.body.patientId,
            patientName: req.body.patientName,
            testType: req.body.testType || 'General Lab Test',
            results: req.body.results,
            filePath: req.file ? req.file.path : null,
            vetId: req.body.vetId,
            vetName: req.body.vetName,
            notes: req.body.notes
        });
        
        await labResult.save();
        
        // Send to RabbitMQ for background processing (VM 3)
        if (req.app.locals.publishToQueue) {
            req.app.locals.publishToQueue('lab_results', {
                labResultId: labResult._id,
                patientId: labResult.patientId,
                patientName: labResult.patientName,
                testType: labResult.testType,
                filePath: labResult.filePath
            });
        }
        
        res.status(201).json(labResult);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Create lab result (without file)
router.post('/', async (req, res) => {
    try {
        const labResult = new LabResult(req.body);
        await labResult.save();
        res.status(201).json(labResult);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

module.exports = router;
