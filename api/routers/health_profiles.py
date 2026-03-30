from fastapi import APIRouter, HTTPException, Query #type: ignore
from google.cloud import bigquery
from typing import Optional
from api.bigquery import get_bigquery_client
client = get_bigquery_client()

# initialize router
router = APIRouter()

# define Table ID
TABLE_ID = 'maternal-health-pipeline.maternal_health_dbt.mart_state_health_profile'

@router.get('/states/health-profiles')
async def get_health_profiles(
    # optional parameters
    state_name: Optional[str] = Query(default=None, description='Filter by state_name'),
    survey_year: Optional[int] = Query(default=None, description='Filter by survey_year'),
    zone: Optional[str] = Query(default=None, description='Filter by zone'), 
):
    """
    Queries BigQuery for state names, optionally filtering by survey year and zone
    """
    try:
        # sql query
        sql = f'SELECT * FROM `{TABLE_ID}` WHERE 1=1'

        # list of query parameters/columns
        query_parameters = []

        if state_name:
            sql+= ' AND state_name = @state_name'
            query_parameters.append(
                bigquery.ScalarQueryParameter('state_name', 'STRING', state_name)
            )

        if survey_year:
            sql += ' AND survey_year = @survey_year'
            query_parameters.append(
                bigquery.ScalarQueryParameter('survey_year', 'INT64', survey_year)
            )
        if zone:
            sql += ' AND zone = @zone'
            query_parameters.append(
                bigquery.ScalarQueryParameter('zone', 'STRING', zone)
            )  

        # job conig
        job_config = bigquery.QueryJobConfig(query_parameters=query_parameters)

        # execute query
        query_job = client.query(sql, job_config=job_config)

        # convert rows into list of dictionaries
        results = [dict(row) for row in query_job]

        if not results:
            raise HTTPException(status_code=404, detail="No data found...")
        return results
    
    except HTTPException:
        raise  # FastAPI handle it as-is    

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))         