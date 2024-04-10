{{
  config(
    post_hook=[
      "ALTER TABLE dbt_db.sf_gold.geography_dim ADD CONSTRAINT unique_constraintGD UNIQUE (GEO_REGION)",
      "ALTER TABLE dbt_db.sf_gold.geography_dim ADD CONSTRAINT primary_key_constraintGD PRIMARY KEY (geo_id)"
    ]
  )
}}

WITH geography_dim_data AS (
    SELECT
        GEO_REGION,
        GEO_SUMMARY,
        COUNT(*) AS count,
        RANK() OVER (PARTITION BY GEO_REGION ORDER BY COUNT(*) DESC) AS rank
    FROM
        (
            SELECT GEO_REGION, GEO_SUMMARY FROM {{ ref('updated_cargo') }}
            UNION ALL
            SELECT GEO_REGION, GEO_SUMMARY FROM {{ ref('updated_monthly_passengers') }}
            UNION ALL
            SELECT GEO_REGION, GEO_SUMMARY FROM {{ ref('updated_landing') }}
        ) AS CombinedData
    GROUP BY
        GEO_REGION,
        GEO_SUMMARY
    QUALIFY
        rank = 1
)

SELECT
    ROW_NUMBER() OVER (ORDER BY GEO_REGION) AS geo_id,
    GEO_REGION,
    GEO_SUMMARY
FROM geography_dim_data
