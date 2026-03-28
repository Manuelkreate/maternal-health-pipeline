SELECT
    year,
    CASE 
        WHEN year BETWEEN 2013 AND 2018 THEN '2013-2018'
        WHEN year BETWEEN 2019 AND 2024 THEN '2019-2024'
    END AS survey_period, 
    country_code, 
    population, 
    health_expenditure_per_capita, 
    oop_expenditure_pct,
    (oop_expenditure_pct/100)*health_expenditure_per_capita AS oop_per_capita_usd
FROM {{ ref('stg_worldbank')}}
WHERE year BETWEEN 2013 AND 2024