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
        ir.wealth_index,
        s.state_name,
        s.zone
    FROM {{ ref('stg_dhs_br') }} br
    LEFT JOIN {{ ref('stg_dhs_ir') }} ir
        ON br.case_id = ir.case_id
        AND br.survey_year = ir.survey_year
    LEFT JOIN {{ ref('dim_state') }} s
        ON (br.survey_year = 2018 AND br.state_code = s.state_code_2018)
        OR (br.survey_year = 2024 AND br.state_code = s.state_code_2024)
    WHERE ir.wealth_index IS NOT NULL
),

aggregated AS (
    SELECT
        state_name,
        survey_year,
        zone,
        wealth_index,
        SUM(CASE WHEN child_alive = 0 AND age_of_death_in_completed_months = 0 
            THEN sample_weight ELSE 0 END)
            / NULLIF(SUM(sample_weight), 0) * 1000              AS neonatal_mortality_rate,
        SUM(sample_weight)                                      AS total_births_weighted,
        SUM(CASE WHEN child_alive = 0 AND age_of_death_in_completed_months = 0
            THEN sample_weight ELSE 0 END)                      AS neonatal_deaths,
        SUM(CASE WHEN place_of_delivery BETWEEN 10 AND 19
            AND delivery_attendant_doctor = 0
            AND delivery_attendant_cs_1 = 0
            AND delivery_attendant_cs_2 = 0
            THEN sample_weight ELSE 0 END)
            / NULLIF(SUM(sample_weight), 0)                     AS pct_home_delivery_no_skilled_attendant,
        COUNT(*)                                                AS birth_record_count
    FROM base
    GROUP BY state_name, survey_year, zone, wealth_index
),

with_flag AS (
    SELECT
        *,
        CASE
            WHEN birth_record_count >= 50 THEN 'stable'
            WHEN birth_record_count >= 25 THEN 'reliable'
            ELSE 'unreliable'
        END AS reliability_flag
    FROM aggregated
)

SELECT * FROM with_flag