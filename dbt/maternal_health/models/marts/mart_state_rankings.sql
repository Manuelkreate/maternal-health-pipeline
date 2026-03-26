WITH base AS (
    SELECT
        state_name,
        ROUND(anc_4plus_visits_delta * 100, 2) AS anc_4plus_visits_delta,
        DENSE_RANK() OVER (ORDER BY anc_4plus_visits_delta DESC) AS anc_4plus_visits_ranking,
        ROUND(facility_delivery_delta * 100, 2) AS facility_delivery_delta,
        DENSE_RANK() OVER (ORDER BY facility_delivery_delta DESC) AS facility_delivery_ranking,
        ROUND(doctor_at_delivery_delta * 100, 2) AS doctor_at_delivery_delta,
        DENSE_RANK() OVER (ORDER BY doctor_at_delivery_delta DESC) AS doctor_at_delivery_ranking,
        ROUND(skilled_birth_attendants_delta * 100, 2) AS skilled_birth_attendants_delta,
        DENSE_RANK() OVER (ORDER BY skilled_birth_attendants_delta DESC) AS skilled_birth_attendants_ranking,
        ROUND(attended_anc_but_delivered_home_delta * 100, 2) AS attended_anc_but_delivered_home_delta,
        DENSE_RANK() OVER (ORDER BY attended_anc_but_delivered_home_delta) AS attended_anc_but_delivered_home_ranking,
        ROUND(home_delivery_no_skilled_attendant_delta * 100, 2) AS home_delivery_no_skilled_attendant_delta,
        DENSE_RANK() OVER (ORDER BY home_delivery_no_skilled_attendant_delta) AS home_delivery_no_skilled_attendant_ranking,
        ROUND(anc_attended_no_skilled_delivery_delta * 100, 2) AS anc_attended_no_skilled_delivery_delta,
        DENSE_RANK() OVER (ORDER BY anc_attended_no_skilled_delivery_delta) AS anc_attended_no_skilled_delivery_ranking,
        ROUND(neonatal_mortality_rate_delta, 2) AS neonatal_mortality_rate_delta,
        DENSE_RANK() OVER (ORDER BY neonatal_mortality_rate_delta) AS neonatal_mortality_rate_ranking,
        ROUND(maternal_mortality_ratio_proxy_delta, 2) AS maternal_mortality_ratio_proxy_delta,
        DENSE_RANK() OVER (ORDER BY maternal_mortality_ratio_proxy_delta) AS maternal_mortality_ratio_proxy_ranking
    FROM {{ ref('int_dhs_delta') }}
),

normalized AS (  
    SELECT
        state_name,
        ((anc_4plus_visits_ranking) - MIN(anc_4plus_visits_ranking) OVER())/(MAX(anc_4plus_visits_ranking) OVER() - MIN(anc_4plus_visits_ranking) OVER()) AS anc_visits_score,
        ((facility_delivery_ranking) - MIN(facility_delivery_ranking) OVER())/(MAX(facility_delivery_ranking) OVER() - MIN(facility_delivery_ranking) OVER()) AS facility_delivery_score,
        ((doctor_at_delivery_ranking) - MIN(doctor_at_delivery_ranking) OVER())/(MAX(doctor_at_delivery_ranking) OVER() - MIN(doctor_at_delivery_ranking) OVER()) AS doctor_at_delivery_score,
        ((skilled_birth_attendants_ranking) - MIN(skilled_birth_attendants_ranking) OVER())/(MAX(skilled_birth_attendants_ranking) OVER() - MIN(skilled_birth_attendants_ranking) OVER()) AS skilled_birth_attendants_score,
        1 - ((attended_anc_but_delivered_home_ranking) - MIN(attended_anc_but_delivered_home_ranking) OVER())/(MAX(attended_anc_but_delivered_home_ranking) OVER() - MIN(attended_anc_but_delivered_home_ranking) OVER()) AS attended_anc_but_delivered_home_score,
        1 - ((home_delivery_no_skilled_attendant_ranking) - MIN(home_delivery_no_skilled_attendant_ranking) OVER())/(MAX(home_delivery_no_skilled_attendant_ranking) OVER() - MIN(home_delivery_no_skilled_attendant_ranking) OVER()) AS home_delivery_no_skilled_attendant_score,
        1 - ((anc_attended_no_skilled_delivery_ranking) - MIN(anc_attended_no_skilled_delivery_ranking) OVER())/(MAX(anc_attended_no_skilled_delivery_ranking) OVER() - MIN(anc_attended_no_skilled_delivery_ranking) OVER()) AS anc_attended_no_skilled_delivery_score,
        1 - ((neonatal_mortality_rate_ranking) - MIN(neonatal_mortality_rate_ranking) OVER())/(MAX(neonatal_mortality_rate_ranking) OVER() - MIN(neonatal_mortality_rate_ranking) OVER()) AS neonatal_mortality_rate_score,
        1 - ((maternal_mortality_ratio_proxy_ranking) - MIN(maternal_mortality_ratio_proxy_ranking) OVER())/(MAX(maternal_mortality_ratio_proxy_ranking) OVER() - MIN(maternal_mortality_ratio_proxy_ranking) OVER()) AS maternal_mortality_ratio_proxy_score
  FROM base
),

weighted AS (
    SELECT
        state_name,    
        (
            (anc_visits_score * 0.15) + 
            (facility_delivery_score * 0.20) + 
            (doctor_at_delivery_score * 0) + 
            (skilled_birth_attendants_score * 0.15) + 
            (attended_anc_but_delivered_home_score * 0) + 
            (home_delivery_no_skilled_attendant_score * 0.10) + 
            (anc_attended_no_skilled_delivery_score * 0.10) + 
            (neonatal_mortality_rate_score * 0.25) + 
            (maternal_mortality_ratio_proxy_score * 0.05)
        ) / 9   AS weighted_score
    FROM normalized
),

final AS (
    SELECT
        b.state_name,
        b.anc_4plus_visits_delta,
        b.anc_4plus_visits_ranking,
        b.facility_delivery_delta,
        b.facility_delivery_ranking,
        b.doctor_at_delivery_delta,
        b.doctor_at_delivery_ranking,
        b.skilled_birth_attendants_delta,
        b.skilled_birth_attendants_ranking,
        b.attended_anc_but_delivered_home_delta,
        b.attended_anc_but_delivered_home_ranking,
        b.home_delivery_no_skilled_attendant_delta,
        b.home_delivery_no_skilled_attendant_ranking,
        b.anc_attended_no_skilled_delivery_delta,
        b.anc_attended_no_skilled_delivery_ranking,
        b.neonatal_mortality_rate_delta,
        b.neonatal_mortality_rate_ranking,
        b.maternal_mortality_ratio_proxy_delta,
        b.maternal_mortality_ratio_proxy_ranking,        
        w.weighted_score,
        DENSE_RANK() OVER(ORDER BY w.weighted_score ASC) AS weighted_rank
    FROM weighted w
    JOIN base b
        ON w.state_name = b.state_name
)

SELECT * FROM final