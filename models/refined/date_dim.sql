{{
  config(
    post_hook=[
      "ALTER TABLE dbt_db.sf_gold.date_dim ADD CONSTRAINT unique_constraintDD UNIQUE (time_id)",
      "ALTER TABLE dbt_db.sf_gold.date_dim ADD CONSTRAINT primary_key_constraintDD PRIMARY KEY (time_id)"
    ]
  )
}}

WITH date_dim_data AS (
    SELECT DISTINCT
        TO_NUMBER(TO_CHAR(TO_TIMESTAMP(ACTIVITY_PERIOD_START_DATE), 'YYYYMMDD')) AS time_id,
        TO_TIMESTAMP(ACTIVITY_PERIOD_START_DATE) AS activity_period,
        ACTIVITY_PERIOD_START_DATE,
        TO_CHAR(TO_TIMESTAMP(ACTIVITY_PERIOD_START_DATE), 'DY') AS day_of_week,
        EXTRACT(MONTH FROM TO_TIMESTAMP(ACTIVITY_PERIOD_START_DATE)) AS month_of_year,
        EXTRACT(YEAR FROM TO_TIMESTAMP(ACTIVITY_PERIOD_START_DATE)) AS year
    FROM
        (
            SELECT ACTIVITY_PERIOD, ACTIVITY_PERIOD_START_DATE FROM {{ ref('updated_cargo') }}
            UNION ALL
            SELECT ACTIVITY_PERIOD, ACTIVITY_PERIOD_START_DATE FROM {{ ref('updated_monthly_passengers') }}
            UNION ALL
            SELECT ACTIVITY_PERIOD, ACTIVITY_PERIOD_START_DATE FROM {{ ref('updated_landing') }}
        ) combined_data
)

SELECT * FROM date_dim_data
