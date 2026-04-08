"""
Appointment reminder task
Sends email reminders to pet owners about upcoming appointments
"""

import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime


def send_appointment_reminder(appointment_data):
    """
    Send appointment reminder email
    
    Args:
        appointment_data: Dictionary containing appointment information
    """
    print(f"📧 Sending appointment reminder for {appointment_data.get('patientName')}")
    
    # Email configuration
    smtp_host = os.getenv('SMTP_HOST', 'smtp.mailtrap.io')
    smtp_port = int(os.getenv('SMTP_PORT', '2525'))
    smtp_user = os.getenv('SMTP_USER', 'testuser')
    smtp_password = os.getenv('SMTP_PASSWORD', 'testpass')
    
    # Create email message
    subject = f"Appointment Reminder for {appointment_data.get('patientName')}"
    
    body = f"""
    Dear Pet Owner,
    
    This is a reminder about your upcoming appointment at PawsCare Veterinary Network:
    
    Patient: {appointment_data.get('patientName')}
    Veterinarian: {appointment_data.get('vetName')}
    Date: {appointment_data.get('appointmentDate')}
    
    Please arrive 10 minutes early for check-in.
    
    If you need to reschedule, please contact us at (555) 123-4567.
    
    Best regards,
    PawsCare Veterinary Network
    """
    
    # In a real system, this would actually send the email
    # For the legacy demo, we just log it
    print(f"   Subject: {subject}")
    print(f"   To: owner@example.com")
    print(f"   ✓ Reminder email sent (simulated)")
    
    return True


def send_daily_reminder_batch():
    """
    Send batch of reminders for appointments in the next 24 hours
    This would be triggered by cron
    """
    print("📅 Processing daily reminder batch...")
    # In real implementation, would query API for upcoming appointments
    print("✓ Daily batch complete")
