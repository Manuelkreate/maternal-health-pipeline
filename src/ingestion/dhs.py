import pandas as pd
import json
import os
import math
from datetime import datetime
from src.utils import upload_to_gcs

# DHS file registry for years and file types
DHS_FILE_REGISTRY = {
    2018: {
        "ir": r"C:\Users\USER\Documents\DHS-data\2018\NGIR7BDT\NGIR7BFL.DTA",
        "br": r"C:\Users\USER\Documents\DHS-data\2018\NGBR7BDT\NGBR7BFL.DTA",
    },
    2024: {
        "ir": r"C:\Users\USER\Documents\DHS-data\2024\NGIR8BDT\NGIR8BFL.dta",
        "br": r"C:\Users\USER\Documents\DHS-data\2024\NGBR8BDT\NGBR8BFL.dta",
        "nr": r"C:\Users\USER\Documents\DHS-data\2024\NGNR8BDT\NGNR8BFL.dta",
    }    
}

# Column mappings for each DHS file type
IR_COLUMNS = [
    'caseid', 'v000', 'v001', 'v002', 'v003', 'v005',
    'v012', 'v024', 'v025', 'v190', 'v501', 'v481',
    'm14_1', 'm15_1', 'm3a_1', 'm3b_1', 'm3c_1',
    'm57a_1', 'm57b_1', 'm70_1', 'm72_1', 'mm1_01', 
    'mm1_02', 'mm1_03', 'mm1_04', 'mm1_05', 'mm2_01',
    'mm2_02', 'mm2_03', 'mm2_04', 'mm2_05', 'mm7_01',
    'mm7_02', 'mm7_03', 'mm7_04', 'mm7_05', 'mm9_01',
    'mm9_02', 'mm9_03', 'mm9_04', 'mm9_05', 'mm15_01',
    'mm15_02', 'mm15_03', 'mm15_04', 'mm15_05',
    'sstate', 'szone'
]

BR_COLUMNS = [
    'caseid', 'v000', 'v001', 'v002', 'v003', 'v005',
    'v024', 'v025','bidx','bord','b2','b4','b5','b6',
    'b7','b11', 'sstate', 'm14', 'm15', 'm3a', 'm3b', 'm3c'
]

NR_COLUMNS = [
    'caseid', 'v000', 'v001', 'v005',
    'v024', 'v025','pidx', 'm1','m14',
    'm15','m3a','m3b','m3c','m57a', 
    'm57b','m70','m72','sstate', 'szone'
]
# Map file types to their respective columns for filtering
COLUMN_MAP = {
    "ir": IR_COLUMNS,
    "br": BR_COLUMNS,
    "nr": NR_COLUMNS
}

# DHS Ingestion Script
def ingest_dhs(years=None):
    # If no specific years are provided, ingest all registered years
    if years is None:
        years = list(DHS_FILE_REGISTRY.keys())

    today = datetime.utcnow().strftime("%Y-%m-%d")

    # Loop through each specified year and file type, process the data, and upload to GCS
    for year in years:
        if year not in DHS_FILE_REGISTRY:
            raise ValueError(f"No DHS files registered for year: {year}")

        # Process each file type for the given year
        for file_type, file_path in DHS_FILE_REGISTRY[year].items():
            if not os.path.exists(file_path):
                raise FileNotFoundError(f"DHS file not found: {file_path}")

            df = pd.read_stata(file_path, convert_categoricals=False)

            if df.empty:
                raise ValueError(f"DHS file loaded but contains no data: {year} {file_type}")

            # Filter the DataFrame to include only the relevant columns for the file type
            cols = [c for c in COLUMN_MAP[file_type] if c in df.columns]
            df = df[cols]

            # Convert the DataFrame to a newline-delimited JSON string for uploading
            records = df.to_dict(orient="records")
            cleaned = [
                {k: (None if isinstance(v, float) and math.isnan(v) else v) for k, v in record.items()}
                for record in records
            ]
            data = "\n".join(json.dumps(record) for record in cleaned)
            
            # Generate destination path
            destination_path = f"dhs/raw/{file_type}/{year}/{today}.json"

            upload_to_gcs(data=data, destination_path=destination_path)
            print(f"DHS ingestion complete for {year} {file_type}")
