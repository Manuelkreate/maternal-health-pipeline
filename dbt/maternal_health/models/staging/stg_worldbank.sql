WITH population AS (
    SELECT
        countryiso3code,
        CAST(date AS INTEGER)   AS year,
        value                   AS population
    FROM {{ source('raw', 'worldbank_population') }}    
),

health_expenditure AS (
    SELECT
        countryiso3code,
        CAST(date AS INTEGER)   AS year,
        value       AS health_expenditure_per_capita
    FROM {{ source('raw', 'worldbank_health_expenditure') }}
),

oop_expenditure AS (
    SELECT
        countryiso3code,
        CAST(date AS INTEGER)   AS year,
        value       AS oop_expenditure_pct
    FROM {{ source('raw', 'worldbank_oop_expenditure') }}
),

joined AS (
    SELECT
        p.year,
        p.countryiso3code         AS country_code,
        p.population,
        h.health_expenditure_per_capita,
        o.oop_expenditure_pct
    FROM population p
    LEFT JOIN health_expenditure h
        ON p.year = h.year
        AND p.countryiso3code = h.countryiso3code
    LEFT JOIN oop_expenditure o
        ON p.year = o.year
        AND p.countryiso3code = o.countryiso3code
    WHERE p.population IS NOT NULL

)

SELECT * FROM joined