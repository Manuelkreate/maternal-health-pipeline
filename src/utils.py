from google.cloud import storage
import os

def upload_to_gcs(data: str, destination_path: str, bucket_name: str = None):
    if bucket_name is None:
        bucket_name = os.getenv('GCS_BUCKET_NAME')
    if bucket_name is None:
        raise ValueError("No GCS bucket name provided and GCS_BUCKET_NAME not set in environment.")
    
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(destination_path)
    blob.upload_from_string(data)
    print(f"Uploaded to gcs://{bucket_name}/{destination_path}")