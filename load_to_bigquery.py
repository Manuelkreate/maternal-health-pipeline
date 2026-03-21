import os
from dotenv import load_dotenv # type: ignore
from google.cloud import bigquery, storage
import json

load_dotenv()

# Global configuration for BigQuery and GCS
PROJECT_ID = os.getenv("GCP_PROJECT_ID")
BUCKET_NAME = os.getenv("GCS_BUCKET_NAME")
DATASET_ID = "raw"

NON_DHS_SOURCES = {
    "acled": "acled/raw/",
    "worldbank_health_expenditure": "worldbank/raw/health_expenditure_per_capita/",
    "worldbank_oop_expenditure": "worldbank/raw/out_of_pocket_health_expenditure/",
    "worldbank_population": "worldbank/raw/population/",
}

# Get latest versions of files in GCS for a given type
def get_latest_gcs_file(prefix):
    client = storage.Client()
    blobs = list(client.list_blobs(BUCKET_NAME, prefix=prefix))
    if not blobs:
        raise FileNotFoundError(f"No files found in GCS under prefix: {prefix}")
    latest = sorted(blobs, key=lambda b: b.name)[-1]
    return f"gs://{BUCKET_NAME}/{latest.name}"

# Scan GCS for all dhs/raw/{file_type}/{year}/ paths and build table names dynamically
def discover_dhs_sources():
    client = storage.Client()
    sources = {}
    file_types = ["ir", "br", "nr"]
    for file_type in file_types:
        prefix = f"dhs/raw/{file_type}/"
        blobs = list(client.list_blobs(BUCKET_NAME, prefix=prefix))
        years = set()
        for blob in blobs:
            parts = blob.name.split("/")
            if len(parts) >= 4:
                years.add(parts[3])
        for year in years:
            table_name = f"dhs_{file_type}_{year}"
            sources[table_name] = f"dhs/raw/{file_type}/{year}/"
    return sources

# Load data from GCS into BigQuery
def load_gcs_to_bigquery(gcs_uri, table_id):
    client = bigquery.Client(project=PROJECT_ID)
    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
        autodetect=True,
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE
    )
    load_job = client.load_table_from_uri(
        gcs_uri,
        table_id,
        job_config=job_config
    )
    load_job.result()
    print(f"Loaded {gcs_uri} into {table_id}")

# Load all sources into BigQuery
def main():
    all_sources = {**NON_DHS_SOURCES, **discover_dhs_sources()}

    for table_name, prefix in all_sources.items():
        gcs_uri = get_latest_gcs_file(prefix)
        table_id = f"{PROJECT_ID}.{DATASET_ID}.{table_name}"
        load_gcs_to_bigquery(gcs_uri, table_id)


if __name__ == "__main__":
    main()