WITH neonatal_base AS (
    SELECT
        br.state_code,
        br.survey_year,
        br.sample_weight,
        br.child_alive,
        br.age_of_death_in_completed_months,
        s.state_name,
        s.zone
    FROM {{ ref('stg_dhs_br') }} br
    LEFT JOIN {{ ref('dim_state') }} s
        ON (br.survey_year = 2018 AND br.state_code = s.state_code_2018)
        OR (br.survey_year = 2024 AND br.state_code = s.state_code_2024)   
),

neonatal_agg AS (
    SELECT
        state_name,
        survey_year,
        zone,
        -- Neonatal mortality rate (deaths in first month per 1,000 live births)
        SUM(CASE WHEN child_alive = 0 AND age_of_death_in_completed_months = 0 THEN sample_weight ELSE 0 END) 
            / NULLIF(SUM(sample_weight), 0) * 1000              AS neonatal_mortality_rate,
        SUM(sample_weight)                                      AS total_births_weighted,
        -- Total neonatal deaths (weighted)
        SUM(CASE WHEN child_alive = 0 AND age_of_death_in_completed_months = 0 
            THEN sample_weight ELSE 0 END)                      AS neonatal_deaths,
        COUNT(*)                                                AS birth_record_count
    FROM neonatal_base
    GROUP BY state_name, survey_year, zone
),

maternal_base AS(
    SELECT
        ir.state_code,
        ir.survey_year,
        ir.sample_weight,
        ir.sibling_sex_1, ir.sibling_alive_1, ir.sibling_preg_related_death_1,
        ir.sibling_sex_2, ir.sibling_alive_2, ir.sibling_preg_related_death_2,
        ir.sibling_sex_3, ir.sibling_alive_3, ir.sibling_preg_related_death_3,
        ir.sibling_sex_4, ir.sibling_alive_4, ir.sibling_preg_related_death_4,
        ir.sibling_sex_5, ir.sibling_alive_5, ir.sibling_preg_related_death_5,
        s.state_name,
        s.geopolitical_zone AS zone
    FROM {{ ref('stg_dhs_ir') }} ir
    LEFT JOIN {{ ref('nigeria_states') }} s
        ON (ir.survey_year = 2018 AND ir.state_code = s.state_code_2018)
        OR (ir.survey_year = 2024 AND ir.state_code = s.state_code_2024)
),

maternal_agg AS (
    SELECT
        state_name,
        survey_year,
        zone,
        -- sibling maternal death
        SUM(
            CASE WHEN sibling_sex_1 = 2 AND sibling_alive_1 = 0 AND sibling_preg_related_death_1 BETWEEN 2 AND 6 THEN sample_weight ELSE 0 END +
            CASE WHEN sibling_sex_2 = 2 AND sibling_alive_2 = 0 AND sibling_preg_related_death_2 BETWEEN 2 AND 6 THEN sample_weight ELSE 0 END +
            CASE WHEN sibling_sex_3 = 2 AND sibling_alive_3 = 0 AND sibling_preg_related_death_3 BETWEEN 2 AND 6 THEN sample_weight ELSE 0 END +
            CASE WHEN sibling_sex_4 = 2 AND sibling_alive_4 = 0 AND sibling_preg_related_death_4 BETWEEN 2 AND 6 THEN sample_weight ELSE 0 END +
            CASE WHEN sibling_sex_5 = 2 AND sibling_alive_5 = 0 AND sibling_preg_related_death_5 BETWEEN 2 AND 6 THEN sample_weight ELSE 0 END 
        )                   AS maternal_deaths_proxy,
        COUNT(*)            AS respondent_count
    FROM maternal_base
    GROUP BY state_name, survey_year, zone
),

final AS (
    SELECT
        n.state_name,
        n.survey_year,
        n.zone,
        n.neonatal_mortality_rate,
        n.total_births_weighted,
        n.neonatal_deaths,
        n.birth_record_count,
        m.maternal_deaths_proxy,
        -- maternal death ratio per 100,000 live births
        m.maternal_deaths_proxy 
            / NULLIF(n.total_births_weighted, 0) * 100000   AS maternal_mortality_ratio_proxy,
        m.respondent_count        
    FROM neonatal_agg n
    LEFT JOIN maternal_agg m
        ON n.state_name = m.state_name AND n.survey_year = m.survey_year
)

SELECT * FROM final