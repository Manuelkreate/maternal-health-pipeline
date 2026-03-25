WITH base AS(
    SELECT
        ir.state_code,
        ir.survey_year,
        ir.geopolitical_zone,
        ir.region,
        ir.sample_weight,
        ir.womans_age,
        ir.wealth_index,
        ir.antenatal_care_visits,
        ir.place_of_delivery,
        ir.delivery_attendant_doctor,
        ir.delivery_attendant_cs_1,
        ir.delivery_attendant_cs_2,
        ir.anc_location_home,
        ir.anc_location_other_home,
        s.state_name,
        s.geopolitical_zone AS zone        
    FROM {{ ref('stg_dhs_ir') }} ir
    LEFT JOIN {{ ref('nigeria_states') }} s
        ON (ir.state_code = s.state_code_2018 AND ir.survey_year = 2018)
        OR (ir.state_code = s.state_code_2024 AND ir.survey_year = 2024)
    WHERE wealth_index IS NOT NULL
),

aggregated AS (
    SELECT
        state_name,
        survey_year,
        zone,
        wealth_index,
        SUM(CASE WHEN antenatal_care_visits >= 4 THEN sample_weight ELSE 0 END) 
            / NULLIF(SUM(sample_weight), 0)                     AS pct_4plus_anc_visits,
        SUM(CASE WHEN place_of_delivery >= 20 THEN sample_weight ELSE 0 END) 
            / NULLIF(SUM(sample_weight), 0)                     AS pct_facility_delivery,
        SUM(CASE WHEN delivery_attendant_doctor = 1 THEN sample_weight ELSE 0 END) 
            / NULLIF(SUM(sample_weight), 0)                     AS pct_doctor_at_delivery,
        SUM(CASE WHEN delivery_attendant_doctor = 1 OR delivery_attendant_cs_1 = 1 OR delivery_attendant_cs_2 = 1 THEN sample_weight ELSE 0 END) 
            / NULLIF(SUM(sample_weight), 0)                     AS pct_skilled_birth_attendant,
        SUM(CASE WHEN antenatal_care_visits >= 1 AND place_of_delivery BETWEEN 10 AND 19 THEN sample_weight ELSE 0 END)
            / NULLIF(SUM(sample_weight), 0)                     AS pct_attended_anc_but_delivered_home,
        SUM(CASE WHEN place_of_delivery BETWEEN 10 AND 19 AND delivery_attendant_doctor = 0 AND delivery_attendant_cs_1 = 0 AND delivery_attendant_cs_2 = 0 THEN sample_weight ELSE 0 END)
            / NULLIF(SUM(sample_weight), 0)                     AS pct_home_delivery_no_skilled_attendant,
        SUM(CASE WHEN antenatal_care_visits >= 1 AND delivery_attendant_doctor = 0 AND delivery_attendant_cs_1 = 0 AND delivery_attendant_cs_2 = 0 THEN sample_weight ELSE 0 END)
            / NULLIF(SUM(CASE WHEN antenatal_care_visits >= 1 THEN sample_weight ELSE 0 END)
            , 0)                                                AS pct_anc_attended_no_skilled_delivery,
        SUM(sample_weight)                                      AS total_respondents_weighted,
        COUNT(*)                                                AS respondent_count        
    FROM base
    GROUP BY state_name, survey_year, zone, wealth_index
)

SELECT * FROM aggregated