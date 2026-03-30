WITH base AS (
    SELECT
        br.state_code,
        br.survey_year,
        br.sample_weight,
        br.antenatal_care_visits,
        br.place_of_delivery,
        br.delivery_attendant_doctor,
        br.delivery_attendant_cs_1,
        br.delivery_attendant_cs_2,
        br.child_alive,
        br.age_of_death_in_completed_months,
        s.state_name,
        s.zone    
    FROM {{ ref('stg_dhs_br') }} br
    LEFT JOIN {{ ref('dim_state') }} s
        ON (br.survey_year = 2018 AND br.state_code = s.state_code_2018)
        OR (br.survey_year = 2024 AND br.state_code = s.state_code_2024)  
),

aggregated AS (
    SELECT
        state_name,
        survey_year,
        zone,
        CASE
            WHEN place_of_delivery >= 20 THEN 'facility_delivery'
            WHEN place_of_delivery BETWEEN 10 AND 19 THEN 'home_delivery'
            ELSE 'unknown'  
        END AS place_of_delivery_category,
        CASE
            WHEN delivery_attendant_doctor = 1 OR delivery_attendant_cs_1 = 1 OR delivery_attendant_cs_2 = 1 THEN 'skilled'
            ELSE 'unskilled'
        END AS birth_attendant_category,            
        CASE 
            WHEN antenatal_care_visits = 0 THEN 'no_anc' 
            WHEN antenatal_care_visits BETWEEN 1 AND 3 THEN 'inadequate_anc'
            WHEN antenatal_care_visits >= 4 AND antenatal_care_visits != 98 THEN 'adequate_anc'
            WHEN antenatal_care_visits = 98 THEN 'unknown'
            ELSE 'unknown' 
        END AS anc_adequacy,                 
        SUM(CASE WHEN child_alive = 0 AND age_of_death_in_completed_months = 0 THEN sample_weight ELSE 0 END) 
            / NULLIF(SUM(sample_weight), 0) * 1000              AS neonatal_mortality_rate,
        SUM(sample_weight)                                      AS total_births_weighted,
        SUM(CASE WHEN child_alive = 0 AND age_of_death_in_completed_months = 0 
            THEN sample_weight ELSE 0 END)                      AS neonatal_deaths,
        COUNT(*)                                                AS birth_record_count
    FROM base
    GROUP BY state_name, survey_year, zone, place_of_delivery_category, birth_attendant_category, anc_adequacy
)

SELECT * FROM aggregated