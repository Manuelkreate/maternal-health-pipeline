WITH anc_delivery AS (
    SELECT
        state_name,
        MAX(CASE WHEN survey_year = 2018 THEN pct_4plus_anc_visits END) AS anc_4plus_visits_2018,
        MAX(CASE WHEN survey_year = 2024 THEN pct_4plus_anc_visits END) AS anc_4plus_visits_2024,
        MAX(CASE WHEN survey_year = 2024 THEN pct_4plus_anc_visits END) - MAX(CASE WHEN survey_year = 2018 THEN pct_4plus_anc_visits END) AS anc_4plus_visits_delta,
        MAX(CASE WHEN survey_year = 2018 THEN pct_facility_delivery END) AS facility_delivery_2018,
        MAX(CASE WHEN survey_year = 2024 THEN pct_facility_delivery END) AS facility_delivery_2024,
        MAX(CASE WHEN survey_year = 2024 THEN pct_facility_delivery END) - MAX(CASE WHEN survey_year = 2018 THEN pct_facility_delivery END) AS facility_delivery_delta,        
        MAX(CASE WHEN survey_year = 2018 THEN pct_doctor_at_delivery END) AS doctor_at_delivery_2018,
        MAX(CASE WHEN survey_year = 2024 THEN pct_doctor_at_delivery END) AS doctor_at_delivery_2024,
        MAX(CASE WHEN survey_year = 2024 THEN pct_doctor_at_delivery END) - MAX(CASE WHEN survey_year = 2018 THEN pct_doctor_at_delivery END) AS doctor_at_delivery_delta,
        MAX(CASE WHEN survey_year = 2018 THEN pct_skilled_birth_attendant END) AS skilled_birth_attendants_2018,
        MAX(CASE WHEN survey_year = 2024 THEN pct_skilled_birth_attendant END) AS skilled_birth_attendants_2024,
        MAX(CASE WHEN survey_year = 2024 THEN pct_skilled_birth_attendant END) - MAX(CASE WHEN survey_year = 2018 THEN pct_skilled_birth_attendant END) AS skilled_birth_attendants_delta,
        MAX(CASE WHEN survey_year = 2018 THEN pct_attended_anc_but_delivered_home END) AS attended_anc_but_delivered_home_2018,
        MAX(CASE WHEN survey_year = 2024 THEN pct_attended_anc_but_delivered_home END) AS attended_anc_but_delivered_home_2024,
        MAX(CASE WHEN survey_year = 2024 THEN pct_attended_anc_but_delivered_home END) - MAX(CASE WHEN survey_year = 2018 THEN pct_attended_anc_but_delivered_home END) AS attended_anc_but_delivered_home_delta,
        MAX(CASE WHEN survey_year = 2018 THEN pct_home_delivery_no_skilled_attendant END) AS home_delivery_no_skilled_attendant_2018,
        MAX(CASE WHEN survey_year = 2024 THEN pct_home_delivery_no_skilled_attendant END) AS home_delivery_no_skilled_attendant_2024,
        MAX(CASE WHEN survey_year = 2024 THEN pct_home_delivery_no_skilled_attendant END) - MAX(CASE WHEN survey_year = 2018 THEN pct_home_delivery_no_skilled_attendant END) AS home_delivery_no_skilled_attendant_delta,
        MAX(CASE WHEN survey_year = 2018 THEN pct_anc_attended_no_skilled_delivery END) AS anc_attended_no_skilled_delivery_2018,
        MAX(CASE WHEN survey_year = 2024 THEN pct_anc_attended_no_skilled_delivery END) AS anc_attended_no_skilled_delivery_2024,
        MAX(CASE WHEN survey_year = 2024 THEN pct_anc_attended_no_skilled_delivery END) - MAX(CASE WHEN survey_year = 2018 THEN pct_anc_attended_no_skilled_delivery END) AS anc_attended_no_skilled_delivery_delta,
        MAX(CASE WHEN survey_year = 2018 THEN respondent_count END) AS respondent_count_2018,
        MAX(CASE WHEN survey_year = 2024 THEN respondent_count END) AS respondent_count_2024,
        MAX(CASE WHEN survey_year = 2024 THEN respondent_count END) - MAX(CASE WHEN survey_year = 2018 THEN respondent_count END) AS respondent_count_delta                                              
    FROM {{ ref('int_anc_vs_delivery')}}
    GROUP BY state_name
),

neonatal_mortality AS (
    SELECT
        state_name,
        MAX(CASE WHEN survey_year = 2018 THEN neonatal_mortality_rate END) AS neonatal_mortality_rate_2018,
        MAX(CASE WHEN survey_year = 2024 THEN neonatal_mortality_rate END) AS neonatal_mortality_rate_2024,
        MAX(CASE WHEN survey_year = 2024 THEN neonatal_mortality_rate END) - MAX(CASE WHEN survey_year = 2018 THEN neonatal_mortality_rate END) AS neonatal_mortality_rate_delta,
        MAX(CASE WHEN survey_year = 2018 THEN total_births_weighted END) AS total_births_weighted_2018,
        MAX(CASE WHEN survey_year = 2024 THEN total_births_weighted END) AS total_births_weighted_2024,
        MAX(CASE WHEN survey_year = 2024 THEN total_births_weighted END) - MAX(CASE WHEN survey_year = 2018 THEN total_births_weighted END) AS total_births_weighted_delta,        
        MAX(CASE WHEN survey_year = 2018 THEN maternal_mortality_ratio_proxy END) AS maternal_mortality_ratio_proxy_2018,
        MAX(CASE WHEN survey_year = 2024 THEN maternal_mortality_ratio_proxy END) AS maternal_mortality_ratio_proxy_2024,
        MAX(CASE WHEN survey_year = 2024 THEN maternal_mortality_ratio_proxy END) - MAX(CASE WHEN survey_year = 2018 THEN maternal_mortality_ratio_proxy END) AS maternal_mortality_ratio_proxy_delta,
        MAX(CASE WHEN survey_year = 2018 THEN respondent_count END) AS birth_record_count_2018,
        MAX(CASE WHEN survey_year = 2024 THEN respondent_count END) AS birth_record_count_2024,
        MAX(CASE WHEN survey_year = 2024 THEN respondent_count END) - MAX(CASE WHEN survey_year = 2018 THEN respondent_count END) AS birth_record_count_delta      
    FROM {{ ref('int_neonatal_mortality')}}
    GROUP BY state_name
),

joined AS (
    SELECT 
        ad.state_name,
        ad.anc_4plus_visits_2018,
        ad.anc_4plus_visits_2024,
        ad.anc_4plus_visits_delta,
        ad.facility_delivery_2018,
        ad.facility_delivery_2024,
        ad.facility_delivery_delta,
        ad.doctor_at_delivery_2018,
        ad.doctor_at_delivery_2024,
        ad.doctor_at_delivery_delta,
        ad.skilled_birth_attendants_2018,
        ad.skilled_birth_attendants_2024,
        ad.skilled_birth_attendants_delta,
        ad.attended_anc_but_delivered_home_2018,
        ad.attended_anc_but_delivered_home_2024,
        ad.attended_anc_but_delivered_home_delta,
        ad.home_delivery_no_skilled_attendant_2018,
        ad.home_delivery_no_skilled_attendant_2024,
        ad.home_delivery_no_skilled_attendant_delta,
        ad.anc_attended_no_skilled_delivery_2018,
        ad.anc_attended_no_skilled_delivery_2024,
        ad.anc_attended_no_skilled_delivery_delta,
        ad.respondent_count_2018,
        ad.respondent_count_2024,
        ad.respondent_count_delta,
        nm.neonatal_mortality_rate_2018,
        nm.neonatal_mortality_rate_2024,
        nm.neonatal_mortality_rate_delta,
        nm.total_births_weighted_2018,
        nm.total_births_weighted_2024,
        nm.total_births_weighted_delta,
        nm.maternal_mortality_ratio_proxy_2018,
        nm.maternal_mortality_ratio_proxy_2024,
        nm.maternal_mortality_ratio_proxy_delta,
        nm.birth_record_count_2018,
        nm.birth_record_count_2024,
        nm.birth_record_count_delta
    FROM anc_delivery ad
    LEFT JOIN neonatal_mortality nm
        ON ad.state_name = nm.state_name
)

SELECT * FROM joined
