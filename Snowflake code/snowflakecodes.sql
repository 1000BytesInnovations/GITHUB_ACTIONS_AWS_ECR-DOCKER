use role accountadmin;

create warehouse dbt_wh with warehouse_size='x-small';
create database if not exists dbt_db;
create role if not exists dbt_role;

show grants on warehouse dbt_wh;
show grants on database dbt_db;

USE ROLE ACCOUNTADMIN;
grant usage on warehouse dbt_wh to role dbt_role;
grant all on database dbt_db to role dbt_role;

use role dbt_role;

create schema if not exists dbt_db.dbt_schema;

create schema if not exists sf_raw;








CREATE or replace STORAGE INTEGRATION s3_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'aws role arn'          --creating storage integration
  STORAGE_ALLOWED_LOCATIONS = ('s3://sandbox-learning-01/vk')
  STORAGE_AWS_EXTERNAL_ID = 'externalid1';

  
  desc STORAGE INTEGRATION s3_int; --to get the "STORAGE_AWS_IAM_USER_ARN"




CREATE or replace  STAGE s3stage
  URL = 's3://sandbox-learning-01/vk'
  STORAGE_INTEGRATION = s3_int
  DIRECTORY = (                              --creating a external stage
    ENABLE = true
    AUTO_REFRESH = true
    refresh_on_create=true
  );



  

create or replace file format my_json_format
 type = json
 null_if = ('\\n', 'null', '')                  --creating file format
    strip_outer_array = true

------------------------------------------------------------------------------------------------------------------------------------------------
CREATING SNOWPIPES(AUTO-INGEST)
    
create or replace pipe s3pipe_cargo auto_ingest=true as
  copy into DBT_DB.RAW.RAW_CARGO
  from @s3stage/cargo_data                                      
  file_format = my_json_format;

create or replace pipe s3pipe_landing_data auto_ingest=true as
  copy into DBT_DB.RAW.RAW_LANDING_DATA                                     
  from @s3stage/landing_data
  file_format = my_json_format;

create or replace pipe s3pipe_monthly_passenger auto_ingest=true as
  copy into DBT_DB.RAW.RAW_MONTHLY_PASSENGER
  from @s3stage/monthly_passenger
  file_format = my_json_format;

---------------------------------------------------------------------------------------------------------------------------------------------------
