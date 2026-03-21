WITH nr AS (
    SELECT *
    FROM {{ source('raw', 'dhs_nr_2024')}}
),

renamed AS (
    SELECT
        CONCAT(
            TRIM(CAST(caseid AS STRING)), '_',
            CAST(pidx AS STRING), '_',
            '2024'
        )                               AS unique_id,
        2024                            AS survey_year,
        TRIM(CAST(caseid AS STRING))    AS case_id,
        v001                            AS cluster_num,
        CAST(v005 AS FLOAT64)           AS sample_weight,
        sstate                          AS state_code,
        szone                           AS geopolitical_zone,
        v024                            AS region,
        v025                            AS urban_rural,
        pidx                            AS pregnancy_index,
        m1                              AS num_tetanus_injections,
        CAST(m14 AS INTEGER)            AS antenatal_care_visits,
        CAST(m15 AS INTEGER)            AS place_of_delivery,
        CAST(m3a AS INTEGER)            AS delivery_attendant_doctor,
        CAST(m3b AS INTEGER)            AS delivery_attendant_cs_1,
        CAST(m3c AS INTEGER)            AS delivery_attendant_cs_2,
        CAST(m57a AS INTEGER)           AS anc_location_home,
        CAST(m57b AS INTEGER)           AS anc_location_other_home,
        CAST(m70 AS INTEGER)            AS postnatal_care_visits_2months,
        m72                             AS postnatal_care_attendant
    FROM nr
)

SELECT * FROM renamed