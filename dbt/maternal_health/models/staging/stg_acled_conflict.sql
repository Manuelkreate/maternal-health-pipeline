WITH source AS (
    SELECT * FROM {{ source('raw', 'acled') }}
),

renamed AS (
    SELECT
        event_id_cnty               AS event_id,
        CAST(event_date AS DATE)    AS event_date,
        year                        AS event_year,
        disorder_type,
        event_type,
        sub_event_type,
        actor1,
        inter1                      AS actor1_type,
        actor2,
        inter2                      AS actor2_type,
        admin1                      AS state_name,
        admin2                      AS lga_name,
        location,
        latitude,
        longitude,
        COALESCE(fatalities, 0)     AS fatalities
    FROM source
    WHERE admin1 IS NOT NULL
)

SELECT * FROM renamed