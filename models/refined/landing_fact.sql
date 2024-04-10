{{
  config(
    post_hook=["ALTER TABLE dbt_db.sf_gold.landing_fact ADD CONSTRAINT unique_constraint UNIQUE (ACTIVITY_PERIOD_ID,OPERATING_AIRLINE_IATA_CODE_ID,PUBLISHED_AIRLINE_IATA_CODE_ID,GEO_REGION_ID,AIRCRAFT_MODEL_ID)",
      "ALTER TABLE dbt_db.sf_gold.landing_fact ADD CONSTRAINT fk_landing1 FOREIGN KEY (ACTIVITY_PERIOD_ID) REFERENCES dbt_db.sf_gold.date_dim (time_id)",
      "ALTER TABLE dbt_db.sf_gold.landing_fact ADD CONSTRAINT fk_landing2 FOREIGN KEY (OPERATING_AIRLINE_IATA_CODE_ID) REFERENCES dbt_db.sf_gold.airline_dim(airline_id)",
      "ALTER TABLE dbt_db.sf_gold.landing_fact ADD CONSTRAINT fk_landing3 FOREIGN KEY (PUBLISHED_AIRLINE_IATA_CODE_ID) REFERENCES dbt_db.sf_gold.airline_dim(airline_id)",
      "ALTER TABLE dbt_db.sf_gold.landing_fact ADD CONSTRAINT fk_landing4 FOREIGN KEY (GEO_REGION_ID) REFERENCES dbt_db.sf_gold.geography_dim (geo_id)",
      "ALTER TABLE dbt_db.sf_gold.landing_fact ADD CONSTRAINT fk_landing5 FOREIGN KEY (AIRCRAFT_MODEL_ID) REFERENCES dbt_db.sf_gold.aircraft_dim (aircraft_id)"
    ]
  )
}}

WITH landing_fact_data AS (
    SELECT
        d.time_id AS ACTIVITY_PERIOD_ID,
        ad.airline_id AS OPERATING_AIRLINE_IATA_CODE_ID,
        ad1.airline_id AS PUBLISHED_AIRLINE_IATA_CODE_ID,
        gd.geo_id AS GEO_REGION_ID,
        ac.aircraft_id AS AIRCRAFT_MODEL_ID,
        SUM(l.LANDING_COUNT) AS LANDING_COUNT,
        SUM(l.TOTAL_LANDED_WEIGHT) AS TOTAL_LANDED_WEIGHT
    FROM
        {{ ref('updated_landing') }} l
    JOIN
        {{ ref('date_dim') }} d ON TO_CHAR(l.ACTIVITY_PERIOD_START_DATE, 'YYYYMMDD') = d.time_id
    JOIN
        {{ ref('airline_dim') }} ad ON l.OPERATING_AIRLINE_IATA_CODE = ad.AIRLINE_IATA_CODE AND to_number(TO_CHAR(l.ACTIVITY_PERIOD_START_DATE, 'YYYYMMDD')) between ad.START_DATE and ad.END_DATE
    JOIN
        {{ ref('airline_dim') }} ad1 ON l.PUBLISHED_AIRLINE_IATA_CODE = ad1.AIRLINE_IATA_CODE AND to_number(TO_CHAR(l.ACTIVITY_PERIOD_START_DATE, 'YYYYMMDD')) between ad1.START_DATE and ad1.END_DATE
    JOIN
        {{ ref('geography_dim') }} gd ON l.GEO_REGION = gd.GEO_REGION
    JOIN
        {{ ref('aircraft_dim') }} ac ON l.AIRCRAFT_MODEL = ac.AIRCRAFT_MODEL
    GROUP BY
        d.time_id,
        ad.airline_id,
        ad1.airline_id,
        gd.geo_id,
        ac.aircraft_id
)

SELECT * FROM landing_fact_data
