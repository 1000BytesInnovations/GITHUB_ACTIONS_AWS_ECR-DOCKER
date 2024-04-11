import os
import json
import boto3
import requests
from datetime import datetime

s3 = boto3.client('s3')
bucket_name = 'learning-01'  # replace with your bucket name
folder_name = 'vk/landing_data'  # replace with your folder name
api_endpoint = 'https://data.sfgov.org/resource/fpux-q53t.json' 

def lambda_handler(event, context):
    lines_per_file = 1000
    offset = 0
    total_records = 0

    while True:
        response = requests.get(f"{api_endpoint}?$limit={lines_per_file}&$offset={offset}")
        data = response.json()
        if not data:
            break

        total_records += len(data)
        print(f"Total records: {total_records}")  # Print the total number of records
        
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

        filename = f'{folder_name}/file_{timestamp}_{offset//lines_per_file + 1}.json'
        try:
            s3.put_object(Body=json.dumps(data), Bucket=bucket_name, Key=filename)
            print(f"Uploaded file {filename}")  # Print a message each time a file is uploaded
        except Exception as e:
            print(f"Failed to upload {filename} to S3: {e}")

        offset += lines_per_file
