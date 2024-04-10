{{ config(materialized='table') }}

WITH base AS (
    SELECT 
        data:activity_period::STRING AS activity_period,
        data:activity_period_start_date::TIMESTAMP AS activity_period_start_date,
        data:aircraft_body_type::STRING AS aircraft_body_type,
        data:aircraft_manufacturer::STRING AS aircraft_manufacturer,
        data:aircraft_model::STRING AS aircraft_model,
        data:data_as_of::TIMESTAMP AS data_as_of,
        data:data_loaded_at::TIMESTAMP AS data_loaded_at,
        data:geo_region::STRING AS geo_region,
        data:geo_summary::STRING AS geo_summary,
        data:landing_aircraft_type::STRING AS landing_aircraft_type,
        data:landing_count::INT AS landing_count,
        data:operating_airline::STRING AS operating_airline,
        data:operating_airline_iata_code::STRING AS operating_airline_iata_code,
        data:published_airline::STRING AS published_airline,
        data:published_airline_iata_code::STRING AS published_airline_iata_code,
        data:total_landed_weight::FLOAT AS total_landed_weight
    FROM {{ source('RAW', 'RAW_LANDING_DATA') }}
    WHERE data:activity_period::STRING IS NOT NULL
    AND data:activity_period_start_date::TIMESTAMP IS NOT NULL
    AND data:data_as_of::TIMESTAMP IS NOT NULL
    AND data:data_loaded_at::TIMESTAMP IS NOT NULL
)

SELECT * FROM base

