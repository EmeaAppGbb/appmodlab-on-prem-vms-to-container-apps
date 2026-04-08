const express = require('express');
const router = express.Router();
const Appointment = require('../models/Appointment');

// Get all appointments
router.get('/', async (req, res) => {
    try {
        const appointments = await Appointment.find().sort({ appointmentDate: -1 });
        res.json(appointments);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get appointment by ID
router.get('/:id', async (req, res) => {
    try {
        const appointment = await Appointment.findById(req.params.id);
        if (!appointment) {
            return res.status(404).json({ error: 'Appointment not found' });
        }
        res.json(appointment);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Create new appointment
router.post('/', async (req, res) => {
    try {
        const appointment = new Appointment(req.body);
        await appointment.save();
        
        // Send reminder to RabbitMQ queue (legacy VM 3 worker)
        if (req.app.locals.publishToQueue) {
            req.app.locals.publishToQueue('appointment_reminders', {
                appointmentId: appointment._id,
                patientName: appointment.patientName,
                appointmentDate: appointment.appointmentDate,
                vetName: appointment.vetName
            });
        }
        
        res.status(201).json(appointment);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Update appointment
router.put('/:id', async (req, res) => {
    try {
        req.body.updatedAt = Date.now();
        const appointment = await Appointment.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );
        if (!appointment) {
            return res.status(404).json({ error: 'Appointment not found' });
        }
        res.json(appointment);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Delete appointment
router.delete('/:id', async (req, res) => {
    try {
        const appointment = await Appointment.findByIdAndDelete(req.params.id);
        if (!appointment) {
            return res.status(404).json({ error: 'Appointment not found' });
        }
        res.json({ message: 'Appointment deleted successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
