WITH ir AS (
    SELECT
        caseid, v000, v001, v005, v024, v025,
        v190, v501, v481, v012, sstate,
        m14_1, m15_1, m3a_1, m3b_1, m3c_1,
        m57a_1, m57b_1, m70_1, m72_1,
        mm1_01, mm2_01, mm7_01, mm9_01, mm15_01,
        mm1_02, mm2_02, mm7_02, mm9_02, mm15_02,
        mm1_03, mm2_03, mm7_03, mm9_03, mm15_03,
        mm1_04, mm2_04, mm7_04, mm9_04, mm15_04,
        mm1_05, mm2_05, mm7_05, mm9_05, mm15_05,
        NULL AS szone
    FROM {{ source('raw', 'dhs_ir_2018')}}

    UNION ALL

    SELECT
        caseid, v000, v001, v005, v024, v025,
        v190, v501, v481, v012, sstate,
        m14_1, m15_1, m3a_1, m3b_1, m3c_1,
        m57a_1, m57b_1, m70_1, m72_1,
        mm1_01, mm2_01, mm7_01, mm9_01, mm15_01,
        mm1_02, mm2_02, mm7_02, mm9_02, mm15_02,
        mm1_03, mm2_03, mm7_03, mm9_03, mm15_03,
        mm1_04, mm2_04, mm7_04, mm9_04, mm15_04,
        mm1_05, mm2_05, mm7_05, mm9_05, mm15_05,
        szone    
    FROM {{ source('raw', 'dhs_ir_2024')}}
),

renamed AS (
    SELECT
        CONCAT(
            TRIM(CAST(caseid AS STRING)), '_',
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
        szone                           AS geopolitical_zone,
        v024                            AS region,
        v025                            AS urban_rural,
        v001                            AS cluster_num,
        CAST(v005 AS FLOAT64)             AS sample_weight,
        CAST(v012 AS INTEGER)           AS womans_age,
        v501                            AS marital_status,
        v190                            AS wealth_index,
        v481                            AS health_insurance,
        CAST(m14_1 AS INTEGER)          AS antenatal_care_visits,
        m57a_1                          AS anc_location_home,
        m57b_1                          AS anc_location_other_home,
        CAST(m15_1 AS INTEGER)          AS place_of_delivery,
        CAST(m3a_1 AS INTEGER)          AS delivery_attendant_doctor,
        CAST(m3b_1 AS INTEGER)          AS delivery_attendant_cs_1,
        CAST(m3c_1 AS INTEGER)          AS delivery_attendant_cs_2,
        CAST(m70_1 AS INTEGER)          AS postnatal_care_visits_2months,
        m72_1                           AS postnatal_care_attendant,
        CAST(mm1_01 AS INTEGER)         AS sibling_sex_1,
        CAST(mm2_01 AS INTEGER)         AS sibling_alive_1,
        CAST(mm7_01 AS INTEGER)         AS sibling_age_at_death_1,
        CAST(mm9_01 AS INTEGER)         AS sibling_preg_related_death_1,
        CAST(mm15_01 AS INTEGER)        AS sibling_year_of_death_1,
        CAST(mm1_02 AS INTEGER)         AS sibling_sex_2,
        CAST(mm2_02 AS INTEGER)         AS sibling_alive_2,
        CAST(mm7_02 AS INTEGER)         AS sibling_age_at_death_2,
        CAST(mm9_02 AS INTEGER)         AS sibling_preg_related_death_2,
        CAST(mm15_02 AS INTEGER)        AS sibling_year_of_death_2,
        CAST(mm1_03 AS INTEGER)         AS sibling_sex_3,
        CAST(mm2_03 AS INTEGER)         AS sibling_alive_3,
        CAST(mm7_03 AS INTEGER)         AS sibling_age_at_death_3,
        CAST(mm9_03 AS INTEGER)         AS sibling_preg_related_death_3,
        CAST(mm15_03 AS INTEGER)        AS sibling_year_of_death_3,
        CAST(mm1_04 AS INTEGER)         AS sibling_sex_4,
        CAST(mm2_04 AS INTEGER)         AS sibling_alive_4,
        CAST(mm7_04 AS INTEGER)         AS sibling_age_at_death_4,
        CAST(mm9_04 AS INTEGER)         AS sibling_preg_related_death_4,
        CAST(mm15_04 AS INTEGER)        AS sibling_year_of_death_4,
        CAST(mm1_05 AS INTEGER)         AS sibling_sex_5,
        CAST(mm2_05 AS INTEGER)         AS sibling_alive_5,
        CAST(mm7_05 AS INTEGER)         AS sibling_age_at_death_5,
        CAST(mm9_05 AS INTEGER)         AS sibling_preg_related_death_5,
        CAST(mm15_05 AS INTEGER)        AS sibling_year_of_death_5
    FROM ir
)

SELECT * FROM renamed
