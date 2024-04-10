{{
  config(
    post_hook=[
      "ALTER TABLE dbt_db.sf_gold.aircraft_dim ADD CONSTRAINT unique_constraintAC UNIQUE (AIRCRAFT_MODEL)",
      "ALTER TABLE dbt_db.sf_gold.aircraft_dim ADD CONSTRAINT primary_key_constraintAC PRIMARY KEY (aircraft_id)"
    ]
  )
}}


WITH aircraft_dim_data AS (
    SELECT
        AIRCRAFT_MANUFACTURER,
        AIRCRAFT_MODEL,
        AIRCRAFT_BODY_TYPE,
        COUNT(*) AS count,
        RANK() OVER (PARTITION BY AIRCRAFT_MODEL ORDER BY COUNT(*) DESC) AS rank
    FROM
        {{ ref('updated_landing') }}
    GROUP BY
        AIRCRAFT_MANUFACTURER,
        AIRCRAFT_MODEL,
        AIRCRAFT_BODY_TYPE
    QUALIFY
        rank = 1
)

SELECT
    ROW_NUMBER() OVER (ORDER BY AIRCRAFT_MODEL) AS aircraft_id,
    AIRCRAFT_MANUFACTURER,
    AIRCRAFT_MODEL,
    AIRCRAFT_BODY_TYPE
FROM aircraft_dim_data
