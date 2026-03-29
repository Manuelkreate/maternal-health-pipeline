import sys
# allow python read the right path in airflow
sys.path.insert(0, '/opt/airflow')
from airflow.models import DAG #type: ignore
from airflow.operators.bash import BashOperator #type: ignore
from datetime import datetime


default_args = {
    'owner': 'emmanuel',
    'email_on_failure': True,
    'email_on_retry': False,    
    'retries': 1
}

# define DAG
with DAG(
    dag_id='maternal_health_transformation', 
    default_args=default_args,
    start_date=datetime(2024, 1, 1), 
    schedule='@monthly', 
    catchup=False

# each dag run instance
) as dag:

    dbt_run = BashOperator(
        task_id='dbt_run',
        bash_command='dbt run --project-dir /opt/airflow/dbt/maternal_health --profiles-dir /home/airflow/.dbt',    
    )

    dbt_test = BashOperator(
        task_id='dbt_test',
        bash_command='dbt test --project-dir /opt/airflow/dbt/maternal_health --profiles-dir /home/airflow/.dbt',
    )

    dbt_run >> dbt_test