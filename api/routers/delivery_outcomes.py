from fastapi import APIRouter, HTTPException, Query #type: ignore
from google.cloud import bigquery
from typing import Optional
from api.bigquery import get_bigquery_client
client = get_bigquery_client()

# initialize router
router = APIRouter()

# define view ID
VIEW_ID = 'maternal-health-pipeline.maternal_health_dbt.int_delivery_outcomes'

@router.get('/states/delivery-outcomes')
async def get_delivery_outcomes(
    # optional parameters
    state_name: Optional[str] = Query(default=None, description='Filter by state_name'),    
    survey_year: Optional[int] = Query(default=None, description='Filter by survey_year'),
    zone: Optional[str] = Query(default=None, description='Filter by zone'),
    place_of_delivery_category: Optional[str] = Query(default=None, description='Filter by place_of_delivery'),	
    birth_attendant_category: Optional[str] = Query(default=None, description='Filter by birth_attendant_category'),	
    anc_adequacy: Optional[str] = Query(default=None, description='Filter by anc_adequacy') 
):
    """
    Queries BigQuery for state names, optionally filtering by survey year, zone, place of delivery, birth attendant, and anc adequacy
    """
    try:
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

        if place_of_delivery_category:
            sql += ' AND place_of_delivery_category = @place_of_delivery_category'
            query_parameters.append(
                bigquery.ScalarQueryParameter('place_of_delivery_category', 'STRING', place_of_delivery_category)
            )

        if birth_attendant_category:
            sql += ' AND birth_attendant_category = @birth_attendant_category'
            query_parameters.append(
                bigquery.ScalarQueryParameter('birth_attendant_category', 'STRING', birth_attendant_category)
            )

        if anc_adequacy:
            sql += ' AND anc_adequacy = @anc_adequacy'
            query_parameters.append(
                bigquery.ScalarQueryParameter('anc_adequacy', 'STRING', anc_adequacy)
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