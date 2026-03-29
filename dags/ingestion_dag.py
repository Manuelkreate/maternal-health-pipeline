import sys
# allow python read the right path in airflow
sys.path.insert(0, '/opt/airflow')  
# import ingestion scripts
from src.ingestion.acled import ingest_acled
from src.ingestion.dhs import ingest_dhs
from src.ingestion.worldbank import ingest_worldbank
from load_to_bigquery import main as load_to_bigquery
# import airflow modules
from airflow.models import DAG #type: ignore
from airflow.operators.python import PythonOperator #type: ignore
from airflow.operators.trigger_dagrun import TriggerDagRunOperator #type: ignore
from datetime import datetime

default_args = {
    'owner': 'emmanuel',
    'email_on_failure': True,
    'email_on_retry': False,    
    'retries': 1
}

# define DAG
with DAG(
    dag_id='maternal_health_ingest', 
    default_args=default_args,
    start_date=datetime(2024, 1, 1), 
    schedule='@monthly', 
    catchup=False

# each dag run instance
) as dag:

    acled = PythonOperator(
        task_id='ingest_acled_task',
        python_callable=ingest_acled,    
    )

    dhs = PythonOperator(
        task_id='ingest_dhs_task',
        python_callable=ingest_dhs,
    )

    worldbank = PythonOperator(
        task_id='ingest_worldbank_task',
        python_callable=ingest_worldbank,
    )

    bigquery = PythonOperator(
        task_id='load_bigquery_task',
        python_callable=load_to_bigquery,
        trigger_rule='all_success',
    )

    trigger = TriggerDagRunOperator(
        task_id='trigger_transformation_dag',
        trigger_dag_id='maternal_health_transformation',
        wait_for_completion=True,
    )

    # order of run
    [acled, dhs, worldbank] >> bigquery >> trigger

    