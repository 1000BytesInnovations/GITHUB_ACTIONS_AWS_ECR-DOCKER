{{ config(materialized='table') }}
WITH base AS (
    SELECT 
        data:activity_period::STRING AS activity_period,
        data:activity_period_start_date::TIMESTAMP AS activity_period_start_date,
        data:activity_type_code::STRING AS activity_type_code,
        data:cargo_aircraft_type::STRING AS cargo_aircraft_type,
        data:cargo_metric_tons::FLOAT AS cargo_metric_tons,
        data:cargo_type_code::STRING AS cargo_type_code,
        data:cargo_weight_lbs::FLOAT AS cargo_weight_lbs,
        data:data_as_of::TIMESTAMP AS data_as_of,
        data:data_loaded_at::TIMESTAMP AS data_loaded_at,
        data:geo_region::STRING AS geo_region,
        data:geo_summary::STRING AS geo_summary,
        data:operating_airline::STRING AS operating_airline,
        data:operating_airline_iata_code::STRING AS operating_airline_iata_code,
        data:published_airline::STRING AS published_airline,
        data:published_airline_iata_code::STRING AS published_airline_iata_code
    FROM {{ source('RAW', 'RAW_CARGO') }}
    WHERE data:activity_period::STRING IS NOT NULL
    AND data:activity_period_start_date::TIMESTAMP IS NOT NULL
    AND data:data_as_of::TIMESTAMP IS NOT NULL
    AND data:data_loaded_at::TIMESTAMP IS NOT NULL
)

SELECT * FROM base

