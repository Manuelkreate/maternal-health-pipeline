from fastapi import APIRouter, HTTPException, Query #type: ignore
from google.cloud import bigquery
from typing import Optional
from api.bigquery import get_bigquery_client
from api.constants import VALID_SURVEY_PERIODS
client = get_bigquery_client()

# initialize router
router = APIRouter()

# define view ID
TABLE_ID = 'maternal-health-pipeline.maternal_health_dbt.mart_nigeria_health_spending'

@router.get('/country/health-spending')
async def get_health_spending(
    # optional parameters
    survey_period: Optional[str] = Query(default=None, description='Filter by survey_period')
):
    """
    Queries BigQuery for Nigeria's years of health spending data, optionally filtering by the survey_period
    """
    try:
        # validation

        if survey_period and survey_period not in VALID_SURVEY_PERIODS:
            raise HTTPException(
                status_code=422,
                detail=f"Invalid survey_period. Valid values: {VALID_SURVEY_PERIODS}"
            )     
            
        # sql query
        sql = f'SELECT * FROM `{TABLE_ID}` WHERE 1=1'

        # list of query parameters/columns
        query_parameters = []

        if survey_period:
            sql += ' AND survey_period = @survey_period'
            query_parameters.append(
                bigquery.ScalarQueryParameter('survey_period', 'STRING', survey_period)
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