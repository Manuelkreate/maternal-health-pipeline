WITH br AS (
    SELECT 
        caseid, v000, v001, v002, v003, v005,
        v024, v025, sstate,
        bidx, bord, b2, b4, b5, b6, b7, b11, m14, m15, m3a, m3b, m3c    
    FROM {{ source('raw', 'dhs_br_2018')}}

    UNION ALL

    SELECT 
        caseid, v000, v001, v002, v003, v005,
        v024, v025, sstate,
        bidx, bord, b2, b4, b5, b6, b7, b11, m14, m15, m3a, m3b, m3c     
    FROM {{ source('raw', 'dhs_br_2024')}}
),

renamed AS (
    SELECT
        CONCAT(
            TRIM(CAST(caseid AS STRING)), '_',
            CAST(bidx AS STRING), '_',
            CAST(
                CASE WHEN v000 = 'NG7' THEN 2018
                    WHEN v000 = 'NG8' THEN 2024
                    ELSE NULL
                END AS STRING)
        )                               AS unique_id,
        CASE WHEN v000 = 'NG7' THEN 2018
             WHEN v000 = 'NG8' THEN 2024
             ELSE NULL
        END                             AS survey_year,
        TRIM(CAST(caseid AS STRING))    AS case_id,
        sstate                          AS state_code,
        v001                            AS cluster_num,
        CAST(v005 AS FLOAT64)/1000000   AS sample_weight,
        v024                            AS region,
        v025                            AS urban_rural,
        bidx                            AS birth_index,
        bord                            AS birth_order_num,
        CAST(m14 AS INTEGER)          AS antenatal_care_visits,
        CAST(m15 AS INTEGER)          AS place_of_delivery,        
        CAST(m3a AS INTEGER)          AS delivery_attendant_doctor,
        CAST(m3b AS INTEGER)          AS delivery_attendant_cs_1,
        CAST(m3c AS INTEGER)          AS delivery_attendant_cs_2,        
        b2                              AS year_of_birth,
        b4                              AS sex_of_child,
        b5                              AS child_alive,
        b6                              AS age_of_death_as_reported,
        b7                              AS age_of_death_in_completed_months,
        b11                             AS preceeding_birth_interval_months
    FROM br
)

SELECT * FROM renamed