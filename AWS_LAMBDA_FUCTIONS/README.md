# Lambda Function README

## Overview

These Lambda function are designed to extract the data from SFO data sources and trigger ECS tasks after data is loaded into the snowflake
## Dependencies

This Lambda function relies on the following modules/packages:
  **Data Extraction:**
- `requests.zip`
  **ECS_TRIGGER:**
- `snowflake_lambda_layer.zip`

## How to Use

1. **Setting Environment Variables**:
   - Navigate to the AWS Lambda console.
   - Locate the Lambda function and click on it.
   - Scroll down to the "Environment variables" section.
   - Add the required environment variables listed 

2. **Adding Layers**:
   - Download the provided zip files of modules.
   - Navigate to the AWS Lambda console.
   - Locate the Lambda function and click on it.
   - Scroll down to the "Layers" section.
   - Click on "Add a layer".
   - Upload the downloaded zip files as layers.

## Additional Notes

    - make sure to change the bucket name and key to your needs and that comply with the code.
    - place the previous_timestamp.txt file in the bucket that is specified in your fuction.