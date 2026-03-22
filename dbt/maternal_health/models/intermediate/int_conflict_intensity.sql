WITH base AS (
    SELECT
        state_name,
        event_year,
        fatalities,
        disorder_type,
        event_type
    FROM {{ ref('stg_acled_conflict')}}
),

aggregated AS (
    SELECT
        state_name,
        event_year,
        COUNT(*)                            AS total_events,
        SUM(fatalities)                     AS sum_of_fatalities,
        SUM(CASE WHEN disorder_type = 'Political violence' 
            THEN 1 ELSE 0 END)              AS political_violence_event,
        SUM(CASE WHEN disorder_type = 'Strategic developments' 
            THEN 1 ELSE 0 END)              AS strategic_dev_event,
        SUM(CASE WHEN disorder_type = 'Demonstrations' 
            THEN 1 ELSE 0 END)              AS demonstrations_event,
        SUM(CASE WHEN disorder_type = 'Political violence; Demonstrations' 
            THEN 1 ELSE 0 END)              AS political_violence_demonstration_event    
    FROM base
    GROUP BY state_name, event_year
)

SELECT * FROM aggregated