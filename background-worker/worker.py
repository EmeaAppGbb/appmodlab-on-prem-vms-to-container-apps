#!/usr/bin/env python3
"""
PawsCare Background Worker - Legacy VM 3
Handles appointment reminders and lab result processing via RabbitMQ
"""

import os
import sys
import time
import json
import pika
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

print(f"🐾 PawsCare Background Worker (Legacy VM 3)")
print(f"📍 VM IP: 10.0.1.30 (simulated)")
print(f"🔗 RabbitMQ: {RABBITMQ_HOST}:{RABBITMQ_PORT}")
print(f"🔗 API Server: {API_SERVER_URL}")


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
    """Process appointment reminder messages"""
    try:
        data = json.loads(body)
        print(f"\n📧 Processing appointment reminder:")
        print(f"   Patient: {data.get('patientName')}")
        print(f"   Vet: {data.get('vetName')}")
        print(f"   Date: {data.get('appointmentDate')}")
        
        # Simulate sending email reminder
        print(f"   ✓ Email reminder sent (simulated via {SMTP_HOST})")
        
        # In a real system, this would send an actual email
        # send_email_reminder(data)
        
        ch.basic_ack(delivery_tag=method.delivery_tag)
        print(f"   ✓ Reminder processed successfully")
        
    except Exception as e:
        print(f"   ✗ Error processing reminder: {e}")
        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)


def process_lab_result(ch, method, properties, body):
    """Process lab result messages"""
    try:
        data = json.loads(body)
        print(f"\n🔬 Processing lab result:")
        print(f"   Patient: {data.get('patientName')}")
        print(f"   Test Type: {data.get('testType')}")
        print(f"   File: {data.get('filePath')}")
        
        # Simulate generating PDF report
        print(f"   ⚙ Generating PDF report...")
        time.sleep(2)  # Simulate processing time
        print(f"   ✓ PDF report generated")
        
        # Simulate copying to SMB share
        print(f"   📁 Copying to SMB share (\\\\10.0.1.10\\documents)")
        print(f"   ✓ File copied to shared storage")
        
        ch.basic_ack(delivery_tag=method.delivery_tag)
        print(f"   ✓ Lab result processed successfully")
        
    except Exception as e:
        print(f"   ✗ Error processing lab result: {e}")
        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)


def main():
    """Main worker loop"""
    print("\n🚀 Starting background worker...")
    
    # Connect to RabbitMQ
    connection = connect_rabbitmq()
    channel = connection.channel()
    
    # Declare queues
    channel.queue_declare(queue='appointment_reminders', durable=True)
    channel.queue_declare(queue='lab_results', durable=True)
    
    # Set prefetch count
    channel.basic_qos(prefetch_count=1)
    
    # Set up consumers
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


if __name__ == '__main__':
    main()
