WITH base AS (
    SELECT
        br.state_code,
        br.survey_year,
        br.sample_weight,
        br.child_alive,
        br.birth_order_num,
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
        birth_order_num,
        -- Neonatal mortality rate (deaths in first month per 1,000 live births)
        SUM(CASE WHEN child_alive = 0 AND age_of_death_in_completed_months = 0 THEN sample_weight ELSE 0 END) 
            / NULLIF(SUM(sample_weight), 0) * 1000              AS neonatal_mortality_rate,
        SUM(sample_weight)                                      AS total_births_weighted,
        -- Total neonatal deaths (weighted)
        SUM(CASE WHEN child_alive = 0 AND age_of_death_in_completed_months = 0 
            THEN sample_weight ELSE 0 END)                      AS neonatal_deaths,
        COUNT(*)                                                AS birth_record_count
    FROM base
    GROUP BY state_name, survey_year, zone, birth_order_num
),

final AS (
    SELECT
        state_name,
        survey_year,
        zone,
        birth_order_num,
        neonatal_mortality_rate,
        total_births_weighted,
        neonatal_deaths,
        birth_record_count,
        CASE 
            WHEN birth_record_count >= 50 THEN 'reliable'
            WHEN birth_record_count >= 25 THEN 'stable'
            ELSE 'unreliable'
        END AS reliability_flag
    FROM aggregated 
)

SELECT * FROM final