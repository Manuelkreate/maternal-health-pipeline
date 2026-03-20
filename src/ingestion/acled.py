import requests
import json
import os
from datetime import datetime
from src.utils import upload_to_gcs

# ACLED Ingestion Script
def ingest_acled():
    # Load ACLED credentials from environment variables
    email = os.getenv("ACLED_EMAIL")
    password = os.getenv("ACLED_PASSWORD")
    
    # Validate credentials
    if not email or not password:
        raise ValueError("ACLED_EMAIL and ACLED_PASSWORD must be set in environment.")
    
    # Authenticate with ACLED API to get access token
    token_response = requests.post(
        "https://acleddata.com/oauth/token",
        data={
            "username": email,
            "password": password,
            "grant_type": "password",
            "client_id": "acled"
        }
    )

    # Check if authentication was successful
    if token_response.status_code != 200:
        raise Exception(f"ACLED authentication failed: {token_response.text}") 
    
    # Extract access token from response
    access_token = token_response.json()["access_token"]
    print(f"Token received: {access_token[:20]}...")

    # Fetch ACLED data for Nigeria with specified fields
    response = requests.get(
        "https://acleddata.com/api/acled/read",
        headers={
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        },
        params={
            "country": "Nigeria",
            "fields": "event_id_cnty|disorder_type|event_date|event_type|sub_event_type|actor1|inter1|actor2|inter2|admin1|admin2|location|latitude|longitude|fatalities|year",
            "_format": "json"
        }
    )

    # Check if data fetch was successful
    if response.status_code != 200:
        raise Exception(f"ACLED data fetch failed: {response.text}")
    
    # Convert the list of records to a newline-delimited JSON string for uploading
    records = response.json()["data"]
    data = "\n".join(json.dumps(record) for record in records)

    # Generate destination path with current date
    today = datetime.utcnow().strftime("%Y-%m-%d")
    destination_path = f"acled/raw/{today}.json"

    # Upload data to Google Cloud Storage
    upload_to_gcs(data=data, destination_path=destination_path)
    print(f"ACLED ingestion completed for {today} and uploaded to {destination_path}")