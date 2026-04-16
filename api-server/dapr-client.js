/**
 * Dapr HTTP API client helpers for service invocation and pub/sub.
 * Used when DAPR_HTTP_PORT is set (i.e., running with a Dapr sidecar).
 */

const http = require('http');

const DAPR_HTTP_PORT = process.env.DAPR_HTTP_PORT;
const DAPR_BASE_URL = `http://localhost:${DAPR_HTTP_PORT}`;

/**
 * Check if Dapr sidecar is available.
 */
function isDaprEnabled() {
    return !!DAPR_HTTP_PORT;
}

/**
 * Publish an event to a Dapr pub/sub topic.
 * @param {string} pubsubName - Name of the pub/sub component (e.g., 'pubsub')
 * @param {string} topic - Topic name (e.g., 'appointment_reminders')
 * @param {object} data - Event payload
 * @returns {Promise<void>}
 */
async function publishEvent(pubsubName, topic, data) {
    const url = `${DAPR_BASE_URL}/v1.0/publish/${pubsubName}/${topic}`;
    const body = JSON.stringify(data);

    const response = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body
    });

    if (!response.ok) {
        const text = await response.text();
        throw new Error(`Dapr publish failed (${response.status}): ${text}`);
    }
}

/**
 * Invoke a method on another service via Dapr service invocation.
 * @param {string} appId - Target service app ID
 * @param {string} method - Method/path to invoke (e.g., 'api/patients')
 * @param {object} [options] - Request options
 * @param {string} [options.httpMethod='GET'] - HTTP method
 * @param {object} [options.data] - Request body for POST/PUT
 * @returns {Promise<object>} Response data
 */
async function invokeService(appId, method, options = {}) {
    const httpMethod = options.httpMethod || 'GET';
    const url = `${DAPR_BASE_URL}/v1.0/invoke/${appId}/method/${method}`;

    const fetchOptions = {
        method: httpMethod,
        headers: { 'Content-Type': 'application/json' }
    };

    if (options.data && (httpMethod === 'POST' || httpMethod === 'PUT')) {
        fetchOptions.body = JSON.stringify(options.data);
    }

    const response = await fetch(url, fetchOptions);

    if (!response.ok) {
        const text = await response.text();
        throw new Error(`Dapr invoke failed (${response.status}): ${text}`);
    }

    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
        return response.json();
    }
    return response.text();
}

module.exports = {
    isDaprEnabled,
    publishEvent,
    invokeService
};
