import pandas as pd
import json
import os
from datetime import datetime
from src.utils import upload_to_gcs

# DHS Ingestion Script
def ingest_dhs():
    # Define the file paths for the DHS datasets
    files={
        "2018_ir": r"C:\Users\USER\Documents\DHS-data\2018\NGIR7BDT\NGIR7BFL.DTA",
        "2018_br": r"C:\Users\USER\Documents\DHS-data\2018\NGBR7BDT\NGBR7BFL.DTA",
        "2024_ir": r"C:\Users\USER\Documents\DHS-data\2024\NGIR8BDT\NGIR8BFL.dta",
        "2024_br": r"C:\Users\USER\Documents\DHS-data\2024\NGBR8BDT\NGBR8BFL.dta",
        "2024_nr": r"C:\Users\USER\Documents\DHS-data\2024\NGNR8BDT\NGNR8BFL.dta",
    }

    today = datetime.utcnow().strftime("%Y-%m-%d")
    # Define the columns to keep for each dataset type
    IR_COLUMNS = [
        'caseid', 'v000', 'v001', 'v002', 'v003', 'v005',
        'v012', 'v024', 'v025', 'v190', 'v501', 'v481',
        'm14_1', 'm15_1', 'm3a_1', 'm3b_1', 'm3c_1',
        'm57a_1', 'm57b_1', 'm70_1', 'm72_1',
        'sstate'
    ]

    BR_COLUMNS = [
        'caseid', 'v000', 'v001', 'v002', 'v003', 'v005',
        'v024', 'v025',
        'bidx_01', 'bord_01', 'b4_01', 'b5_01', 'b7_01',
        'sstate'
    ]

    NR_COLUMNS = [
        'caseid', 'v000', 'v001', 'v002', 'v003', 'v005',
        'v024', 'v025',
        'm14_1', 'm15_1', 'm3a_1', 'm3b_1', 'm3c_1',
        'm70_1', 'm72_1',
        'sstate'
    ]

    # Loop through each file, read it into a DataFrame, convert to JSON, and upload to GCS
    for file_key, file_path in files.items():
        # Validate that the file exists before attempting to read
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"DHS file not found: {file_path}")
                       
        df = pd.read_stata(file_path, convert_categoricals=False)

        # Validate that the DataFrame is not empty after loading
        if df.empty:
            raise ValueError(f"DHS file loaded but contains no data: {file_key}")
        
        # Select columns based on dataset type (IR, BR, NR)
        if 'ir' in file_key:
            cols = IR_COLUMNS
        elif 'br' in file_key:
            cols = BR_COLUMNS
        else:
            cols = NR_COLUMNS
        
        # Ensure that only existing columns are selected to avoid KeyErrors
        cols = [c for c in cols if c in df.columns]
        df = df[cols]
        
        # Convert the DataFrame to JSON string format for uploading
        data = df.to_json(orient="records")
        destination_path = f"dhs/raw/{file_key}/{today}.json"
        
        upload_to_gcs(data=data, destination_path=destination_path)
        print(f"DHS ingestion complete for {file_key}")