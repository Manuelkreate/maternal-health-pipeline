import requests
import json
import os
from datetime import datetime
from src.utils import upload_to_gcs

# World Bank Ingestion Script
def ingest_worldbank():
    # Define the indicators to fetch with their corresponding World Bank codes
    indicators={
        "health_expenditure_per_capita": "SH.XPD.CHEX.PC.CD",
        "out_of_pocket_health_expenditure": "SH.XPD.OOPC.CH.ZS",
        "population": "SP.POP.TOTL",
    }

    # Base URL for World Bank API
    base_url = "https://api.worldbank.org/v2/country/NG/indicator"

    current_year = datetime.utcnow().year
    today = datetime.utcnow().strftime("%Y-%m-%d")

    # Loop through each indicator, fetch data, and upload to GCS
    for indicator_name, indicator_code in indicators.items():
        # Fetch data from World Bank API for the specified indicator and date range
        response = requests.get(
            f"{base_url}/{indicator_code}",
            params={
                "format": "json",
                "date": f"2013:{current_year}",
                "per_page": 100
            }
        )

        # Check if the API request was successful
        if response.status_code != 200:
            raise Exception(f"World Bank fetch failed for {indicator_name}: {response.text}")
        
        # Convert the list of records to a newline-delimited JSON string for uploading
        records = response.json()[1]
        data = "\n".join(json.dumps(record) for record in records)

        # Generate destination path with current date and indicator name
        destination_path = f"worldbank/raw/{indicator_name}/{today}.json"

        # Upload the data to Google Cloud Storage
        upload_to_gcs(data=data, destination_path=destination_path)
        print(f"World Bank ingestion complete for {indicator_name}")