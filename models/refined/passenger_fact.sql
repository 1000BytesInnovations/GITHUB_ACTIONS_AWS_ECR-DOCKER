{{
  config(
    post_hook=["ALTER TABLE dbt_db.sf_gold.passenger_fact ADD CONSTRAINT unique_constraint2 UNIQUE (ACTIVITY_PERIOD_ID,OPERATING_AIRLINE_IATA_CODE_ID,PUBLISHED_AIRLINE_IATA_CODE_ID,GEO_REGION_ID)",
      "ALTER TABLE dbt_db.sf_gold.passenger_fact ADD CONSTRAINT fk_passenger1 FOREIGN KEY (ACTIVITY_PERIOD_ID) REFERENCES dbt_db.sf_gold.date_dim (time_id)",
      "ALTER TABLE dbt_db.sf_gold.passenger_fact ADD CONSTRAINT fk_passenger2 FOREIGN KEY (OPERATING_AIRLINE_IATA_CODE_ID) REFERENCES dbt_db.sf_gold.airline_dim(airline_id)",
      "ALTER TABLE dbt_db.sf_gold.passenger_fact ADD CONSTRAINT fk_passenger3 FOREIGN KEY (PUBLISHED_AIRLINE_IATA_CODE_ID) REFERENCES dbt_db.sf_gold.airline_dim(airline_id)",
      "ALTER TABLE dbt_db.sf_gold.passenger_fact ADD CONSTRAINT fk_passenger4 FOREIGN KEY (GEO_REGION_ID) REFERENCES dbt_db.sf_gold.geography_dim (geo_id)"
    ]
  )
}}

WITH passenger_fact_data AS (
    SELECT
        d.time_id AS ACTIVITY_PERIOD_ID,
        ad.airline_id AS OPERATING_AIRLINE_IATA_CODE_ID,
        ad1.airline_id AS PUBLISHED_AIRLINE_IATA_CODE_ID,
        gd.geo_id AS GEO_REGION_ID,
        sum(P.PASSENGER_COUNT) as PASSENGER_COUNT
    FROM
        {{ ref('updated_monthly_passengers') }} P
    JOIN
        {{ ref('date_dim') }} d ON TO_CHAR(P.ACTIVITY_PERIOD_START_DATE, 'YYYYMMDD') = d.time_id
    JOIN
        {{ ref('airline_dim') }} ad ON P.OPERATING_AIRLINE_IATA_CODE = ad.AIRLINE_IATA_CODE AND  to_number(TO_CHAR(p.ACTIVITY_PERIOD_START_DATE, 'YYYYMMDD')) between ad.START_DATE and ad.END_DATE
    JOIN
        {{ ref('airline_dim') }} ad1 ON P.PUBLISHED_AIRLINE_IATA_CODE = ad1.AIRLINE_IATA_CODE AND  to_number(TO_CHAR(p.ACTIVITY_PERIOD_START_DATE, 'YYYYMMDD')) between ad1.START_DATE and ad1.END_DATE
    JOIN
        {{ ref('geography_dim') }} gd ON P.GEO_REGION = gd.GEO_REGION
    GROUP BY
        d.time_id,
        ad.airline_id,
        ad1.airline_id,
        gd.geo_id
)

SELECT * FROM passenger_fact_data
