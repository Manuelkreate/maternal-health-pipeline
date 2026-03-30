SELECT
    a.state_name,
    a.survey_year,
    COALESCE(a.zone, b.zone) AS zone,
    ROUND(a.pct_4plus_anc_visits * 100, 2) AS pct_4plus_anc_visits, 
    ROUND(a.pct_facility_delivery * 100, 2) AS pct_facility_delivery,  
    ROUND(a.pct_skilled_birth_attendant * 100, 2) AS pct_skilled_birth_attendant, 
    ROUND(a.pct_doctor_at_delivery * 100, 2) AS pct_doctor_at_delivery,
    ROUND(a.pct_anc_attended_no_skilled_delivery * 100, 2) AS pct_anc_attended_no_skilled_delivery, 
    ROUND(a.pct_home_delivery_no_skilled_attendant * 100, 2) AS pct_home_delivery_no_skilled_attendant,
    a.total_respondents_weighted, 
    b.neonatal_mortality_rate, 
    b.neonatal_deaths, 
    b.total_births_weighted, 
    b.maternal_mortality_ratio_proxy,
    b.maternal_deaths_proxy, 
    b.birth_record_count
FROM {{ ref('int_anc_vs_delivery') }} a
LEFT JOIN {{ ref('int_neonatal_mortality') }} b
    ON a.state_name = b.state_name AND a.survey_year = b.survey_year