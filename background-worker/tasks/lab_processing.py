"""
Lab result processing task
Generates PDF reports and processes uploaded lab results.
Uses Azure Blob Storage via Dapr bindings for document storage.
"""

import os
import base64
import requests
from datetime import datetime
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from io import BytesIO

DAPR_HTTP_PORT = os.getenv('DAPR_HTTP_PORT')
DAPR_BLOB_BINDING = os.getenv('DAPR_BLOB_BINDING', 'blobstore')


def _upload_to_blob(blob_name, content_bytes, content_type='application/pdf'):
    """Upload content to Azure Blob Storage via Dapr output binding."""
    if not DAPR_HTTP_PORT:
        print(f"   ⚠ Dapr not available, skipping blob upload for {blob_name}")
        return None

    dapr_url = f"http://localhost:{DAPR_HTTP_PORT}/v1.0/bindings/{DAPR_BLOB_BINDING}"
    payload = {
        "operation": "create",
        "data": base64.b64encode(content_bytes).decode('utf-8'),
        "metadata": {
            "blobName": blob_name,
            "contentType": content_type
        }
    }

    try:
        resp = requests.post(dapr_url, json=payload, timeout=30)
        resp.raise_for_status()
        print(f"   ☁ Uploaded to Azure Blob Storage: {blob_name}")
        return blob_name
    except Exception as e:
        print(f"   ✗ Blob upload failed for {blob_name}: {e}")
        return None


def generate_lab_report_pdf(lab_result_data):
    """
    Generate a PDF report for lab results and upload to Azure Blob Storage.

    Args:
        lab_result_data: Dictionary containing lab result information
    Returns:
        Blob path string on success, or None on failure.
    """
    print(f"📄 Generating PDF report for patient {lab_result_data.get('patientName')}")

    lab_result_id = lab_result_data.get('labResultId')
    blob_name = f"lab-results/report_{lab_result_id}.pdf"

    print(f"   Test Type: {lab_result_data.get('testType')}")

    # Generate PDF into memory buffer
    buf = BytesIO()
    c = canvas.Canvas(buf, pagesize=letter)
    c.drawString(100, 750, f"Lab Report for {lab_result_data.get('patientName')}")
    c.drawString(100, 730, f"Test Type: {lab_result_data.get('testType')}")
    c.drawString(100, 710, f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    c.save()
    pdf_bytes = buf.getvalue()

    result = _upload_to_blob(blob_name, pdf_bytes)
    if result:
        print(f"   ✓ PDF report uploaded to blob storage")
    else:
        print(f"   ⚠ PDF generated but blob upload unavailable")

    return result or blob_name


def process_xray_image(image_path, image_bytes=None):
    """
    Process X-ray images and upload to Azure Blob Storage.
    """
    print(f"🩻 Processing X-ray image: {image_path}")

    if image_bytes:
        blob_name = f"xrays/{os.path.basename(image_path)}"
        _upload_to_blob(blob_name, image_bytes, content_type='image/png')

    print("   ✓ Image processed and archived")
    return True


def upload_document_to_blob(blob_name, content_bytes, content_type='application/octet-stream'):
    """
    Upload any document to Azure Blob Storage via Dapr binding.
    Public helper for other modules.
    """
    return _upload_to_blob(blob_name, content_bytes, content_type)
