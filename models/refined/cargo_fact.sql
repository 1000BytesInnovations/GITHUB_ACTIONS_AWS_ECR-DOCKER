{{
  config(
    post_hook=["ALTER TABLE dbt_db.sf_gold.cargo_fact ADD CONSTRAINT unique_constraint1 UNIQUE (ACTIVITY_PERIOD_ID,OPERATING_AIRLINE_IATA_CODE_ID,PUBLISHED_AIRLINE_IATA_CODE_ID,GEO_REGION_ID)",
      "ALTER TABLE dbt_db.sf_gold.cargo_fact ADD CONSTRAINT fk_cargo6 FOREIGN KEY (ACTIVITY_PERIOD_ID) REFERENCES dbt_db.sf_gold.date_dim (time_id)",
      "ALTER TABLE dbt_db.sf_gold.cargo_fact ADD CONSTRAINT fk_cargo2 FOREIGN KEY (OPERATING_AIRLINE_IATA_CODE_ID) REFERENCES dbt_db.sf_gold.airline_dim(airline_id)",
      "ALTER TABLE dbt_db.sf_gold.cargo_fact ADD CONSTRAINT fk_cargo3 FOREIGN KEY (PUBLISHED_AIRLINE_IATA_CODE_ID) REFERENCES dbt_db.sf_gold.airline_dim(airline_id)",
      "ALTER TABLE dbt_db.sf_gold.cargo_fact ADD CONSTRAINT fk_cargo4 FOREIGN KEY (GEO_REGION_ID) REFERENCES dbt_db.sf_gold.geography_dim (geo_id)"
    ]
  )
}}

WITH cargo_fact_data AS (
    SELECT
        d.time_id AS ACTIVITY_PERIOD_ID,
        ad.airline_id AS OPERATING_AIRLINE_IATA_CODE_ID,
        ad1.airline_id AS PUBLISHED_AIRLINE_IATA_CODE_ID,
        gd.geo_id AS GEO_REGION_ID,
        sum(c.CARGO_METRIC_TONS) AS CARGO_METRIC_TONS,
        sum(c.CARGO_WEIGHT_LBS) AS CARGO_WEIGHT_LBS
    FROM
        {{ ref('updated_cargo') }} c
    JOIN
        {{ ref('date_dim') }} d ON TO_CHAR(c.ACTIVITY_PERIOD_START_DATE, 'YYYYMMDD') = d.time_id
    JOIN
        {{ ref('airline_dim') }} ad ON c.OPERATING_AIRLINE_IATA_CODE = ad.AIRLINE_IATA_CODE AND to_number(TO_CHAR(c.ACTIVITY_PERIOD_START_DATE, 'YYYYMMDD')) between ad.START_DATE and ad.END_DATE
    JOIN
        {{ ref('airline_dim') }} ad1 ON c.PUBLISHED_AIRLINE_IATA_CODE = ad1.AIRLINE_IATA_CODE AND to_number(TO_CHAR(c.ACTIVITY_PERIOD_START_DATE, 'YYYYMMDD')) between ad1.START_DATE and ad1.END_DATE
    JOIN
        {{ ref('geography_dim') }} gd ON c.GEO_REGION = gd.GEO_REGION
    GROUP BY
        d.time_id,
        ad.airline_id,
        ad1.airline_id,
        gd.geo_id
)

SELECT * FROM cargo_fact_data
