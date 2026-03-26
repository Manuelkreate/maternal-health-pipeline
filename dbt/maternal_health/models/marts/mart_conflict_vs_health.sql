WITH conflict AS (
    SELECT
        state_name,
        CASE
            WHEN event_year BETWEEN 2013 AND 2018 THEN 2018
            WHEN event_year BETWEEN 2019 AND 2024 THEN 2024
            ELSE NULL
        END AS survey_year,
        total_events,
        sum_of_fatalities,
        political_violence_event,
        strategic_dev_event,
        demonstrations_event,
        political_violence_demonstration_event
    FROM {{ ref('int_conflict_intensity') }}
    WHERE state_name IS NOT NULL
),

aggregated AS (
    SELECT
        state_name,
        survey_year,
        SUM(total_events)                                AS cumulative_events,
        SUM(sum_of_fatalities)                           AS cumulative_fatalities,
        SUM(political_violence_event)                    AS cumulative_political_violence_events,
        SUM(strategic_dev_event)                         AS cumulative_strategic_dev_events,
        SUM(demonstrations_event)                        AS cumulative_demonstrations_events,
        SUM(political_violence_demonstration_event)      AS cumulative_political_violence_demonstration_events
    FROM conflict
    WHERE survey_year IS NOT NULL
    GROUP BY state_name, survey_year
),

final AS (
    SELECT
        a.state_name,
        a.survey_year,
        b.zone, 
        a.cumulative_events,
        a.cumulative_fatalities,
        a.cumulative_political_violence_events,
        a.cumulative_strategic_dev_events,
        a.cumulative_demonstrations_events,
        a.cumulative_political_violence_demonstration_events,
        ROUND(b.pct_4plus_anc_visits * 100, 2) AS pct_4plus_anc_visits, 
        ROUND(b.pct_facility_delivery * 100, 2) AS pct_facility_delivery,  
        ROUND(b.pct_skilled_birth_attendant * 100, 2) AS pct_skilled_birth_attendant, 
        ROUND(b.pct_doctor_at_delivery * 100, 2) AS pct_doctor_at_delivery,
        ROUND(b.pct_anc_attended_no_skilled_delivery * 100, 2) AS pct_anc_attended_no_skilled_delivery, 
        ROUND(b.pct_home_delivery_no_skilled_attendant * 100, 2) AS pct_home_delivery_no_skilled_attendant,
        c.neonatal_mortality_rate, 
        c.neonatal_deaths, 
        c.maternal_mortality_ratio_proxy, 
        c.maternal_deaths_proxy      
    FROM aggregated a
    LEFT JOIN {{ ref('int_anc_vs_delivery')}} b
        ON a.state_name = b.state_name AND a.survey_year = b.survey_year
    LEFT JOIN {{ ref('int_neonatal_mortality')}} c
        ON b.state_name = c.state_name AND b.survey_year = c.survey_year
    WHERE a.state_name IS NOT NULL AND a.state_name != ''
)

SELECT * FROM final