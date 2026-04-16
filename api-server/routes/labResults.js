const express = require('express');
const router = express.Router();
const multer = require('multer');
const axios = require('axios');
const LabResult = require('../models/LabResult');

const DAPR_HTTP_PORT = process.env.DAPR_HTTP_PORT || '3500';
const DAPR_BLOB_BINDING = process.env.DAPR_BLOB_BINDING || 'blobstore';

// Use multer memory storage — files are uploaded to Azure Blob Storage, not local disk
const upload = multer({ storage: multer.memoryStorage() });

/**
 * Upload file content to Azure Blob Storage via Dapr output binding.
 */
async function uploadToBlob(blobName, fileBuffer, contentType) {
    const daprUrl = `http://localhost:${DAPR_HTTP_PORT}/v1.0/bindings/${DAPR_BLOB_BINDING}`;
    const payload = {
        operation: 'create',
        data: fileBuffer.toString('base64'),
        metadata: {
            blobName,
            contentType: contentType || 'application/octet-stream'
        }
    };

    await axios.post(daprUrl, payload);
    return blobName;
}

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

// Upload lab result file to Azure Blob Storage
router.post('/upload', upload.single('file'), async (req, res) => {
    try {
        let blobPath = null;

        if (req.file) {
            const blobName = `lab-results/${Date.now()}-${req.file.originalname}`;
            blobPath = await uploadToBlob(blobName, req.file.buffer, req.file.mimetype);
        }

        const labResult = new LabResult({
            patientId: req.body.patientId,
            patientName: req.body.patientName,
            testType: req.body.testType || 'General Lab Test',
            results: req.body.results,
            filePath: blobPath,
            vetId: req.body.vetId,
            vetName: req.body.vetName,
            notes: req.body.notes
        });

        await labResult.save();

        // Publish to message queue for background processing
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
