const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const amqp = require('amqplib');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// MongoDB connection (hardcoded for legacy VM)
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/pawscare';
const RABBITMQ_URL = process.env.RABBITMQ_URL || 'amqp://guest:guest@10.0.1.30:5672';

let rabbitmqChannel = null;

// Connect to MongoDB
mongoose.connect(MONGODB_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
    useFindAndModify: false,
    useCreateIndex: true
})
.then(() => console.log('✓ Connected to MongoDB'))
.catch(err => console.error('MongoDB connection error:', err));

// Connect to RabbitMQ (legacy message queue on VM 3)
async function connectRabbitMQ() {
    try {
        const connection = await amqp.connect(RABBITMQ_URL);
        rabbitmqChannel = await connection.createChannel();
        await rabbitmqChannel.assertQueue('appointment_reminders', { durable: true });
        await rabbitmqChannel.assertQueue('lab_results', { durable: true });
        console.log('✓ Connected to RabbitMQ');
    } catch (err) {
        console.error('RabbitMQ connection error:', err.message);
        setTimeout(connectRabbitMQ, 5000); // Retry after 5 seconds
    }
}

connectRabbitMQ();

// Helper function to publish message to RabbitMQ
function publishToQueue(queueName, message) {
    if (rabbitmqChannel) {
        rabbitmqChannel.sendToQueue(queueName, Buffer.from(JSON.stringify(message)), {
            persistent: true
        });
    }
}

// Routes
const patientsRouter = require('./routes/patients');
const appointmentsRouter = require('./routes/appointments');
const prescriptionsRouter = require('./routes/prescriptions');
const labResultsRouter = require('./routes/labResults');

app.use('/api/patients', patientsRouter);
app.use('/api/appointments', appointmentsRouter);
app.use('/api/prescriptions', prescriptionsRouter);
app.use('/api/labresults', labResultsRouter);

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ 
        status: 'healthy', 
        mongodb: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected',
        rabbitmq: rabbitmqChannel ? 'connected' : 'disconnected'
    });
});

// Root endpoint
app.get('/', (req, res) => {
    res.json({ 
        message: 'PawsCare API Server (Legacy VM)',
        version: '1.0.0',
        vm: 'VM-2 (10.0.1.20)'
    });
});

// Export publishToQueue for use in routes
app.locals.publishToQueue = publishToQueue;

app.listen(PORT, () => {
    console.log(`🐾 PawsCare API Server running on port ${PORT}`);
    console.log(`📍 VM IP: 10.0.1.20 (simulated)`);
});

module.exports = app;
