from fastapi import APIRouter, HTTPException, Query #type: ignore
from google.cloud import bigquery
from typing import Optional
from api.bigquery import get_bigquery_client
from api.constants import (VALID_SURVEY_YEARS, VALID_ZONES, VALID_WEALTH_INDEX)

client = get_bigquery_client()

# initialize router
router = APIRouter()

# define view ID
VIEW_ID = 'maternal-health-pipeline.maternal_health_dbt.int_wealth_delivery'

@router.get('/states/wealth-delivery')
async def get_wealth_delivery(
    # optional parameters
    state_name: Optional[str] = Query(default=None, description='Filter by state_name'),
    survey_year: Optional[int] = Query(default=None, description='Filter by survey_year'),
    zone: Optional[str] = Query(default=None, description='Filter by zone'),
    wealth_index: Optional[str] = Query(default=None, description='Filter by wealth_index')
):
    """
    Queries BigQuery for wealth vs delivery data, optionally filtering by state names, survey year, zone, and wealth index
    """
    try:
        # validation

        if survey_year and survey_year not in VALID_SURVEY_YEARS:
            raise HTTPException(
                status_code=422,
                detail=f"Invalid survey_year. Valid values: {VALID_SURVEY_YEARS}"
            ) 

        if zone and zone not in VALID_ZONES:
            raise HTTPException(
                status_code=422,
                detail=f"Invalid zone. Valid values: {VALID_ZONES}"
            )
        
        if wealth_index and wealth_index not in VALID_WEALTH_INDEX:
            raise HTTPException(
                status_code=422,
                detail=f"Invalid wealth_index. Valid values: {VALID_WEALTH_INDEX}"
            )  
                      
        # sql query
        sql = f'SELECT * FROM `{VIEW_ID}` WHERE 1=1'

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

        if wealth_index:
            sql += ' AND wealth_index = @wealth_index'
            query_parameters.append(
                bigquery.ScalarQueryParameter('wealth_index', 'STRING', wealth_index)
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