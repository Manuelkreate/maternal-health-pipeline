import os
from google.cloud import bigquery
from google.oauth2 import service_account #type: ignore

# config
CREDENTIALS_PATH = os.getenv(
    'GOOGLE_APPLICATION_CREDENTIALS_LOCAL'
) or os.getenv(
    'GOOGLE_APPLICATION_CREDENTIALS'
)
PROJECT_ID = os.getenv('GCP_PROJECT_ID')

def get_bigquery_client():

    credentials = service_account.Credentials.from_service_account_file(
        CREDENTIALS_PATH,
        scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    ) 

    client = bigquery.Client(
        credentials=credentials,
        project=PROJECT_ID
    )
    
    return client
