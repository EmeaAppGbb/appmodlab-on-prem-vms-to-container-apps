#!/usr/bin/env python3
"""
PawsCare Background Worker - Legacy VM 3
Handles appointment reminders and lab result processing.
Supports Dapr pub/sub (when DAPR_HTTP_PORT is set) or direct RabbitMQ (legacy).
"""

import os
import sys
import time
import json
import requests
from datetime import datetime

# Configuration from environment variables (hardcoded IPs for legacy VM)
RABBITMQ_HOST = os.getenv('RABBITMQ_HOST', 'localhost')
RABBITMQ_PORT = int(os.getenv('RABBITMQ_PORT', '5672'))
RABBITMQ_USER = os.getenv('RABBITMQ_USER', 'guest')
RABBITMQ_PASSWORD = os.getenv('RABBITMQ_PASSWORD', 'guest')

API_SERVER_URL = os.getenv('API_SERVER_URL', 'http://10.0.1.20:3000')
SMTP_HOST = os.getenv('SMTP_HOST', 'smtp.mailtrap.io')
SMTP_PORT = int(os.getenv('SMTP_PORT', '2525'))

DAPR_HTTP_PORT = os.getenv('DAPR_HTTP_PORT')
APP_PORT = int(os.getenv('APP_PORT', '8080'))

print(f"🐾 PawsCare Background Worker")
print(f"📍 VM IP: 10.0.1.30 (simulated)")
print(f"🔗 API Server: {API_SERVER_URL}")

if DAPR_HTTP_PORT:
    print(f"✓ Dapr sidecar detected (HTTP port: {DAPR_HTTP_PORT}). Using Dapr pub/sub.")
else:
    print(f"🔗 RabbitMQ: {RABBITMQ_HOST}:{RABBITMQ_PORT} (legacy mode)")


# --- Shared message processing logic ---

def handle_appointment_reminder(data):
    """Process appointment reminder messages"""
    print(f"\n📧 Processing appointment reminder:")
    print(f"   Patient: {data.get('patientName')}")
    print(f"   Vet: {data.get('vetName')}")
    print(f"   Date: {data.get('appointmentDate')}")
    print(f"   ✓ Email reminder sent (simulated via {SMTP_HOST})")
    print(f"   ✓ Reminder processed successfully")


def handle_lab_result(data):
    """Process lab result messages"""
    print(f"\n🔬 Processing lab result:")
    print(f"   Patient: {data.get('patientName')}")
    print(f"   Test Type: {data.get('testType')}")
    print(f"   File: {data.get('filePath')}")
    print(f"   ⚙ Generating PDF report...")
    time.sleep(2)  # Simulate processing time
    print(f"   ✓ PDF report generated")
    print(f"   📁 Copying to SMB share (\\\\10.0.1.10\\documents)")
    print(f"   ✓ File copied to shared storage")
    print(f"   ✓ Lab result processed successfully")


# --- Dapr mode: Flask HTTP endpoints for pub/sub subscriptions ---

def run_dapr_mode():
    """Run worker with Flask HTTP server for Dapr pub/sub subscriptions."""
    from flask import Flask, request, jsonify

    app = Flask(__name__)

    @app.route('/dapr/subscribe', methods=['GET'])
    def subscribe():
        """Return Dapr subscription configuration."""
        subscriptions = [
            {
                'pubsubname': 'pubsub',
                'topic': 'appointment_reminders',
                'route': '/events/appointment_reminders'
            },
            {
                'pubsubname': 'pubsub',
                'topic': 'lab_results',
                'route': '/events/lab_results'
            }
        ]
        return jsonify(subscriptions)

    @app.route('/events/appointment_reminders', methods=['POST'])
    def on_appointment_reminder():
        """Handle appointment reminder events from Dapr pub/sub."""
        envelope = request.get_json(silent=True) or {}
        # Dapr sends CloudEvents; payload is in the 'data' field
        data = envelope.get('data', envelope)
        try:
            handle_appointment_reminder(data)
            return jsonify({'status': 'SUCCESS'}), 200
        except Exception as e:
            print(f"   ✗ Error processing reminder: {e}")
            return jsonify({'status': 'DROP'}), 200

    @app.route('/events/lab_results', methods=['POST'])
    def on_lab_result():
        """Handle lab result events from Dapr pub/sub."""
        envelope = request.get_json(silent=True) or {}
        data = envelope.get('data', envelope)
        try:
            handle_lab_result(data)
            return jsonify({'status': 'SUCCESS'}), 200
        except Exception as e:
            print(f"   ✗ Error processing lab result: {e}")
            return jsonify({'status': 'DROP'}), 200

    @app.route('/health', methods=['GET'])
    def health():
        return jsonify({'status': 'healthy', 'mode': 'dapr'}), 200

    print(f"\n🚀 Starting Dapr subscriber on port {APP_PORT}...")
    print(f"📬 Topics: appointment_reminders, lab_results")
    app.run(host='0.0.0.0', port=APP_PORT)


# --- Legacy mode: direct RabbitMQ pika consumption ---

def run_legacy_mode():
    """Run worker with direct RabbitMQ pika consumption (legacy)."""
    import pika

    def connect_rabbitmq(max_retries=10):
        """Connect to RabbitMQ with retries"""
        credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASSWORD)
        parameters = pika.ConnectionParameters(
            host=RABBITMQ_HOST,
            port=RABBITMQ_PORT,
            credentials=credentials,
            heartbeat=600,
            blocked_connection_timeout=300
        )

        for attempt in range(max_retries):
            try:
                connection = pika.BlockingConnection(parameters)
                print(f"✓ Connected to RabbitMQ")
                return connection
            except Exception as e:
                print(f"⚠ RabbitMQ connection attempt {attempt + 1}/{max_retries} failed: {e}")
                if attempt < max_retries - 1:
                    time.sleep(5)
                else:
                    raise

    def process_appointment_reminder(ch, method, properties, body):
        try:
            data = json.loads(body)
            handle_appointment_reminder(data)
            ch.basic_ack(delivery_tag=method.delivery_tag)
        except Exception as e:
            print(f"   ✗ Error processing reminder: {e}")
            ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)

    def process_lab_result(ch, method, properties, body):
        try:
            data = json.loads(body)
            handle_lab_result(data)
            ch.basic_ack(delivery_tag=method.delivery_tag)
        except Exception as e:
            print(f"   ✗ Error processing lab result: {e}")
            ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)

    print("\n🚀 Starting background worker (legacy RabbitMQ mode)...")

    connection = connect_rabbitmq()
    channel = connection.channel()

    channel.queue_declare(queue='appointment_reminders', durable=True)
    channel.queue_declare(queue='lab_results', durable=True)
    channel.basic_qos(prefetch_count=1)

    channel.basic_consume(
        queue='appointment_reminders',
        on_message_callback=process_appointment_reminder
    )
    channel.basic_consume(
        queue='lab_results',
        on_message_callback=process_lab_result
    )

    print("\n✓ Worker ready and listening for messages...")
    print("📬 Queues: appointment_reminders, lab_results")
    print("\nPress CTRL+C to exit\n")

    try:
        channel.start_consuming()
    except KeyboardInterrupt:
        print("\n\n⚠ Shutting down worker...")
        channel.stop_consuming()
        connection.close()
        print("✓ Worker stopped")
        sys.exit(0)
    except Exception as e:
        print(f"\n✗ Worker error: {e}")
        sys.exit(1)


def main():
    """Main entry point - select Dapr or legacy mode."""
    if DAPR_HTTP_PORT:
        run_dapr_mode()
    else:
        run_legacy_mode()


if __name__ == '__main__':
    main()
