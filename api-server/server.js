const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const amqp = require('amqplib');
const { isDaprEnabled, publishEvent } = require('./dapr-client');

const app = express();
const PORT = process.env.PORT || 3000;
const USE_DAPR = isDaprEnabled();

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

// --- Messaging: Dapr pub/sub or legacy RabbitMQ ---

if (USE_DAPR) {
    console.log(`✓ Dapr sidecar detected (HTTP port: ${process.env.DAPR_HTTP_PORT}). Using Dapr pub/sub.`);
} else {
    // Connect to RabbitMQ (legacy message queue on VM 3)
    async function connectRabbitMQ() {
        try {
            const connection = await amqp.connect(RABBITMQ_URL);
            rabbitmqChannel = await connection.createChannel();
            await rabbitmqChannel.assertQueue('appointment_reminders', { durable: true });
            await rabbitmqChannel.assertQueue('lab_results', { durable: true });
            console.log('✓ Connected to RabbitMQ (legacy mode)');
        } catch (err) {
            console.error('RabbitMQ connection error:', err.message);
            setTimeout(connectRabbitMQ, 5000);
        }
    }
    connectRabbitMQ();
}

/**
 * Publish a message to a topic/queue.
 * Uses Dapr pub/sub when available, falls back to direct RabbitMQ.
 * @param {string} topicOrQueue - Topic/queue name
 * @param {object} message - Message payload
 * @returns {Promise<void>}
 */
async function publishMessage(topicOrQueue, message) {
    if (USE_DAPR) {
        try {
            await publishEvent('pubsub', topicOrQueue, message);
        } catch (err) {
            console.error(`Dapr publish error (${topicOrQueue}):`, err.message);
        }
    } else if (rabbitmqChannel) {
        rabbitmqChannel.sendToQueue(topicOrQueue, Buffer.from(JSON.stringify(message)), {
            persistent: true
        });
    }
}

// Legacy alias kept for backward compatibility with route handlers
function publishToQueue(queueName, message) {
    publishMessage(queueName, message).catch(err =>
        console.error(`publishToQueue error (${queueName}):`, err.message)
    );
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
        messaging: USE_DAPR ? 'dapr' : (rabbitmqChannel ? 'rabbitmq' : 'disconnected')
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
